import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String academyUid;
  const HomePage({super.key, required this.academyUid});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Home Page\nAcademy ID: $academyUid",
        textAlign: TextAlign.center,
      ),
    );
  }
}
