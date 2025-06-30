import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize notifications and request permissions
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    final iOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // Fallback for iOS < 10
      },
    );

    final settings = InitializationSettings(android: android, iOS: iOS);
    await _notifications.initialize(settings);

    // Timezone initialization
    tz.initializeTimeZones();
  }

  /// Ask user for notification permissions and return result
  static Future<bool> requestPermission() async {
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    // Android grants permission by default
    return true;
  }

  /// Schedule a daily notification at the selected time
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);

    // Determine the first notification time
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(
      Duration(
        days: now.hour > time.hour || (now.hour == time.hour && now.minute >= time.minute) ? 1 : 0,
      ),
    );

    await _notifications.zonedSchedule(
      0, // Notification ID
      'Don’t forget to log your expenses 💸',
      'Keeping track daily helps you stick to your budget.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel the daily reminder if needed
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0); // Same ID as in zonedSchedule
  }
}
