import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> showSimpleNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'simple_channel_id',
      'Simple Notifications',
      channelDescription: 'Basic notification demo.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Hello!',
      'This is a simple notification.',
      notificationDetails,
    );
  }
}
