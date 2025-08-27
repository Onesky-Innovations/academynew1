import 'package:flutter/material.dart';

import 'student_fees_page.dart';
import 'student_schedule_page.dart';
import 'student_worklogs_page.dart';
import 'student_profile_page.dart';

class StudentDashboard extends StatefulWidget {
  final String studentUid;
  const StudentDashboard({super.key, required this.studentUid});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabs.addAll([
      StudentProfilePage(),
      StudentFeesPage(),
      StudentSchedulePage(),
      StudentWorklogsPage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Fees"),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Worklogs",
          ),
        ],
      ),
    );
  }
}
