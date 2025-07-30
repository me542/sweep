import 'package:flutter/material.dart';
import 'package:sweep/screen/homescreen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF075E37), Color(0xFFC9DBB2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -250,
              left: -280,
              child: Container(
                height: 800,
                width: 800,
                decoration: BoxDecoration(
                  color: Color(0xFF06703C),
                  borderRadius: BorderRadius.circular(800),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 400),
                  Image.asset(
                    'assets/logo1.png', // ✅ Replace with your image path
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  // Optional: You can add more widgets here
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const homescreen()),
                    );
                  }, // ✅ You missed this comma
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF054120),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black38,
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1,
                      color: Color(0xFFA9EBA4),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
