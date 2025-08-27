// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FeePaymentForm extends StatefulWidget {
//   final String academyUid;
//   final String studentId;
//   final String? studentName;
//   final String? feeDocId; // Nullable for new month fees
//   final String month;
//   final double totalFee;
//   final double paidAmount;

//   const FeePaymentForm({
//     super.key,
//     required this.academyUid,
//     required this.studentId,
//     this.studentName,
//     this.feeDocId,
//     required this.month,
//     required this.totalFee,
//     required this.paidAmount,
//   });

//   @override
//   State<FeePaymentForm> createState() => _FeePaymentFormState();
// }

// class _FeePaymentFormState extends State<FeePaymentForm> {
//   final _formKey = GlobalKey<FormState>();
//   late double _paidAmount;

//   @override
//   void initState() {
//     super.initState();
//     _paidAmount = 0.0; // default input
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: SizedBox(
//         width: 400,
//         height: 300,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Text(
//                   "Pay Fee - ${widget.studentName ?? widget.studentId}",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text("Month: ${widget.month}"),
//                 Text("Total Fee: ₹${widget.totalFee.toStringAsFixed(0)}"),
//                 Text("Already Paid: ₹${widget.paidAmount.toStringAsFixed(0)}"),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Pay Amount",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) return "Enter amount";
//                     final amt = double.tryParse(value);
//                     if (amt == null) return "Invalid number";
//                     final balance = widget.totalFee - widget.paidAmount;
//                     if (amt <= 0 || amt > balance)
//                       return "Enter valid amount (≤ balance)";
//                     return null;
//                   },
//                   onSaved: (value) {
//                     _paidAmount = double.parse(value!);
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       _formKey.currentState!.save();

//                       final feesRef = FirebaseFirestore.instance
//                           .collection('academies')
//                           .doc(widget.academyUid)
//                           .collection('fees');

//                       if (widget.feeDocId == null || widget.feeDocId!.isEmpty) {
//                         // Create new fee doc for this month
//                         await feesRef.add({
//                           'studentId': widget.studentId,
//                           'month': widget.month,
//                           'amount': widget.totalFee,
//                           'paidAmount': _paidAmount,
//                           'payments': [
//                             {'amount': _paidAmount, 'date': DateTime.now()},
//                           ],
//                           'status': _paidAmount >= widget.totalFee
//                               ? 'paid'
//                               : 'partial',
//                         });
//                       } else {
//                         // Update existing fee doc
//                         final docRef = feesRef.doc(widget.feeDocId);
//                         final snapshot = await docRef.get();
//                         if (!snapshot.exists) return;

//                         final data = snapshot.data()!;
//                         final currentPaid = (data['paidAmount'] ?? 0)
//                             .toDouble();
//                         final newPaid = currentPaid + _paidAmount;

//                         await docRef.update({
//                           'paidAmount': newPaid,
//                           'payments': FieldValue.arrayUnion([
//                             {'amount': _paidAmount, 'date': DateTime.now()},
//                           ]),
//                           'status': newPaid >= (data['amount'] ?? 0)
//                               ? 'paid'
//                               : 'partial',
//                         });
//                       }

//                       Navigator.pop(context);
//                     }
//                   },
//                   child: const Text("Submit Payment"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
