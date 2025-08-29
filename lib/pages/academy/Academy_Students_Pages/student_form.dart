import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class StudentForm extends StatefulWidget {
  final String academyUid;
  final String? studentId;
  final Map<String, dynamic>? studentData;

  const StudentForm({
    super.key,
    required this.academyUid,
    this.studentId,
    this.studentData,
  });

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  late TextEditingController _ageController;
  String _gender = "Male";
  late TextEditingController _categoryController;
  late TextEditingController _feeController; // For first month's fee
  late TextEditingController _emailController;
  late TextEditingController _whatsappController;
  bool _suspended = false;

  final CollectionReference _studentsRef = FirebaseFirestore.instance
      .collection('academies');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentData?['name']);
    _schoolController = TextEditingController(
      text: widget.studentData?['school'],
    );
    _ageController = TextEditingController(
      text: widget.studentData?['age']?.toString(),
    );
    _gender = widget.studentData?['gender'] ?? "Male";
    _categoryController = TextEditingController(
      text: widget.studentData?['category'],
    );
    _feeController = TextEditingController(
      text: widget.studentData?['fee']?.toString(),
    );
    _emailController = TextEditingController(
      text: widget.studentData?['email'],
    );
    _whatsappController = TextEditingController(
      text: widget.studentData?['whatsapp'],
    );
    _suspended = widget.studentData?['suspended'] ?? false;
  }

  String _generatePassword() {
    const chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    final password = widget.studentData != null
        ? widget.studentData!['password']
        : _generatePassword();

    final doc = widget.studentId == null
        ? _studentsRef.doc(widget.academyUid).collection('students').doc()
        : _studentsRef
              .doc(widget.academyUid)
              .collection('students')
              .doc(widget.studentId);

    // Save student data without fee
    await doc.set({
      'name': _nameController.text.trim(),
      'school': _schoolController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'gender': _gender,
      'category': _categoryController.text.trim(),
      'email': _emailController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'password': password,
      'suspended': _suspended,
      'attendance': widget.studentData?['attendance'] ?? 0,
    });

    // If adding a new student, create first month's fee in subcollection
    if (widget.studentId == null && _feeController.text.isNotEmpty) {
      final feeAmount = double.tryParse(_feeController.text.trim()) ?? 0.0;
      await doc.collection('fees').add({
        'amount': feeAmount,
        'paidAmount': 0.0,
        'status': 'unpaid',
        'dueDate': DateTime.now().add(
          const Duration(days: 30),
        ), // example next month
        'paidDate': null,
      });
    }

    Navigator.pop(context);

    if (widget.studentId == null) {
      // Show username/password after adding new student
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Student Added"),
          content: Text(
            "Username: ${_emailController.text}\nPassword: $password",
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.studentId == null ? "Add Student" : "Edit Student"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(labelText: "School/College"),
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (val) => _gender = val!,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              // Enter first month's fee only
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(labelText: "First Month Fee"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: "WhatsApp"),
              ),
              Row(
                children: [
                  const Text("Suspended: "),
                  Switch(
                    value: _suspended,
                    onChanged: (val) => setState(() => _suspended = val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _saveStudent,
          child: Text(
            widget.studentId == null ? "Add Student" : "Save Changes",
          ),
        ),
      ],
    );
  }
}
