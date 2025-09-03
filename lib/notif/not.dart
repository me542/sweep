import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification system and create channels
  static Future<void> init() async {
    // Request permission
    if (await Permission.notification.isDenied ||
        await Permission.notification.isRestricted) {
      await Permission.notification.request();
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // WATER channels
      for (var bucket in [25, 50, 75, 100]) {
        final channel = AndroidNotificationChannel(
          'water_level_$bucket',
          'Water Level $bucket%',
          description: 'Notifies when water is in $bucket% range.',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('level$bucket'),
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      // WASTE channels
      for (var bucket in [25, 50, 75, 100]) {
        final channel = AndroidNotificationChannel(
          'waste_level_$bucket',
          'Waste Level $bucket%',
          description: 'Notifies when waste is in $bucket% range.',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('waste$bucket'),
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      // EMERGENCY channel
      const emergencyChannel = AndroidNotificationChannel(
        'emergency_channel',
        'Emergency Alerts',
        description: 'Critical alerts for malfunction or emergency.',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('emergency'),
      );
      await androidPlugin.createNotificationChannel(emergencyChannel);
    }

    await _notificationsPlugin.initialize(initSettings);
    print('[NotificationService] Notification system initialized.');
  }

  /// Save notification text to SharedPreferences
  static Future<void> _saveNotification(
      String message, int codePoint, String fontFamily, int color) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("notifications") ?? [];

    // Decode existing notifications
    final decoded = saved.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    // Check if this message already exists in history
    bool exists = decoded.any((notif) => notif['message'] == message);

    if (!exists) {
      final notif = jsonEncode({
        "message": message,
        "time": DateTime.now().toIso8601String(),
        "icon": codePoint,
        "fontFamily": fontFamily,
        "color": color,
      });

      saved.add(notif);
      await prefs.setStringList("notifications", saved);
      print('[NotificationService] Saved notification: $message');
    } else {
      print('[NotificationService] Duplicate notification skipped: $message');
    }
  }


  /// 🔔 Water notification for any value in the bucket range
  static Future<void> showWaterLevelNotification(int percent) async {
    int bucket;
    String body;

    if (percent >= 25 && percent <= 49) {
      bucket = 25;
      body = 'Water level is in range 25–49%. Please monitor closely.';
    } else if (percent >= 50 && percent <= 74) {
      bucket = 50;
      body = 'Water level is in range 50–74%. Normal range.';
    } else if (percent >= 75 && percent <= 99) {
      bucket = 75;
      body = 'Water level is in range 75–99%. Tank filling efficiently.';
    } else if (percent >= 100) {
      bucket = 100;
      body = '⚠ Water level is 100%. Overflow risk.';
    } else {
      return; // ignore below 25%
    }

    final androidDetails = AndroidNotificationDetails(
      'water_level_$bucket',
      'Water Level $bucket%',
      channelDescription: 'Water level notification',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    await _notificationsPlugin.show(
      bucket,
      'Water Level Status',
      body,
      NotificationDetails(android: androidDetails),
    );

    // Water notification
    await _saveNotification(
      body,
      Icons.water_drop.codePoint,
      Icons.water_drop.fontFamily!,
      0xFF2196F3, // blue
    );

    print('[NotificationService] Water notification: $percent → level$bucket');
  }

  /// 🔔 Waste notification for any value in the bucket range
  static Future<void> showWasteLevelNotification(int percent) async {
    int bucket;
    String body;

    if (percent >= 25 && percent <= 49) {
      bucket = 25;
      body = 'Waste container is in range 25–49%. Continue safely.';
    } else if (percent >= 50 && percent <= 74) {
      bucket = 50;
      body = 'Waste container is in range 50–74%. Plan to empty soon.';
    } else if (percent >= 75 && percent <= 99) {
      bucket = 75;
      body = 'Waste container is in range 75–99%. Prepare for disposal.';
    } else if (percent >= 100) {
      bucket = 100;
      body = '⚠ Waste container is 100% full! Warning.';
    } else {
      return; // ignore below 25%
    }

    final androidDetails = AndroidNotificationDetails(
      'waste_level_$bucket',
      'Waste Level $bucket%',
      channelDescription: 'Waste level notification',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    await _notificationsPlugin.show(
      bucket + 1000, // unique ID to avoid overlap with Water
      'Waste Status',
      body,
      NotificationDetails(android: androidDetails),
    );

    // Waste notification
    await _saveNotification(
      body,
      Icons.delete.codePoint,
      Icons.delete.fontFamily!,
      0xFFFFA000, // orange
    );

    print('[NotificationService] Waste notification: $percent → level$bucket');
  }

  /// 🚨 Emergency notification
  static Future<void> showEmergencyNotification() async {
    final body = 'ESP32 reported a malfunction! Immediate attention required.';
    final androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Critical alerts for malfunction or emergency.',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      color: const Color(0xFFFF0000),
      enableLights: true,
      enableVibration: true,
    );

    await _notificationsPlugin.show(
      9999,
      '🚨 Emergency Alert',
      body,
      NotificationDetails(android: androidDetails),
    );


    // Emergency notification
    await _saveNotification(
      body,
      Icons.warning.codePoint,
      Icons.warning.fontFamily!,
      0xFFFF0000, // red
    );

    print('[NotificationService] Emergency notification triggered');
  }
}
