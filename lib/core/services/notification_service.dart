// notification_service.dart
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
          (int id, String? title, String? body, String? payload) async {},
    );

    final settings = InitializationSettings(android: android, iOS: iOS);
    await _notifications.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
  }

  static Future<bool> requestPermission() async {
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return true;
  }

  static Future<void> scheduleDailyReminder(
    BuildContext context,
    TimeOfDay time,
  ) async {
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
                now.hour > time.hour ||
                    (now.hour == time.hour && now.minute >= time.minute)
                ? 1
                : 0,
          ),
        );

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = isArabic
        ? 'لا تنسى تسجيل مصروفاتك 💸'
        : 'Don’t forget to log your expenses 💸';

    final body = isArabic
        ? 'تتبع المصروفات يوميًا يساعدك في الالتزام بميزانيتك.'
        : 'Keeping track daily helps you stick to your budget.';

    await _notifications.zonedSchedule(
      0,
      title,
      body,
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
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }
}
