import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academynew1/theme/app_theme.dart';

class AddSchedulePage extends StatefulWidget {
  final String academyUid;
  const AddSchedulePage({super.key, required this.academyUid});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _placeController = TextEditingController();
  final _linkController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      await FirebaseFirestore.instance
          .collection('academies')
          .doc(widget.academyUid)
          .collection('schedules')
          .add({
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'place': _placeController.text.trim(),
            'link': _linkController.text.trim(),
            'date': Timestamp.fromDate(_selectedDate!),
            'time': _selectedTime!.format(context),
            'createdAt': FieldValue.serverTimestamp(),
          });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Schedule"),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Program / Title"),
                validator: (v) => v == null || v.isEmpty ? "Enter title" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Small Description",
                ),
                maxLines: 2,
              ),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: "Place"),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _selectedTime == null
                        ? "No time chosen"
                        : _selectedTime!.format(context),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text("Pick Time"),
                  ),
                ],
              ),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: "External Link (optional)",
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text("Save Schedule"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
