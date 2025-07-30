import 'package:flutter/material.dart';
import '../widget/navbar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFFA8E6A1),
        foregroundColor: const Color(0xFF06703C),
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
          color: Color(0xFFA8E6A1), // 💡 Light green background
          // You could also use a gradient or image here
          // gradient: LinearGradient(colors: [Color(0xFFB2FF59), Color(0xFFDCEDC8)])
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text("Sensor 1 has reached the maximum waste level."),
              ),
              ListTile(
                leading: Icon(Icons.water_drop, color: Colors.blue),
                title: Text("Water tank level is at 50%."),
              ),
              ListTile(
                leading: Icon(Icons.build, color: Colors.orange),
                title: Text("Scheduled maintenance due tomorrow."),
              ),
              ListTile(
                leading: Icon(Icons.eco, color: Colors.green),
                title: Text("Soil moisture below threshold."),
              ),
              ListTile(
                leading: Icon(Icons.cloud, color: Colors.grey),
                title: Text("Weather update: Rain expected tonight."),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
