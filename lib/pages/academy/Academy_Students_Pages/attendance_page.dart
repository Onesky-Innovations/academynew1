import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academynew1/theme/app_theme.dart';

class AttendancePage extends StatefulWidget {
  final String academyUid;
  final String academyId;

  const AttendancePage({
    super.key,
    required this.academyUid,
    required this.academyId,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime selectedDate = DateTime.now();
  String searchQuery = "";
  Set<String> selectedStudents = {};

  String get dateKey =>
      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

  /// ✅ Always update attendance as a Map (prevents int/string issues)
  Future<void> _markAttendance(String studentId, bool isPresent) async {
    try {
      await _firestore
          .collection('academies')
          .doc(widget.academyUid)
          .collection('students')
          .doc(studentId)
          .set({
        "attendance": {
          dateKey: isPresent ? "present" : "absent",
        }
      }, SetOptions(merge: true)); // ✅ ensures attendance stays a Map
    } catch (e) {
      debugPrint("Error marking attendance: $e");
    }
  }

  Future<void> _markSelectedAttendance(bool isPresent) async {
    for (var studentId in selectedStudents) {
      await _markAttendance(studentId, isPresent);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPresent
              ? "All selected marked Present ✅"
              : "All selected marked Absent ❌",
        ),
      ),
    );
    setState(() {
      selectedStudents.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          // ✅ Mark Present
          TextButton(
            onPressed: selectedStudents.isEmpty
                ? null
                : () => _markSelectedAttendance(true),
            child: const Text(
              "Present",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // ❌ Mark Absent
          TextButton(
            onPressed: selectedStudents.isEmpty
                ? null
                : () => _markSelectedAttendance(false),
            child: const Text(
              "Absent",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search students...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
            ),
          ),

          // ✅ Select All / Clear All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.select_all),
                  label: const Text("Select All"),
                  onPressed: () async {
                    final snapshot = await _firestore
                        .collection('academies')
                        .doc(widget.academyUid)
                        .collection('students')
                        .get();
                    setState(() {
                      selectedStudents =
                          snapshot.docs.map((doc) => doc.id).toSet();
                    });
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear"),
                  onPressed: () {
                    setState(() {
                      selectedStudents.clear();
                    });
                  },
                ),
              ],
            ),
          ),

          // 📝 Students list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('academies')
                  .doc(widget.academyUid)
                  .collection('students')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No students found."));
                }

                final students = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final data = student.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown';

                    // ✅ Safe attendance read (prevents _TypeError)
                    final rawAttendance = data['attendance'];
                    final attendance =
                        (rawAttendance is Map<String, dynamic>)
                            ? rawAttendance
                            : <String, dynamic>{};

                    final todayStatus = attendance[dateKey] ?? 'absent';

                    final isSelected = selectedStudents.contains(student.id);

                    return Card(
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedStudents.add(student.id);
                            } else {
                              selectedStudents.remove(student.id);
                            }
                          });
                        },
                        title: Text(name, style: AppTheme.subHeading),
                        subtitle: Text("Today: $todayStatus"),
                        secondary: todayStatus == "present"
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.close, color: Colors.red),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
