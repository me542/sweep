import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweep/screen/homescreen.dart';
import 'package:sweep/hive&web/hive.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  int wasteMaxWeight = 0;
  int waterHeight = 0;

  final TextEditingController _wasteController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final path = HiveService.getProfileImagePath();
    if (path != null && File(path).existsSync()) {
      setState(() {
        _image = File(path);
      });
    }

    setState(() {
      wasteMaxWeight = HiveService.getWasteMaxWeight();
      waterHeight = HiveService.getWaterHeight();
    });
  }

  Future<void> _saveImageToHive(String path) async {
    await HiveService.saveProfileImagePath(path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path); // ← sync to SharedPreferences
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      await _saveImageToHive(pickedFile.path);
    }
  }

  void _showEditDialog() {
    _wasteController.text = wasteMaxWeight.toString();
    _waterController.text = waterHeight.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await _pickImageFromGallery();
                  Navigator.of(context).pop();
                  _showEditDialog(); // Reopen dialog
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 50, color: Colors.black)
                      : null,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final int? waste = int.tryParse(_wasteController.text);
              final int? water = int.tryParse(_waterController.text);
              if (waste != null && water != null) {
                setState(() {
                  wasteMaxWeight = waste;
                  waterHeight = water;
                });
                HiveService.saveWasteMaxWeight(waste);
                HiveService.saveWaterHeight(water);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      // text: '$title\n\n',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: content),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _wasteController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2DAAC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF06703C)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const homescreen()),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: Image.asset(
              'assets/logo1.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Color(0xFF06703C),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  left: 110,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 40),
                    color: const Color(0xFF06703C),
                    onPressed: _showEditDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 140),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06703C),
              foregroundColor: const Color(0xFFB0E8B3),
              minimumSize: const Size(250, 60),
            ),
            onPressed: () {
              _showInfoDialog(
                context,
                'SWEEP User Manual',
                '''
  The SWEEP User Manual provides a comprehensive guide to operating the SWEEP automated
waste restraint system. Designed with user-friendliness in mind, this manual serves as the
ultimate reference for setting up, operating, and maintaining the device for efficient sewage
waste management.

Overview
  The SWEEP system integrates solar power, automated waste restraint mechanisms, water level
detection, and IoT monitoring technology to address the issue of solid waste accumulation in
sewage systems. Equipped with a solar-powered paddle wheel, water-level-adjustable restraint
mechanism, and a wireless alert system, SWEEP ensures efficient waste collection, prevents
sewage blockage, and promotes environmental sustainability.

Key Features
- Automated Waste Restraint - Adjusts automatically to varying water levels to trap and collect
  solid waste effectively.
- Water Level Monitoring - Continuously measures sewage water height to optimize restraint
  position and prevent overflow.
- Solar-powered Operation - Runs sustainably without reliance on grid electricity.
- Paddle Wheel Flow System - Prevents water stagnation by ensuring continuous water
  movement.
- Waste Level Monitoring - Tracks waste accumulation in real time.
- Notification System - Sends alerts via SMS or app when waste container reaches capacity or
  water level reaches critical height.

Setup Instructions
1. Initial Device Setup
- Place the SWEEP unit securely in the designated sewage inlet or drainage channel.
- Ensure the restraint mechanism is free from obstructions.
- Position the solar panel where it receives maximum sunlight exposure.
- Securely connect all wiring to the control box inside the waterproof housing.
- Verify that the water level sensors are submerged at the correct depth based on site
  conditions.

2. Powering the Device
- Turn the main switch ON.
- Verify that the solar panel indicator light is functioning.
- Wait for the system to initialize (approx. 30-60 seconds).

3. Water Level Calibration
- Open the SWEEP monitoring app or control panel.
- Access the Water Level Settings section.
- Set the Low, Normal, and High water level thresholds according to site requirements.
- Test by manually adjusting the restraint to ensure smooth movement when water levels
  change.

4. App/Notification Setup
- Install the SWEEP monitoring app on your smartphone.
- Connect your device to the SWEEP wireless network (Network Name: SWEEP-Monitor).
- Pair the app with the SWEEP unit using the device code provided in the package.

Safety and Maintenance
Device Care:
- Regularly inspect the restraint mechanism for trapped debris and remove any large
  obstructions.
- Check the solar panel for dirt or leaves and clean with a soft cloth to ensure maximum
  efficiency.
- Inspect the paddle wheel for smooth rotation and lubricate moving parts if needed.
- Ensure wiring connections remain secure and waterproof.
- Test water level sensors monthly to ensure accurate readings.

Operational Safety:
- Do not operate SWEEP during extreme flooding without proper anchoring.
- Wear protective gloves when handling collected waste.
- Avoid tampering with internal electronics while the system is powered on.
''',
              );
            },
            child: const Text(
              'User Manual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06703C),
            foregroundColor: const Color(0xFFB0E8B3),
            minimumSize: const Size(250, 60),
          ),
          onPressed: () {
            _showInfoDialog(
              context,
              'About',
              '''
SWEEP is an automated, solar-powered waste restraint system designed for efficient sewage
management. It combines ESP-based microcontroller technology, smart water level detection,
automated waste collection, and real-time monitoring to prevent blockages and promote cleaner
waterways. By using renewable solar energy, SWEEP operates sustainably while reducing
manual labor and improving environmental protection. Users can track waste levels, receive
alerts, and monitor water conditions directly through the app, ensuring timely maintenance and
uninterrupted operation.

Developed by:
- Gabriel Andrei C. Villanueva
- Keana Riela E. Dela Peña
- Derick John P. Castillo
- Gilianne Felicity C. Manzano
- John Vincent M. Calderon
- Billy Joe R. Rejano

Version: 1.0.0
''',
            );
          },
          child: const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ],
        ),
      ),
    );
  }
}
