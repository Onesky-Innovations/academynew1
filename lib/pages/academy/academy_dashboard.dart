import 'package:flutter/material.dart';
import 'home_page.dart';
import 'Academy_Students_Pages/students_page.dart';
import 'fees/fees_page.dart';
import 'Schedule/schedule_page.dart';
import 'share_page.dart';

class AcademyDashboard extends StatefulWidget {
  final String academyUid;
  const AcademyDashboard({super.key, required this.academyUid});

  @override
  State<AcademyDashboard> createState() => _AcademyDashboardState();
}

class _AcademyDashboardState extends State<AcademyDashboard> {
  int _currentIndex = 0;

  // Initialize pages using late final to avoid RangeError
  late final List<Widget> _pages = [
    HomePage(academyUid: widget.academyUid),
    StudentsPage(academyUid: widget.academyUid),
    FeesPage(academyUid: widget.academyUid),
    SchedulePage(academyUid: widget.academyUid),
    SharePage(academyUid: widget.academyUid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Academy Dashboard")),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Fees"),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Schedule",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: "Share"),
        ],
      ),
    );
  }
}
