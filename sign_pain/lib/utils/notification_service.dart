import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // fixed ID for rolling tracking reminder
  static const int rollingReminderId = 999;

  Future<void> scheduleRollingPainReminder() async {
    // cancel any previously scheduled alarms
    await _notificationsPlugin.cancel(id: rollingReminderId);

    // schedule to exactly 3 hours after now
    tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(hours: 3));

    if (scheduledTime.hour >= 0 && scheduledTime.hour < 7) {
      // do not allow notifications to land between midnight and 7am, force to 8am
      scheduledTime = tz.TZDateTime(
        scheduledTime.location, 
        scheduledTime.year,     
        scheduledTime.month,    
        scheduledTime.day,      
        8,                      
        0,                      
        0,                      
      );
    }

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
          icon: 'ic_stat_signpain',
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