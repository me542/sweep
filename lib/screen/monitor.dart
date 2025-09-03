import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/navbar.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  double _maxWaterHeight = 0.0;
  double _maxWasteWeight = 0.0;
  int _containerCount = 0;
  int _emergencyCount = 0;

  List<String> _waterRecords = [];
  List<String> _wasteRecords = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadDailyStats();
  }

  Future<void> _loadDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedDateStr = _selectedDay!.toIso8601String().split('T')[0];

    _waterRecords = prefs.getStringList('waterHistory_$selectedDateStr') ?? [];
    _wasteRecords = prefs.getStringList('wasteHistory_$selectedDateStr') ?? [];
    _emergencyCount = prefs.getInt('emergency_$selectedDateStr') ?? 0;
    _containerCount = prefs.getInt('container_$selectedDateStr') ?? 0;

    double maxWater = 0.0;
    for (var w in _waterRecords) {
      final val = double.tryParse(w) ?? 0.0;
      if (val > maxWater) maxWater = val;
    }

    double maxWaste = 0.0;
    for (var w in _wasteRecords) {
      final val = double.tryParse(w) ?? 0.0;
      if (val > maxWaste) maxWaste = val;
    }

    setState(() {
      _maxWaterHeight = maxWater;
      _maxWasteWeight = maxWaste;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        backgroundColor: const Color(0xFFB2DAAC),
        foregroundColor: const Color(0xFF06703C),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset(
              'assets/logo1.png',
              height: 60,
              width: 60,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFB2DAAC),
      body: Column(
        children: [
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
              _loadDailyStats();
            },
            availableCalendarFormats: const {CalendarFormat.month: ''},
            daysOfWeekVisible: false,
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
          Expanded(
            child: _selectedDay == null
                ? const Center(
              child: Text(
                "Select a date to view details.",
                style: TextStyle(color: Color(0xFF91EAAF)),
              ),
            )
                : _buildSummaryCircles(),
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildSummaryCircles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircleCard("Water", _maxWaterHeight.toStringAsFixed(1), Colors.blue, Icons.water_drop),
              _buildCircleCard("Waste", _maxWasteWeight.toStringAsFixed(1), Colors.brown, Icons.delete),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircleCard("Container", _containerCount.toString(), Colors.green, Icons.inbox),
              _buildCircleCard("Emergency", _emergencyCount.toString(), Colors.red, Icons.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCard(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
