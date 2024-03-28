import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senjorams/services/notification_service.dart';

class Alarm{
  List<TimeOfDay> time;
  DateTime activationDate;
  int alarmId;
  bool enabled;
  int linkedAlarmAmm;
  List<String> title;
  List<String> body;
  bool isSelected = false;
  Color cardColor = Colors.white;

  Alarm({
    required this.time,
    required this.alarmId, 
    required this.title, 
    required this.body, 
    this.enabled = true, 
    this.linkedAlarmAmm = 0
    }) : activationDate = DateTime.now();

  Alarm.fromJson(Map<String, dynamic> json)
      : time = json['time'].cast<String>().map((tm) => TimeOfDay(hour: int.parse(tm.split(":")[0]), minute: int.parse(tm.split(":")[1]))).toList().cast<TimeOfDay>(),
        alarmId = json['alarmId'] as int,
        enabled = json['enabled'] as bool,
        title = json['title'].cast<String>(),
        body = json['body'].cast<String>(),
        linkedAlarmAmm = json['linkedAlarmAmm'],
        activationDate = DateTime.parse(json['activationDate'].toString());
  Map<String, dynamic> toJson() => {
        'time': time.map((tm) => '${tm.hour}:${tm.minute}').toList(),
        'alarmId': alarmId,
        'enabled' : enabled,
        'title' : title,
        'body' : body,
        'linkedAlarmAmm' : linkedAlarmAmm,
        'activationDate' : activationDate.toString(),
      };
      
  Future<void> updateScheduledNotification() async{
    if(linkedAlarmAmm == 0){
      DateTime date = DateTime(activationDate.year, activationDate.month, activationDate.day, time[0].hour, time[0].minute);
      if(date.add(const Duration(days: 1)).compareTo(DateTime.now()) < 0){
        enabled = false;
      }
    }
    if(enabled){
      for(int i = 0; i <= linkedAlarmAmm; i++){
        NotificationService().scheduledNotification(id: alarmId+i, hour: time[i].hour, minutes: time[i].minute, title: title[i], body: body[i], component: linkedAlarmAmm == 0 ? DateTimeComponents.dateAndTime : DateTimeComponents.time);
      }
    }
    else{
      for(int i = 0; i <= linkedAlarmAmm; i++){
        await NotificationService().cancelScheduledNotification(alarmId+i);
      }
    }
  }
}