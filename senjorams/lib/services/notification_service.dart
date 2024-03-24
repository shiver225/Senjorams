import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//no IOS support
class NotificationService{

  static final NotificationService _notificationService =
      NotificationService._internal();
 
  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    _configureLocalTimeZone();
    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    AndroidInitializationSettings initializationSettingsAndroid = 
      const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );

    await notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: 
        (NotificationResponse notificationResponse) async {});
  }

  /// Set right date and time for notifications
  tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone == "Europe/Kiev" ? "Europe/Kyiv" : timeZone)); //needs to be timeZone but error says that Europe/Kiev doesnt exist since it was changed to Europe/Kyiv in 2022
  }

  /// Scheduled Notification
  Future<void> scheduledNotification({
    int id = 0,
    required int hour,
    required int minutes,
    String? title, 
    String? body
    }) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertTime(hour, minutes),
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            channelDescription: "ashwin",
            importance: Importance.max,
            priority: Priority.max),
      ),
      // Type of time interpretation
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,// To show notification even when the app is closed
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint(tz.TZDateTime.now(tz.local).toString());
  }
}
