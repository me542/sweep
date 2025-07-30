import 'package:flutter/material.dart';
import 'package:sweep/screen/monitor.dart';

import '../screen/homescreen.dart';
import '../screen/notif.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
      decoration: const BoxDecoration(
        color: Color(0xFF06703C), // dark green background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Color(0xFFCCFFCC), size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const homescreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFFCCFFCC), size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonitorPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: Color(0xFFCCFFCC), size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
