import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  notifications =
  FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings =
    InitializationSettings(
      android: android,
    );

    await notifications.initialize(
      settings,
    );
  }

  static Future showNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'notes_channel',
        'Notes',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await notifications.show(
      0,
      title,
      body,
      details,
    );
  }
}