import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // fixed ID for rolling tracking reminder
  static const int rollingReminderId = 999;

  static const int dailyReminderID = 998;

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

  Future<void> scheduleDailyReminder() async {
    // figure out what time 20:00 is today
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, 
      now.year, 
      now.month, 
      now.day, 
      20,
      0,  
    );

    // if already past 20:00, notifications start tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: dailyReminderID,
      title: 'SignPain',
      body: 'Como está a sua dor hoje? Registe em 1 minuto.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Lembrete Diário',
          icon: 'ic_stat_signpain',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      
      // tell OS to repeat everyday
      matchDateTimeComponents: DateTimeComponents.time, 
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