import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this
import '../widget/appbar.dart';
import '../widget/navbar.dart';

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homescreen> {
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchState();
  }

  // Load saved switch state
  void _loadSwitchState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isStarted = prefs.getBool('switchState') ?? false;
    });
  }

  // Save switch state
  void _saveSwitchState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('switchState', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      bottomNavigationBar: const CustomBottomNavBar(),
      backgroundColor: const Color(0xFFA8E6A1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // START Switch + Fixed Text
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SwitchTheme(
                  data: SwitchThemeData(
                    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.red;
                      }
                      return const Color(0xFF006400);
                    }),
                    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                      return const Color(0xFFCCFFCC);
                    }),
                  ),
                  child: Transform.scale(
                    scale: 1.4,
                    child: Switch(
                      value: _isStarted,
                      onChanged: (value) {
                        setState(() {
                          _isStarted = value;
                        });
                        _saveSwitchState(value); // Save state
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 100),
                Text(
                  _isStarted ? "STOP" : "START",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: _isStarted ? Colors.red : const Color(0xFF006400),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            // Indicators Section
            Opacity(
              opacity: _isStarted ? 1.0 : 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      _buildCircleIndicator(Icons.delete, "0%"),
                      const SizedBox(height: 20),
                      _buildCircleIndicator(Icons.water_drop, "0%"),
                    ],
                  ),
                  Row(
                    children: [
                      _buildVerticalBar(Icons.delete),
                      const SizedBox(width: 20),
                      _buildVerticalBar(Icons.water_drop),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),

            Opacity(
              opacity: _isStarted ? 1.0 : 0.5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Waste Max Weight (kg): 2",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Water Height (ft): 2",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIndicator(IconData icon, String text) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 90,
          width: 90,
          child: CircularProgressIndicator(
            value: 0.0,
            backgroundColor: const Color(0xFF06703C),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 8,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Icon(icon, size: 25, color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalBar(IconData icon) {
    return Container(
      height: 330,
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF06703C), width: 2.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Icon(icon, color: const Color(0xFF06703C)),
        ),
      ),
    );
  }
}

