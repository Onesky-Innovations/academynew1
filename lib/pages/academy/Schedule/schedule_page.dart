import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academynew1/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_schedule_page.dart';
import 'edit_schedule_page.dart';

class SchedulePage extends StatefulWidget {
  final String academyUid;
  const SchedulePage({super.key, required this.academyUid});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool showCalendar = false;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('academies')
            .doc(widget.academyUid)
            .collection('schedules')
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No schedules found"));
          }

          final schedules = snapshot.data!.docs;

          // 🔹 Build events map for calendar markers
          events.clear();
          for (var doc in schedules) {
            final data = doc.data() as Map<String, dynamic>;
            final dateField = data['date'];
            DateTime? date;
            if (dateField is Timestamp) {
              date = dateField.toDate();
            } else if (dateField is String) {
              try {
                date = DateTime.parse(dateField);
              } catch (_) {}
            }
            if (date != null) {
              final day = DateTime(date.year, date.month, date.day);
              events.putIfAbsent(day, () => []).add({...data, 'id': doc.id});
            }
          }

          if (showCalendar) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      showCalendar ? Icons.list : Icons.calendar_today,
                    ),
                    onPressed: () {
                      setState(() => showCalendar = !showCalendar);
                    },
                  ),
                ),
                TableCalendar(
                  focusedDay: focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  eventLoader: (day) {
                    return events[DateTime(day.year, day.month, day.day)] ?? [];
                  },
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    // remove markerDecoration since we will use custom builders
                    markersMaxCount: 1,
                  ),

                  // ✅ Custom marker with icon
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return const Icon(
                          Icons.schedule, // 📅 schedule icon
                          size: 16,
                          color: Colors.blue, // same color as before
                        );
                      }
                      return null;
                    },
                  ),

                  // Only month view
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...events[DateTime(
                            selectedDay?.year ?? focusedDay.year,
                            selectedDay?.month ?? focusedDay.month,
                            selectedDay?.day ?? focusedDay.day,
                          )] ??
                          [],
                    ].map((data) => buildScheduleCard(data)).toList(),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      showCalendar ? Icons.list : Icons.calendar_today,
                    ),
                    onPressed: () {
                      setState(() => showCalendar = !showCalendar);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final data = schedule.data() as Map<String, dynamic>;
                      data['id'] = schedule.id;
                      return buildScheduleCard(data);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSchedulePage(academyUid: widget.academyUid),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildScheduleCard(Map<String, dynamic> data) {
    final title = data['title'] ?? "Untitled";
    final desc = data['description'] ?? "";
    final place = data['place'] ?? "";
    final time = data['time'] ?? "";
    final link = data['link'] ?? "";

    // Safe date handling
    DateTime? date;
    final dateField = data['date'];
    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is String) {
      try {
        date = DateTime.parse(dateField);
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (desc.isNotEmpty) Text(desc),
            if (place.isNotEmpty) Text("📍 $place"),
            if (date != null)
              Text("📅 ${date.day}-${date.month}-${date.year}  ⏰ $time"),
            if (link.isNotEmpty) Text("🔗 $link"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditSchedulePage(
                  academyUid: widget.academyUid,
                  scheduleId: data['id'],
                  existingData: data,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
