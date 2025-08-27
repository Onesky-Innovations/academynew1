import 'package:academynew1/widgets/student_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'student_list.dart';

class FeesPage extends StatefulWidget {
  final String academyUid;
  const FeesPage({super.key, required this.academyUid});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  String searchQuery = "";
  bool sortAsc = true;
  String filterMode = "all"; // "all", "paid", "unpaid", "overdue"

  @override
  Widget build(BuildContext context) {
    final feesRef = FirebaseFirestore.instance
        .collection("academies")
        .doc(widget.academyUid)
        .collection("fees");

    return Column(
      children: [
        // =======================
        // 🔹 Top Summary Cards
        // =======================
        StreamBuilder<QuerySnapshot>(
          stream: feesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final fees = snapshot.data!.docs;
            final now = DateTime.now();
            final currentMonth =
                "${now.year}-${now.month.toString().padLeft(2, '0')}";

            double total = 0;
            double paid = 0;
            double unpaid = 0;
            double overdue = 0;

            for (var doc in fees) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['amount'] ?? 0).toDouble();
              final paidAmount = (data['paidAmount'] ?? 0).toDouble();
              final balance = amount - paidAmount;
              final month = data['month'] ?? "";

              total += amount;
              paid += paidAmount;

              if (balance > 0) {
                if (month == currentMonth) {
                  unpaid += balance;
                } else {
                  overdue += balance;
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildSummaryCard("💰 Paid", paid, Colors.green, "paid"),
                  _buildSummaryCard("❌ Unpaid", unpaid, Colors.red, "unpaid"),
                  _buildSummaryCard(
                    "⚠️ Overdue",
                    overdue,
                    Colors.orange,
                    "overdue",
                  ),
                  _buildSummaryCard("📊 Total", total, Colors.blue, "all"),
                ],
              ),
            );
          },
        ),

        // =======================
        // 🔍 Search + Sort Bar
        // =======================
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search students...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value.toLowerCase());
                  },
                ),
              ),
              IconButton(
                icon: Icon(sortAsc ? Icons.sort_by_alpha : Icons.sort),
                onPressed: () {
                  setState(() => sortAsc = !sortAsc);
                },
              ),
            ],
          ),
        ),

        // =======================
        // 📋 Students List
        // =======================
        Expanded(
          child: StudentList(
            academyUid: widget.academyUid,
            filterMode: filterMode,
            searchQuery: searchQuery,
            sortAsc: sortAsc,
          ),
        ),
      ],
    );
  }

  // 🔹 Summary Card Widget
  Widget _buildSummaryCard(
    String title,
    double value,
    Color color,
    String mode,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => filterMode = mode);
        },
        child: Card(
          color: filterMode == mode
              ? color.withOpacity(0.2)
              : color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${value.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
