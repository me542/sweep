import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweep/hive&web/hive.dart'; // Import your HiveService
import '../screen/profile.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfile;
  final double logoSize;
  final double iconSize;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showProfile = true,
    this.logoSize = 100.0,
    this.iconSize = 50.0,
    this.height = 140.0,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    // First try loading from Hive
    String? path = HiveService.getProfileImagePath();

    // If not available in Hive, try SharedPreferences
    if (path == null || !File(path).existsSync()) {
      final prefs = await SharedPreferences.getInstance();
      path = prefs.getString('profile_image');
    }

    // Update state only if the file exists
    if (path != null && File(path).existsSync()) {
      if (mounted) {
        setState(() {
          _imagePath = path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset(
              'assets/logo1.png',
              width: widget.logoSize,
              height: widget.logoSize,
              fit: BoxFit.contain,
            ),

            // Title
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Profile Icon or Avatar
            if (widget.showProfile)
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                  _loadProfileImage(); // Reload profile after return
                },
                child: _imagePath != null && File(_imagePath!).existsSync()
                    ? CircleAvatar(
                  backgroundImage: FileImage(File(_imagePath!)),
                  radius: widget.iconSize / 2,
                )
                    : Icon(
                  Icons.person,
                  size: widget.iconSize,
                  color: const Color(0xFF06703C),
                ),
              )
            else
              const SizedBox(width: 60), // Maintain layout spacing
          ],
        ),
      ),
    );
  }
}
