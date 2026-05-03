import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await plugin.initialize(settings);
  }
  
  static Future<void> showHabitReminder(String habitName, DateTime time) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_channel',
      'Habit Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Habit Reminder',
      'Time to complete: $habitName',
      time,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  static Future<void> showMoodReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mood_channel',
      'Mood Reminders',
      importance: Importance.low,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'How are you feeling?',
      'Don\'t forget to log your mood today',
      details,
    );
  }
}