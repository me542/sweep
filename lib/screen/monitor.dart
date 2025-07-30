import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widget/navbar.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        backgroundColor: const Color(0xFFA8E6A1),
        foregroundColor: Color(0xFF06703C),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset(
              'assets/logo1.png', // 🔁 Replace with your actual logo path
              height: 60,
              width: 60,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFA8E6A1), // ✅ Background color
        ),
        child: Column(
          children: [
            // Calendar Widget
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              availableCalendarFormats: const {
                CalendarFormat.month: '', // 👈 hides the format button
              },
              daysOfWeekVisible: false, // Optional: hides Mon–Sun row
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF91EAAF),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF06703C),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Colors.black),
                weekendTextStyle: TextStyle(color: Colors.red),
                todayTextStyle: TextStyle(color: Colors.white),
                selectedTextStyle: TextStyle(color: Color(0xFF06703C)),
              ),
            ),
            const SizedBox(height: 20),

            // Plain Box Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF06703C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF06703C)),
                ),
                child: _selectedDay == null
                    ? const Center(
                  child: Text(
                    "Select a date to view details.",
                    style: TextStyle(color: Color(0xFF06703C)),
                  ),
                )
                    : Text(
                  "Details for ${_selectedDay!.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(fontSize: 16, color: Color(0xFFA8E6A1)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
