import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await plugin.initialize(settings: settings);
  }

  static Future<void> showHabitReminder(String habitName, DateTime time) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _plugin.zonedSchedule(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Habit Reminder',
      body: 'Time to complete: $habitName',
      scheduledDate: tz.TZDateTime.from(time, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> showMoodReminder() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mood_channel',
          'Mood Reminders',
          importance: Importance.low,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'How are you feeling?',
      body: 'Don\'t forget to log your mood today',
      notificationDetails: details,
    );
  }
}

