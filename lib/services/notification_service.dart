import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  // INITIALIZATION

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    try {
      final String currentTimeZone =
      (await FlutterTimezone.getLocalTimezone()) as String;

      print("Current Timezone: $currentTimeZone");

      tz.setLocalLocation(
        tz.getLocation(currentTimeZone),
      );
    } catch (e) {
      print("Timezone Error: $e");

      tz.setLocalLocation(
        tz.getLocation('UTC'),
      );
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
    );

    final androidPlugin =
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();

    print("Notification Service Initialized");
  }

  // ===============================
  // INSTANT NOTIFICATION
  // ===============================
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'notes_channel',
      'Notes Notifications',
      channelDescription: 'Instant notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // ===============================
  // SCHEDULED REMINDER
  // ===============================
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime tzDate =
      tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      print("================================");
      print("Current Time : ${DateTime.now()}");
      print("Reminder Time: $scheduledDate");
      print("TZ Time      : $tzDate");
      print("================================");

      if (!tzDate.isAfter(
        tz.TZDateTime.now(tz.local),
      )) {
        print("Reminder time is in the past.");
        return;
      }

      const AndroidNotificationDetails
      androidDetails =
      AndroidNotificationDetails(
        'notes_reminder_channel',
        'Note Reminders',
        channelDescription:
        'Reminders before note deadline',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails details =
      NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin
          .zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
        payload: "note_reminder",
      );

      print("Reminder Scheduled Successfully");

      await debugPendingNotifications();
    } catch (e) {
      print("Schedule Error: $e");
    }
  }

  // ===============================
  // CANCEL REMINDER
  // ===============================
  static Future<void> cancelReminder(
      int id) async {
    await flutterLocalNotificationsPlugin
        .cancel(id);

    print("Reminder Cancelled: $id");
  }

  // ===============================
  // DEBUG PENDING NOTIFICATIONS
  // ===============================
  static Future<void>
  debugPendingNotifications() async {
    final pending =
    await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    print(
        "Pending Notifications Count: ${pending.length}");

    for (final item in pending) {
      print("-------------------");
      print("ID: ${item.id}");
      print("TITLE: ${item.title}");
      print("BODY: ${item.body}");
    }
  }

  // ===============================
  // GENERATE UNIQUE ID
  // ===============================
  static int idFromNoteId(
      String noteId,
      ) {
    return noteId.hashCode &
    0x7fffffff;
  }
}