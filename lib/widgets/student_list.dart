// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentList extends StatelessWidget {
//   final String academyUid;
//   final String filterMode;
//   final String searchQuery;
//   final bool sortAsc;

//   const StudentList({
//     super.key,
//     required this.academyUid,
//     required this.filterMode,
//     required this.searchQuery,
//     required this.sortAsc,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final studentsRef = FirebaseFirestore.instance
//         .collection("academies")
//         .doc(academyUid)
//         .collection("students");

//     return StreamBuilder<QuerySnapshot>(
//       stream: studentsRef.snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return const Center(child: CircularProgressIndicator());

//         List<QueryDocumentSnapshot> students = snapshot.data!.docs;

//         // Apply search filter
//         if (searchQuery.isNotEmpty) {
//           students = students.where((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             final name = (data['name'] ?? "").toString().toLowerCase();
//             return name.contains(searchQuery.toLowerCase());
//           }).toList();
//         }

//         if (students.isEmpty) {
//           return const Center(
//             child: Text(
//               "No students found",
//               style: TextStyle(color: Colors.white70),
//             ),
//           );
//         }

//         // Sort students alphabetically
//         students.sort((a, b) {
//           final nameA = (a['name'] ?? "").toString().toLowerCase();
//           final nameB = (b['name'] ?? "").toString().toLowerCase();
//           return sortAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
//         });

//         return ListView.builder(
//           padding: const EdgeInsets.all(8),
//           itemCount: students.length,
//           itemBuilder: (context, index) {
//             final studentDoc = students[index];
//             final data = studentDoc.data() as Map<String, dynamic>;
//             final name = data['name'] ?? "Unnamed";

//             // Fetch fees subcollection for each student
//             return FutureBuilder<QuerySnapshot>(
//               future: studentDoc.reference.collection('fees').get(),
//               builder: (context, feeSnapshot) {
//                 if (!feeSnapshot.hasData) {
//                   return const ListTile(title: Text("Loading fees..."));
//                 }

//                 final feesDocs = feeSnapshot.data!.docs;

//                 double totalAmount = 0, paidAmount = 0;
//                 bool showStudent = filterMode == "all" || filterMode == "total";

//                 final now = DateTime.now();
//                 final startOfWeek = now.subtract(
//                   Duration(days: now.weekday - 1),
//                 );
//                 final endOfWeek = startOfWeek.add(const Duration(days: 6));

//                 for (var feeDoc in feesDocs) {
//                   final fee = feeDoc.data() as Map<String, dynamic>;
//                   final amount = (fee['amount'] ?? 0).toDouble();
//                   final paid = (fee['paidAmount'] ?? 0).toDouble();
//                   totalAmount += amount;
//                   paidAmount += paid;

//                   // Filter logic
//                   switch (filterMode) {
//                     case "paid":
//                       final paidDate = (fee['paidDate'] as Timestamp?)
//                           ?.toDate();
//                       if (paidDate != null &&
//                           paidDate.isAfter(startOfWeek) &&
//                           paidDate.isBefore(endOfWeek)) {
//                         showStudent = true;
//                       }
//                       break;
//                     case "unpaid":
//                       final currMonth =
//                           "${now.year}-${now.month.toString().padLeft(2, '0')}";
//                       if ((amount - paid) > 0 && fee['month'] == currMonth)
//                         showStudent = true;
//                       break;
//                     case "overdue":
//                       final currMonth =
//                           "${now.year}-${now.month.toString().padLeft(2, '0')}";
//                       if ((amount - paid) > 0 && fee['month'] != currMonth)
//                         showStudent = true;
//                       break;
//                   }
//                 }

//                 if (!showStudent) return const SizedBox.shrink();

//                 final balance = totalAmount - paidAmount;

//                 return Card(
//                   color: const Color(0xFF2E2E3C),
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ListTile(
//                     title: Text(
//                       name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Text(
//                       "Paid: ₹${paidAmount.toStringAsFixed(0)} | Balance: ₹${balance.toStringAsFixed(0)}",
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentList extends StatelessWidget {
  final String academyUid;
  final String filterMode;
  final String searchQuery;
  final bool sortAsc;

  const StudentList({
    super.key,
    required this.academyUid,
    required this.filterMode,
    required this.searchQuery,
    required this.sortAsc,
  });

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(academyUid)
        .collection("students");

    return StreamBuilder<QuerySnapshot>(
      stream: studentsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> students = snapshot.data!.docs;

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          students = students.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? "").toString().toLowerCase();
            return name.contains(searchQuery.toLowerCase());
          }).toList();
        }

        if (students.isEmpty) {
          return const Center(
            child: Text(
              "No students found",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        // Sort students alphabetically
        students.sort((a, b) {
          final nameA = (a['name'] ?? "").toString().toLowerCase();
          final nameB = (b['name'] ?? "").toString().toLowerCase();
          return sortAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final studentDoc = students[index];
            final data = studentDoc.data() as Map<String, dynamic>;
            final name = data['name'] ?? "Unnamed";

            return StreamBuilder<QuerySnapshot>(
              // ✅ Stream all fee docs live (no per-call get())
              stream: studentDoc.reference.collection('fees').snapshots(),
              builder: (context, feeSnapshot) {
                if (!feeSnapshot.hasData) {
                  return const ListTile(title: Text("Loading fees..."));
                }

                final feesDocs = feeSnapshot.data!.docs;

                double totalAmount = 0, paidAmount = 0;
                bool showStudent = filterMode == "all" || filterMode == "total";

                final now = DateTime.now();
                final startOfWeek = now.subtract(
                  Duration(days: now.weekday - 1),
                );
                final endOfWeek = startOfWeek.add(const Duration(days: 6));

                for (var feeDoc in feesDocs) {
                  final fee = feeDoc.data() as Map<String, dynamic>;
                  final amount = (fee['amount'] ?? 0).toDouble();
                  final paid = (fee['paidAmount'] ?? 0).toDouble();
                  totalAmount += amount;
                  paidAmount += paid;

                  // Skip further checks if already matched
                  if (showStudent) continue;

                  switch (filterMode) {
                    case "paid":
                      final paidDate = (fee['paidDate'] as Timestamp?)
                          ?.toDate();
                      if (paidDate != null &&
                          paidDate.isAfter(startOfWeek) &&
                          paidDate.isBefore(endOfWeek)) {
                        showStudent = true;
                      }
                      break;
                    case "unpaid":
                      final currMonth =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}";
                      if ((amount - paid) > 0 && fee['month'] == currMonth) {
                        showStudent = true;
                      }
                      break;
                    case "overdue":
                      final currMonth =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}";
                      if ((amount - paid) > 0 && fee['month'] != currMonth) {
                        showStudent = true;
                      }
                      break;
                  }
                }

                if (!showStudent) return const SizedBox.shrink();

                final balance = totalAmount - paidAmount;

                return Card(
                  color: const Color(0xFF2E2E3C),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Paid: ₹${paidAmount.toStringAsFixed(0)} | Balance: ₹${balance.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
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
