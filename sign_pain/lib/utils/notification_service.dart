import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // fixed ID for rolling tracking reminder
  static const int rollingReminderId = 999;

  Future<void> scheduleRollingPainReminder() async {
    // cancel any previously scheduled alarms
    await _notificationsPlugin.cancel(id: rollingReminderId);

    // schedule to exactly 4 hours after now
    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(hours: 4));

    await _notificationsPlugin.zonedSchedule(
      id: rollingReminderId,
      title: 'Como se está a sentir? 🩺',
      body: 'Atualize o seu estado de dor agora.',
      scheduledDate: scheduledTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'rolling_reminders_channel',
          'Acompanhamento de Dor',
          channelDescription: 'Alerta disparado x horas após o último registo',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
    );
  }

  Future<void> requestNotificationPermissions() async {
    // Target the Android-specific implementation of the plugin
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // This triggers the official Android 13+ "Allow notifications?" dialog
      await androidPlugin.requestNotificationsPermission();
    }
  }
}