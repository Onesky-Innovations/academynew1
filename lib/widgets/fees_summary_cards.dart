// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FeesSummaryCards extends StatelessWidget {
//   final String academyUid;

//   const FeesSummaryCards({super.key, required this.academyUid});

//   @override
//   Widget build(BuildContext context) {
//     final feesRef = FirebaseFirestore.instance
//         .collection("academies")
//         .doc(academyUid)
//         .collection("students");

//     return StreamBuilder<QuerySnapshot>(
//       stream: feesRef.snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         int totalPaid = 0;
//         int totalUnpaid = 0;

//         for (var studentDoc in snapshot.data!.docs) {
//           final studentFees = studentDoc.reference.collection("fees");

//           // ⚡ We’ll use FutureBuilder here if needed in expanded usage
//           // For summary, you might want to restructure this to query fees once
//         }

//         // Example static summary (you should expand with actual fees calculation)
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildCard("Total Paid", totalPaid, Colors.green),
//             _buildCard("Total Unpaid", totalUnpaid, Colors.red),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCard(String title, int value, Color color) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: 160,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "₹$value",
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
