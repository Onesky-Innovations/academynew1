import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academynew1/theme/app_theme.dart';

class EditSchedulePage extends StatefulWidget {
  final String academyUid;
  final String scheduleId;
  final Map<String, dynamic> existingData;

  const EditSchedulePage({
    super.key,
    required this.academyUid,
    required this.scheduleId,
    required this.existingData,
  });

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingData['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingData['description'] ?? '',
    );

    if (widget.existingData['date'] is Timestamp) {
      _selectedDate = (widget.existingData['date'] as Timestamp).toDate();
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _updateSchedule() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      await FirebaseFirestore.instance
          .collection('academies')
          .doc(widget.academyUid)
          .collection('schedules')
          .doc(widget.scheduleId)
          .update({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'date': Timestamp.fromDate(_selectedDate!),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      Navigator.pop(context); // go back to schedule list
    }
  }

  Future<void> _deleteSchedule() async {
    await FirebaseFirestore.instance
        .collection('academies')
        .doc(widget.academyUid)
        .collection('schedules')
        .doc(widget.scheduleId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Schedule"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteSchedule,
          ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.isEmpty ? "Enter title" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? "No date chosen"
                        : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text("Update Schedule"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
