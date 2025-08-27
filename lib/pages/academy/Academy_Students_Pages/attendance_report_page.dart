// lib/pages/academy/attendance_report_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceReportPage extends StatefulWidget {
  final String academyId;

  const AttendanceReportPage({super.key, required this.academyId});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  DateTime? fromDate;
  DateTime? toDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attendance Report",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a date range to view attendance",
                style: TextStyle(color: Colors.blueGrey[600]),
              ),
              const SizedBox(height: 20),

              // ✅ Date Pickers
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: "From",
                      date: fromDate,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      label: "To",
                      date: toDate,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Show Report Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text("Show Report"),
                  onPressed: () {
                    setState(() {}); // refresh UI
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Report List
              Expanded(
                child: (fromDate == null || toDate == null)
                    ? _emptyMessage("Please select a date range")
                    : _buildReportList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Report List (per date → expand to see student details)
  Widget _buildReportList() {
    final start = DateFormat('yyyy-MM-dd').format(fromDate!);
    final end = DateFormat('yyyy-MM-dd').format(toDate!);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('academies')
          .doc(widget.academyId)
          .collection('attendance')
          .orderBy(FieldPath.documentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyMessage("No attendance found");
        }

        final docs = snapshot.data!.docs.where((doc) {
          final id = doc.id; // date as string
          return id.compareTo(start) >= 0 && id.compareTo(end) <= 0;
        }).toList();

        if (docs.isEmpty) {
          return _emptyMessage("No records for selected dates");
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final dateId = docs[index].id;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ExpansionTile(
                title: Text(
                  DateFormat('MMM d, yyyy').format(DateTime.parse(dateId)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('academies')
                        .doc(widget.academyId)
                        .collection('attendance')
                        .doc(dateId)
                        .collection('records')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final records = snapshot.data!.docs;
                      if (records.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No student records"),
                        );
                      }

                      return Column(
                        children: records.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = data['studentName'] ?? "Unknown";
                          final status = data['status'] ?? "absent";

                          return ListTile(
                            leading: Icon(
                              status == "present"
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: status == "present"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(name),
                            trailing: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: status == "present"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Helpers
  Widget _emptyMessage(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.blueGrey[500]),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              date == null ? label : DateFormat('MMM d, yyyy').format(date),
              style: TextStyle(
                fontSize: 15,
                color: date == null
                    ? Colors.blueGrey[400]
                    : Colors.blueGrey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }
}
