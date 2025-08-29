import 'package:academynew1/widgets/enter_fee_dialog.dart';
import 'package:academynew1/widgets/student_filter_dialog.dart';
import 'package:academynew1/widgets/student_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../widgets/student_list.dart';
// import '../widgets/enter_fee_dialog.dart';
// import '../widgets/student_filter_dialog.dart';

class FeesPage extends StatefulWidget {
  final String academyUid;
  const FeesPage({super.key, required this.academyUid});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  String? selectedCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildSummaryCard("Paid (This Week)", "paid"),
                _buildSummaryCard("Unpaid (This Month)", "unpaid"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildSummaryCard("Overdue", "overdue"),
                _buildSummaryCard("Total", "total"),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                switch (selectedCard) {
                  case "paid":
                    return Column(
                      children: [
                        _buildPaidTotal(),
                        Expanded(
                          child: StudentList(
                            academyUid: widget.academyUid,
                            filterMode: "paid",
                            searchQuery: "",
                            sortAsc: true,
                          ),
                        ),
                      ],
                    );
                  case "unpaid":
                    return StudentList(
                      academyUid: widget.academyUid,
                      filterMode: "unpaid",
                      searchQuery: "",
                      sortAsc: true,
                    );
                  case "overdue":
                    return StudentList(
                      academyUid: widget.academyUid,
                      filterMode: "overdue",
                      searchQuery: "",
                      sortAsc: true,
                    );
                  case "total":
                    return Column(
                      children: [
                        _buildTotalSummary(),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => StudentFilterDialog(
                                academyUid: widget.academyUid,
                              ),
                            );
                          },
                          child: const Text("Show Students"),
                        ),
                      ],
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEnterFeeDialog,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.payment),
        label: const Text("Enter Fee"),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String key) {
    final isSelected = selectedCard == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCard = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E3C),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaidTotal() {
    final studentsRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(widget.academyUid)
        .collection("students");

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return FutureBuilder<QuerySnapshot>(
      future: studentsRef.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        double totalPaid = 0;
        final docs = snapshot.data!.docs;
        return FutureBuilder(
          future: Future.wait(
            docs.map((doc) async {
              final feesSnapshot = await doc.reference
                  .collection('fees')
                  .where('status', isEqualTo: 'paid')
                  .get();
              for (var feeDoc in feesSnapshot.docs) {
                final data = feeDoc.data();
                final paidDate = (data['paidDate'] as Timestamp?)?.toDate();
                if (paidDate != null &&
                    paidDate.isAfter(weekStart) &&
                    paidDate.isBefore(weekEnd)) {
                  totalPaid += (data['paidAmount'] ?? 0).toDouble();
                }
              }
            }).toList(),
          ),
          builder: (context, snapshot2) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Total Paid This Week: ₹${totalPaid.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalSummary() {
    final studentsRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(widget.academyUid)
        .collection("students");

    return StreamBuilder<QuerySnapshot>(
      stream: studentsRef.snapshots(),
      builder: (context, studentSnapshot) {
        if (!studentSnapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        double totalPaid = 0;
        double totalBalance = 0;

        final studentDocs = studentSnapshot.data!.docs;
        if (studentDocs.isEmpty) return const SizedBox.shrink();

        return FutureBuilder(
          future: Future.wait(
            studentDocs.map((studentDoc) async {
              final feesSnapshot = await studentDoc.reference
                  .collection('fees')
                  .get();
              for (var feeDoc in feesSnapshot.docs) {
                final feeData = feeDoc.data();
                final amount = (feeData['amount'] ?? 0).toDouble();
                final paid = (feeData['paidAmount'] ?? 0).toDouble();
                totalPaid += paid;
                totalBalance += (amount - paid);
              }
            }).toList(),
          ),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    "Total Paid: ₹${totalPaid.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total Balance: ₹${totalBalance.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openEnterFeeDialog() {
    showDialog(
      context: context,
      builder: (_) => EnterFeeDialog(academyUid: widget.academyUid),
    );
  }
}
