import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_fee_dialog.dart';

class StudentList extends StatelessWidget {
  final String academyUid;
  final String filterMode; // "all", "paid", "unpaid", "overdue"
  final String searchQuery;
  final bool sortAsc;

  const StudentList({
    super.key,
    required this.academyUid,
    this.filterMode = "all",
    this.searchQuery = "",
    this.sortAsc = true,
  });

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(academyUid)
        .collection("students");

    final feesRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(academyUid)
        .collection("fees");

    return StreamBuilder<QuerySnapshot>(
      stream: studentsRef.snapshots(),
      builder: (context, studentSnap) {
        if (!studentSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> students = studentSnap.data!.docs;

        // 🔍 Search filter
        if (searchQuery.isNotEmpty) {
          students = students.where((doc) {
            final name = (doc['name'] ?? '').toString().toLowerCase();
            return name.contains(searchQuery.toLowerCase());
          }).toList();
        }

        // ↕ Sort
        students.sort((a, b) {
          final nameA = (a['name'] ?? '').toString().toLowerCase();
          final nameB = (b['name'] ?? '').toString().toLowerCase();
          return sortAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });

        if (students.isEmpty) {
          return const Center(child: Text("No students found"));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: feesRef.snapshots(),
          builder: (context, feeSnap) {
            if (!feeSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final fees = feeSnap.data!.docs;
            final now = DateTime.now();
            final currentMonth =
                "${now.year}-${now.month.toString().padLeft(2, '0')}";

            List<QueryDocumentSnapshot> filteredStudents = [];

            for (var student in students) {
              final studentId = student.id;
              final studentFees = fees
                  .where((f) => (f['studentId'] ?? '') == studentId)
                  .toList();

              bool hasPaid = false;
              bool hasUnpaid = false;
              bool hasOverdue = false;

              for (var fee in studentFees) {
                final data = fee.data() as Map<String, dynamic>;
                final amount = (data['amount'] ?? 0).toDouble();
                final paidAmount = (data['paidAmount'] ?? 0).toDouble();
                final balance = amount - paidAmount;
                final month = data['month'] ?? "";

                if (balance <= 0) {
                  hasPaid = true;
                } else if (month == currentMonth) {
                  hasUnpaid = true;
                } else {
                  hasOverdue = true;
                }
              }

              // Filter by summary mode
              if (filterMode == "all") filteredStudents.add(student);
              if (filterMode == "paid" && hasPaid) {
                filteredStudents.add(student);
              }
              if (filterMode == "unpaid" && hasUnpaid) {
                filteredStudents.add(student);
              }
              if (filterMode == "overdue" && hasOverdue) {
                filteredStudents.add(student);
              }
            }

            if (filteredStudents.isEmpty) {
              return const Center(child: Text("No students found"));
            }

            return ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                final name = student['name'] ?? "Unnamed";
                final studentId = student.id;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(name),
                    subtitle: Text("ID: $studentId"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => StudentFeeDialog(
                          academyUid: academyUid,
                          studentId: studentId,
                          studentName: name,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
