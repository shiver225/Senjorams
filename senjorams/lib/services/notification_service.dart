import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:senjorams/alarm_ui.dart';
import 'package:senjorams/main.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:senjorams/sleep_ui.dart';
import 'package:senjorams/map_ui.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//no IOS support
class NotificationService{

  static final NotificationService _notificationService =
      NotificationService._internal();
 
  factory NotificationService() {
    return _notificationService;
  }

  static final player = AudioPlayer();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      androidAudioAttributes: AndroidAudioAttributes(
        usage: AndroidAudioUsage.alarm,
      ),
    ));
    await player.setLoopMode(LoopMode.one);
    await player.setVolume(1);
    await player.setAsset('assets/audio/best_alarm.mp3');
    player.play();
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    player.stop();
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};
    if(receivedAction.payload != null){
      log('Payload: $payload');
    }
    
    log(navigatorKey.currentState.toString());
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder:(_) => AlarmScreen(player: player),)
    );
  }


static Future<void> scheduledNotification({
    required final String title,
    required final String body,
    final int id = 0,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool repeat = false,
    required int hour,
    required int minutes,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'high_importance_channel',
        fullScreenIntent: true,
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: NotificationCalendar(
              hour: hour,
              minute: minutes,
              repeats: repeat,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            ),
    );
  }
  static Future<void> cancelScheduledNotification(int id) async{
    await AwesomeNotifications().cancel(id);
  }
  static Future<void> cancelAllScheduledNotification() async{
    await AwesomeNotifications().cancelAll();
  }
}
