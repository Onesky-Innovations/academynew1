import 'package:flutter/material.dart';

class StudentFilterDialog extends StatelessWidget {
  final String academyUid;
  const StudentFilterDialog({super.key, required this.academyUid});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter Students"),
      content: const Text("Implement month/year/custom filter UI here"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
// 