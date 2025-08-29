import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EnterFeeDialog extends StatefulWidget {
  final String academyUid;
  const EnterFeeDialog({super.key, required this.academyUid});

  @override
  State<EnterFeeDialog> createState() => _EnterFeeDialogState();
}

class _EnterFeeDialogState extends State<EnterFeeDialog> {
  String searchQuery = "";
  Map<String, dynamic>? selectedStudent;
  String? selectedStudentId;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseFirestore.instance
        .collection('academies')
        .doc(widget.academyUid)
        .collection('students');

    return AlertDialog(
      title: const Text("Enter Fee"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            if (selectedStudent == null)
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Search Student",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) {
                  setState(() => searchQuery = val.toLowerCase());
                },
              ),
            const SizedBox(height: 10),

            if (selectedStudent == null)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: studentsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs.where((doc) {
                      final name =
                          (doc.data() as Map<String, dynamic>)['name'] ?? '';
                      return name.toLowerCase().contains(searchQuery);
                    }).toList();

                    if (docs.isEmpty)
                      return const Center(child: Text("No students found"));

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name']),
                          onTap: () {
                            setState(() {
                              selectedStudent = data;
                              selectedStudentId = docs[index].id;
                              feeController.clear();
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),

            if (selectedStudent != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Student: ${selectedStudent!['name']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedStudent = null;
                            selectedStudentId = null;
                            feeController.clear();
                          });
                        },
                        child: const Text("Change Student"),
                      ),
                      const SizedBox(height: 10),

                      FutureBuilder<QuerySnapshot>(
                        future: studentsRef
                            .doc(selectedStudentId)
                            .collection('fees')
                            .orderBy('dueDate', descending: true)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Center(
                              child: CircularProgressIndicator(),
                            );

                          final fees = snapshot.data!.docs;
                          if (fees.isEmpty) return const Text("No fees found");

                          final lastFee =
                              fees.first.data() as Map<String, dynamic>;
                          final amount = (lastFee['amount'] ?? 0).toDouble();
                          final paid = (lastFee['paidAmount'] ?? 0).toDouble();
                          final balance = amount - paid;
                          final lastPaidDate =
                              (lastFee['paidDate'] as Timestamp?)?.toDate();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Monthly Fee: ₹$amount"),
                              Text(
                                "Last Paid: ${lastPaidDate != null ? DateFormat('dd MMM yyyy').format(lastPaidDate) : 'Not Paid'}",
                              ),
                              Text("Due: ₹$balance"),
                              const SizedBox(height: 10),
                              TextField(
                                controller: feeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Enter Payment Amount",
                                  prefixText: "₹",
                                ),
                              ),
                            ],
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        if (selectedStudent != null)
          ElevatedButton(onPressed: _submitFee, child: const Text("Submit")),
      ],
    );
  }

  Future<void> _submitFee() async {
    if (selectedStudentId == null) return;

    final studentsRef = FirebaseFirestore.instance
        .collection('academies')
        .doc(widget.academyUid)
        .collection('students');

    final feeDocs = await studentsRef
        .doc(selectedStudentId)
        .collection('fees')
        .orderBy('dueDate', descending: false)
        .get();

    double remainingPayment = double.tryParse(feeController.text.trim()) ?? 0;

    if (remainingPayment <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid payment amount")),
      );
      return;
    }

    for (var doc in feeDocs.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final paid = (data['paidAmount'] ?? 0).toDouble();
      final status = data['status'] ?? 'unpaid';

      if (remainingPayment <= 0) break;
      if (status == 'paid') continue;

      double toPay = min(amount - paid, remainingPayment);

      try {
        await doc.reference.update({
          'paidAmount': paid + toPay,
          'status': (paid + toPay >= amount) ? 'paid' : 'partial',
          'paidDate': (paid + toPay >= amount) ? Timestamp.now() : null,
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating fee: $e")));
        return;
      }

      remainingPayment -= toPay;
    }

    // Save extra payment to next month
    if (remainingPayment > 0) {
      final nextMonth = DateTime.now().add(const Duration(days: 30));
      final dueDate = DateTime(nextMonth.year, nextMonth.month, 1);

      await studentsRef.doc(selectedStudentId).collection('fees').add({
        'amount': remainingPayment,
        'paidAmount': remainingPayment,
        'status': 'paid',
        'paidDate': Timestamp.now(),
        'dueDate': Timestamp.fromDate(dueDate),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Extra ₹$remainingPayment saved for next month"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fee submitted successfully")),
      );
    }

    Navigator.pop(context);
  }
}
