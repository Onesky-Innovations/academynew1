import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academynew1/theme/app_theme.dart';
import 'student_form.dart';
import 'student_details_page.dart';
import 'attendance_page.dart' as attend;
import 'attendance_report_page.dart' as report;

class StudentsPage extends StatefulWidget {
  final String academyUid;
  const StudentsPage({super.key, required this.academyUid});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final CollectionReference _academiesRef = FirebaseFirestore.instance
      .collection('academies');

  DateTime selectedDate = DateTime.now();

  String get dateKey =>
      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

  Future<void> _showAddStudentDialog() async {
    await showDialog(
      context: context,
      builder: (_) => StudentForm(academyUid: widget.academyUid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentCollection = _academiesRef
        .doc(widget.academyUid)
        .collection('students');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddStudentDialog,
                      style: AppTheme.primaryButton.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          AppTheme.primaryColor,
                        ),
                      ),
                      icon: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add Student",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => attend.AttendancePage(
                              academyUid: widget.academyUid,
                              academyId: widget.academyUid,
                            ),
                          ),
                        );
                      },
                      style: AppTheme.secondaryButton.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 2, 131, 190),
                        ),
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add Attendance",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Current Day Attendance
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Attendance (${selectedDate.day}-${selectedDate.month}-${selectedDate.year})",
                  style: AppTheme.heading,
                ),
              ),
              const SizedBox(height: 12),

              // Attendance Summary
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: studentCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final students = snapshot.data!.docs;
                    if (students.isEmpty) {
                      return const Center(
                        child: Text(
                          "No students added yet.",
                          style: AppTheme.subHeading,
                        ),
                      );
                    }

                    int presentCount = 0;
                    int absentCount = 0;

                    final filteredStudents = students.map((s) {
                      final data = s.data() as Map<String, dynamic>;

                      final attendanceRaw = data['attendance'];
                      Map<String, dynamic> attendanceMap = {};
                      if (attendanceRaw != null && attendanceRaw is Map) {
                        attendanceMap = Map<String, dynamic>.from(
                          attendanceRaw,
                        );
                      }

                      final status = attendanceMap[dateKey] ?? 'absent';
                      if (status == 'present') presentCount++;
                      if (status == 'absent') absentCount++;

                      return {...data, 'status': status, 'studentId': s.id};
                    }).toList();

                    final activeStudents = filteredStudents
                        .where((s) => !(s['suspended'] ?? false))
                        .toList();

                    return ListView(
                      children: [
                        Card(
                          color: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Present: $presentCount",
                                  style: AppTheme.subHeading,
                                ),
                                Text(
                                  "Absent: $absentCount",
                                  style: AppTheme.subHeading,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...activeStudents.map((student) {
                          return StudentCard(
                            data: student,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentDetailsPage(
                                    academyUid: widget.academyUid,
                                    studentId: student['studentId'],
                                    studentData: student,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Attendance Report Section
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => report.AttendanceReportPage(
                        academyId: widget.academyUid,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 54, 165, 238),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.calendar_month, color: Colors.white),
                label: const Text(
                  "Attendance Report",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Student Card Widget ---
class StudentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const StudentCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'No Name';
    final initials = name.isNotEmpty
        ? name.split(' ').map((s) => s[0]).join().toUpperCase()
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            initials,
            style: AppTheme.subHeading.copyWith(color: Colors.white),
          ),
        ),
        title: Text(name, style: AppTheme.subHeading),
        subtitle: Text("Status: ${data['status']}"),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textSecondary,
          size: 16,
        ),
      ),
    );
  }
}
