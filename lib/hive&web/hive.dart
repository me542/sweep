import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _boxName = 'profileBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // Save profile image path
  static Future<void> saveProfileImagePath(String path) async {
    final box = await _getBox();
    await box.put('profile_image', path);
  }

  // Get profile image path
  static String? getProfileImagePath() {
    if (!Hive.isBoxOpen(_boxName)) return null;
    final box = Hive.box(_boxName);
    return box.get('profile_image');
  }

  // Save waste max weight
  static Future<void> saveWasteMaxWeight(int weight) async {
    final box = await _getBox();
    await box.put('waste_max', weight);
  }

  // Get waste max weight
  static int getWasteMaxWeight() {
    if (!Hive.isBoxOpen(_boxName)) return 0;
    final box = Hive.box(_boxName);
    return box.get('waste_max', defaultValue: 0);
  }

  // Save water height
  static Future<void> saveWaterHeight(int height) async {
    final box = await _getBox();
    await box.put('water_height', height);
  }

  // Get water height
  static int getWaterHeight() {
    if (!Hive.isBoxOpen(_boxName)) return 0;
    final box = Hive.box(_boxName);
    return box.get('water_height', defaultValue: 0);
  }

  // Optional: Clear all saved data
  static Future<void> clearProfileData() async {
    final box = await _getBox();
    await box.clear();
  }
}
