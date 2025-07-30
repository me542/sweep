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
                      text: '$title\n\n',
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
      backgroundColor: const Color(0xFFB0E8B3),
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
                  'User Manual',
                  '- Step 1\n- Step 2\n- Step 3',
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
                  'This app was created to support smart watering using SWEEP technology.\n\nVersion: 1.0.0\nAuthor: Your Name',
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
