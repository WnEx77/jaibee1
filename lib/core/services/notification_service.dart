import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

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

    // ✅ iOS permission request
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // ✅ Initialize timezones
    tz.initializeTimeZones();
  }

  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledDate =
        tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ).add(
          Duration(
            days:
                now.isBefore(
                  DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  ),
                )
                ? 0
                : 1,
          ),
        );

    await _notifications.zonedSchedule(
      0,
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
}
