import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFeeDialog extends StatefulWidget {
  final String academyUid;
  final String studentId;
  final String studentName;

  const StudentFeeDialog({
    super.key,
    required this.academyUid,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentFeeDialog> createState() => _StudentFeeDialogState();
}

class _StudentFeeDialogState extends State<StudentFeeDialog> {
  TextEditingController payController = TextEditingController();
  bool isPaying = false;

  @override
  Widget build(BuildContext context) {
    final feesRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(widget.academyUid)
        .collection("fees")
        .where('studentId', isEqualTo: widget.studentId);

    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Student Info
            Text(
              widget.studentName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("ID: ${widget.studentId}"),
            const Divider(),

            // Fee Info
            StreamBuilder<QuerySnapshot>(
              stream: feesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final fees = snapshot.data!.docs;
                if (fees.isEmpty) {
                  return const Text("No fees found for this student.");
                }

                double thisMonthFee = 0;
                double thisMonthPaid = 0;
                double totalDue = 0;
                List<Map<String, dynamic>> pendingFees = [];

                for (var doc in fees) {
                  final data = doc.data() as Map<String, dynamic>;
                  final month = data['month'] ?? "";
                  final amount = (data['amount'] ?? 0).toDouble();
                  final paid = (data['paidAmount'] ?? 0).toDouble();
                  final balance = amount - paid;

                  if (month == currentMonth) {
                    thisMonthFee = amount;
                    thisMonthPaid = paid;
                  }

                  if (balance > 0) {
                    pendingFees.add({
                      'month': month,
                      'amount': amount,
                      'paid': paid,
                      'balance': balance,
                      'docRef': doc.reference,
                    });
                  }

                  totalDue += balance;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This Month Fee
                    Text("This Month Fee: ₹$thisMonthFee"),
                    Text("Paid: ₹$thisMonthPaid"),
                    Text("Balance: ₹${thisMonthFee - thisMonthPaid}"),
                    const SizedBox(height: 8),

                    // Pending / Overdue Fees
                    if (pendingFees.isNotEmpty)
                      ExpansionTile(
                        title: Text(
                          "Pending / Overdue (${pendingFees.length})",
                        ),
                        children: pendingFees.map((f) {
                          return ListTile(
                            title: Text("Month: ${f['month']}"),
                            subtitle: Text(
                              "Amount: ₹${f['amount']} | Paid: ₹${f['paid']} | Balance: ₹${f['balance']}",
                            ),
                          );
                        }).toList(),
                      ),

                    const Divider(),

                    // Pay Fee Section
                    TextField(
                      controller: payController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Pay Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: isPaying
                          ? null
                          : () async {
                              final payValue = double.tryParse(
                                payController.text,
                              );
                              if (payValue == null || payValue <= 0) return;

                              setState(() => isPaying = true);

                              // Safely find this month's fee
                              QueryDocumentSnapshot? thisMonthDoc;
                              try {
                                thisMonthDoc = fees.firstWhere((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return (data['month'] ?? "") == currentMonth;
                                });
                              } catch (_) {
                                thisMonthDoc = null;
                              }

                              if (thisMonthDoc != null) {
                                final data =
                                    thisMonthDoc.data() as Map<String, dynamic>;
                                final currentPaid = (data['paidAmount'] ?? 0)
                                    .toDouble();

                                await thisMonthDoc.reference.update({
                                  'paidAmount': currentPaid + payValue,
                                  'lastPaidAt': Timestamp.now(),
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("This month fee not found."),
                                  ),
                                );
                              }

                              setState(() {
                                isPaying = false;
                                payController.clear();
                              });
                            },
                      child: Text(isPaying ? "Processing..." : "Pay Fee"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
