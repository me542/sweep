import 'package:flutter/material.dart';

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
              top: -100,
              left: -100,
              child: Container(
                height: 400,
                width: 400,
                decoration: BoxDecoration(
                  color: Color(0xFF06703C),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF054120),
                      ),
                      children: [
                        TextSpan(
                          text: 'S',
                          style: TextStyle(
                            fontSize: 60,
                            letterSpacing: 2,
                          ),
                        ),
                        TextSpan(
                          text: 'WEEP',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // You can add an image/icon here
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(...) or any logic you want
                  },
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
            ),
          ],
        ),
      ),
    );
  }
}
