import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academynew1/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  final String academyUid;
  const HomePage({super.key, required this.academyUid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime today = DateTime.now();

  String get todayKey =>
      "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

  // 🔹 Get total students
  Future<int> _getTotalStudents() async {
    final snapshot = await _firestore
        .collection("academies")
        .doc(widget.academyUid)
        .collection("students")
        .get();
    return snapshot.size;
  }

  // 🔹 Get fees summary from subcollection
  Future<Map<String, int>> _getFeesSummary() async {
    final studentsSnapshot = await _firestore
        .collection("academies")
        .doc(widget.academyUid)
        .collection("students")
        .get();

    int paid = 0;
    int unpaid = 0;

    for (var studentDoc in studentsSnapshot.docs) {
      final feesSnapshot = await studentDoc.reference.collection("fees").get();

      for (var feeDoc in feesSnapshot.docs) {
        final data = feeDoc.data();
        if (data["status"] == "paid") {
          paid++;
        } else {
          unpaid++;
        }
      }
    }

    return {"paid": paid, "unpaid": unpaid};
  }

  // 🔹 Get today’s attendance
  Future<Map<String, int>> _getTodayAttendance() async {
    final studentsSnapshot = await _firestore
        .collection("academies")
        .doc(widget.academyUid)
        .collection("students")
        .get();

    int present = 0;
    int absent = 0;

    for (var studentDoc in studentsSnapshot.docs) {
      final data = studentDoc.data();
      final attendance =
          (data["attendance"] ?? {}) as Map<String, dynamic>? ?? {};
      final status = attendance[todayKey] ?? "absent";
      if (status == "present") {
        present++;
      } else {
        absent++;
      }
    }

    return {"present": present, "absent": absent};
  }

  // 🔹 Get upcoming schedules
  Stream<QuerySnapshot> _getSchedules() {
    return _firestore
        .collection("academies")
        .doc(widget.academyUid)
        .collection("schedules")
        .orderBy("date", descending: false)
        .limit(5)
        .snapshots();
  }

  // 🔹 Get shares
  Stream<QuerySnapshot> _getShares() {
    return _firestore
        .collection("academies")
        .doc(widget.academyUid)
        .collection("share")
        .snapshots();
  }

  // 🔹 Card Widget
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    Color color = Colors.blue,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.subHeading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Academy Dashboard"),
      //   backgroundColor: AppTheme.primaryColor,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(height: 50),
            // ✅ Total Students
            FutureBuilder<int>(
              future: _getTotalStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return _buildCard(
                  icon: Icons.people,
                  title: "Total Students",
                  value: snapshot.data.toString(),
                  color: Colors.blue,
                );
              },
            ),

            const SizedBox(height: 12),

            // ✅ Fees Summary
            FutureBuilder<Map<String, int>>(
              future: _getFeesSummary(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final data = snapshot.data!;
                return _buildCard(
                  icon: Icons.currency_rupee,
                  title: "Fees Summary",
                  value: "Paid: ${data['paid']} | Unpaid: ${data['unpaid']}",
                  color: Colors.green,
                );
              },
            ),

            const SizedBox(height: 12),

            // ✅ Today’s Attendance
            FutureBuilder<Map<String, int>>(
              future: _getTodayAttendance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final data = snapshot.data!;
                return _buildCard(
                  icon: Icons.check_circle,
                  title: "Today’s Attendance",
                  value:
                      "Present: ${data['present']} | Absent: ${data['absent']}",
                  color: Colors.orange,
                );
              },
            ),

            const SizedBox(height: 12),

            // ✅ Upcoming Schedules
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upcoming Schedules",
                      style: AppTheme.subHeading.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _getSchedules(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Text("No upcoming schedules.");
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};
                            return ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text(data["title"] ?? "Untitled"),
                              subtitle: Text(
                                (data["date"] ?? "").toString(),
                              ), // format date later
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Share Info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Share Info",
                      style: AppTheme.subHeading.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _getShares(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Text("No share info available.");
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};
                            return ListTile(
                              leading: const Icon(
                                Icons.share,
                                color: Colors.blue,
                              ),
                              title: Text(data["title"] ?? "No title"),
                              subtitle: Text(data["link"] ?? ""),
                              onTap: () {
                                // open link later
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
