// // lib/utils/fix_attendance_data.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// /// Fixes attendance data for all students in the specified academy.
// /// Converts old int attendance values to a map with today's date as key.
// Future<void> fixAttendanceData(String academyUid) async {
//   final academiesRef = FirebaseFirestore.instance.collection('academies');
//   final studentsRef = academiesRef.doc(academyUid).collection('students');

//   final snapshot = await studentsRef.get();

//   for (final doc in snapshot.docs) {
//     final data = doc.data();
//     var attendance = data['attendance'];

//     // If attendance is not a map, convert it
//     if (attendance is int) {
//       // Create a new map with default date as key
//       final now = DateTime.now();
//       final dateKey =
//           "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

//       final newAttendance = {dateKey: 'present'}; // or 'absent', your choice

//       await studentsRef.doc(doc.id).update({'attendance': newAttendance});
//       print(
//         "Updated attendance for student ${doc.id}: $attendance -> $newAttendance",
//       );
//     }
//   }

//   print("✅ Attendance data fix completed for academy $academyUid");
// }
