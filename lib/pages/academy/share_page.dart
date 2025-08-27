import 'package:flutter/material.dart';

class SharePage extends StatelessWidget {
  final String academyUid;
  const SharePage({super.key, required this.academyUid});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Share Page\nAcademy ID: $academyUid",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
