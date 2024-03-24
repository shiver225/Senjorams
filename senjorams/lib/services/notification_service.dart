import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//no IOS support
class NotificationService{
  final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid = 
      const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );

    await notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: 
        (NotificationResponse notificationResponse) async {});
  }

  _notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max)
    );
  }

  Future showNotification({int id = 0, String? title, String? body, String? payLoad}) async{
    return notificationsPlugin.show(id, title, body, await _notificationDetails());
  }
}
