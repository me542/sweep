import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Track last sent range index (instead of exact value)
  static int? _lastWaterRange;
  static int? _lastWasteRange;

  /// Initialize notification system and request permission
  static Future<void> init() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isRestricted) {
      await Permission.notification.request();
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);
  }

  /// Determine which range the level falls into
  static int _getRange(int level) {
    if (level >= 100) return 4;
    if (level >= 75) return 3;
    if (level >= 50) return 2;
    if (level >= 25) return 1;
    return 0; // below 25 → no notif
  }

  /// Show water level notification (trigger only once per range)
  static Future<void> showWaterLevelNotification(int level) async {
    int currentRange = _getRange(level);
    if (currentRange == 0 || _lastWaterRange == currentRange) return;
    _lastWaterRange = currentRange;

    String title = 'Water Level Status';
    String body = '';

    switch (currentRange) {
      case 1:
        body = 'Water level is at 25%. Please monitor closely.';
        break;
      case 2:
        body = 'Water level is at 50%. Normal range.';
        break;
      case 3:
        body = 'Water is at 75%. Tank filling efficiently.';
        break;
      case 4:
        body = '⚠ Water level is 100%. Overflow risk.';
        break;
      default:
        return;
    }

    final androidDetails = AndroidNotificationDetails(
      'water_channel',
      'Water Level Alerts',
      channelDescription: 'Notifications when water reaches certain levels.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    await _notificationsPlugin.show(
      currentRange, // use range as ID
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// Show waste weight notification (trigger once per range)
  static Future<void> showWasteLevelNotification(int percent) async {
    int currentRange = _getRange(percent);
    if (currentRange == 0 || _lastWasteRange == currentRange) return;
    _lastWasteRange = currentRange;

    String title = 'Waste Weight Status';
    String body = '';

    switch (currentRange) {
      case 1:
        body = 'Waste container is 25% full. Continue safely.';
        break;
      case 2:
        body = 'Waste container is 50% full. Plan to empty soon.';
        break;
      case 3:
        body = 'Waste container is 75% full. Prepare for disposal.';
        break;
      case 4:
        body = '⚠ Waste container is 100% full! Warning.';
        break;
      default:
        return;
    }

    final androidDetails = AndroidNotificationDetails(
      'waste_channel',
      'Waste Level Alerts',
      channelDescription: 'Notifications when waste reaches certain levels.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    await _notificationsPlugin.show(
      currentRange + 1000, // separate ID from water
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// 🚨 Emergency / malfunction notification
  static Future<void> showEmergencyNotification() async {
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
      'ESP32 reported a malfunction! Immediate attention required.',
      NotificationDetails(android: androidDetails),
    );
  }
}
