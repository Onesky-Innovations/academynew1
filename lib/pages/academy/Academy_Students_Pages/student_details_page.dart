import 'package:flutter/material.dart';
import 'student_form.dart';

class StudentDetailsPage extends StatelessWidget {
  final String academyUid;
  final String studentId;
  final Map<String, dynamic> studentData;

  const StudentDetailsPage({
    super.key,
    required this.academyUid,
    required this.studentId,
    required this.studentData,
  });

  // --- Compute attendance percentage ---
  double attendancePercentage(Map<String, dynamic>? attendance) {
    if (attendance == null || attendance.isEmpty) return 0;
    int totalDays = attendance.length;
    int presentDays = attendance.values.where((v) => v == 'present').length;
    return totalDays > 0 ? presentDays / totalDays : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isSuspended = studentData['suspended'] as bool? ?? false;
    final attendanceMap = studentData['attendance'] is Map
        ? Map<String, dynamic>.from(studentData['attendance'])
        : <String, dynamic>{};
    final percent = attendancePercentage(attendanceMap);

    final feeAmount = studentData['fee'] ?? 0;
    final feePaid = feeAmount > 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Student Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: isSuspended ? Colors.red : Colors.blue,
              child: Text(
                (studentData['name'] as String?)?.substring(0, 1) ?? '',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Name"),
                      subtitle: Text(studentData['name'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text("School/College"),
                      subtitle: Text(studentData['school'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text("Age"),
                      subtitle: Text("${studentData['age'] ?? 'N/A'}"),
                    ),
                    ListTile(
                      title: const Text("Gender"),
                      subtitle: Text(studentData['gender'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text("Category"),
                      subtitle: Text(studentData['category'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text("Fee"),
                      subtitle: Text(
                        "$feeAmount (${feePaid ? 'Paid' : 'Pending'})",
                      ),
                    ),
                    ListTile(
                      title: const Text("Email"),
                      subtitle: Text(studentData['email'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text("WhatsApp"),
                      subtitle: Text(studentData['whatsapp'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text("Attendance"),
                      subtitle: LinearProgressIndicator(
                        value: percent.clamp(0, 1),
                        color: Colors.green,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    ListTile(
                      title: const Text("Suspended"),
                      subtitle: Text(isSuspended ? "Yes" : "No"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Student"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => StudentForm(
                      academyUid: academyUid,
                      studentId: studentId,
                      studentData: studentData,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
