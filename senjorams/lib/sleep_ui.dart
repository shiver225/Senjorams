import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:senjorams/main.dart';
import 'package:senjorams/main_screen_ui.dart';
import 'package:senjorams/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';



class Alarm{
  TimeOfDay? time;
  int? alarmId;
  bool enabled;
  bool isSelected = false;
  Color cardColor = Colors.white;
  Alarm({this.time, this.alarmId, this.enabled = true});

  Alarm.fromJson(Map<String, dynamic> json)
      : time = TimeOfDay(hour: int.parse(json['time'].split(":")[0]), minute: int.parse(json['time'].split(":")[1])),
        alarmId = json['alarmId'] as int,
        enabled = json['enabled'] as bool;
  Map<String, dynamic> toJson() => {
        'time': '${time?.hour}:${time?.minute}',
        'alarmId': alarmId,
        'enabled' : enabled,
      };
}
class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final List<bool> _visableSleepSchedual = <bool> [true, false];
  final List<bool> _timeSelection = <bool> [true, false];
  
  List<Alarm> alarmList = [];
  List<Alarm> alarmTrachCan = [];
  TimeOfDay? _selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  TextDirection textDirection = TextDirection.ltr;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Set the login code from the widget parameter when available
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: alarmTrachCan.isEmpty ? 
      AppBar(
        title: const Text('Sleep Tracker'),
      )
      :AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            setState(() {
              alarmTrachCan.clear();
            });
          },
        ),
        title: Text(
          alarmTrachCan.length.toString(), 
          style: const TextStyle(color:Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                alarmList.removeWhere((item) => alarmTrachCan.contains(item));
                //disable alarm
                await _saveData();
                setState(() {alarmTrachCan.clear();});
              },
              icon: const Icon(Icons.delete, color: Colors.white))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: alarmList.length,
                  itemBuilder: (context, index){
                    return Card(
                      color: alarmList[index].cardColor,
                      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        ListTile(
                          selected: alarmTrachCan.contains(alarmList[index]),
                          title: Text(
                            '${alarmList[index].time?.format(context)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Switch(
                            value: alarmList[index].enabled,
                            onChanged: (bool value) async {
                              // This is called when the user toggles the switch.
                              setState(() {
                                alarmList[index].enabled = value;
                              });
                              await _saveData();
                            },
                          ),
                          onTap: alarmTrachCan.isEmpty ? ()=> {} : () => toggleSelection(alarmList[index]),
                          onLongPress: () => toggleSelection(alarmList[index]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(CircleBorder()),
                        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                        backgroundColor: MaterialStateProperty.all(Colors.deepPurple),// <-- Button color
                        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(MaterialState.pressed)) return Colors.deepPurple.shade800; // <-- Splash color
                        }),
                      ),
                      onPressed: () => modalScrollPicker(context),
                      child: const Icon(Icons.add, color: Colors.white, size: 24,)
                    ),
                  ),
    );
  }
  void _loadData() {
    final String? saved = prefs?.getString('alarmList');
    print(saved);
    if(saved != null){
      final List<dynamic> decoded = json.decode(saved);
      alarmList = decoded.map((alarm) => Alarm.fromJson(Map<String, dynamic>.from(alarm))).toList();
    }
  }
  Future<void> _saveData() async {
    final String alarmL = json.encode(alarmList);
    await prefs?.setString('alarmList', alarmL);
  }
  void toggleSelection(Alarm alarm) {
    setState(() {
      if (alarm.isSelected) {
        alarm.cardColor=Colors.white;
        alarm.isSelected = false;
        alarmTrachCan.remove(alarm);
      } else {
        alarm.cardColor=const Color.fromARGB(255, 223, 222, 222);
        alarm.isSelected = true;
        alarmTrachCan.add(alarm);
      }
    });
  }
  

  void modalScrollPicker(BuildContext context){
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState){
        return SizedBox(
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Icon(Icons.clear),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      child: const Icon(Icons.check),
                      onPressed: () async {
                        setState(() {
                          alarmList.add(Alarm(time: _selectedTime, alarmId: 0, enabled: true));
                          NotificationService().scheduledNotification(hour: _selectedTime?.hour ?? 0, minutes: _selectedTime?.minute ?? 0,title: 'Sample title', body: 'Sample body');
                          Navigator.pop(context);
                        });
                        await _saveData();
                      },
                    ),
                  ],
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: _visableSleepSchedual[1],
                  child: toggleButtons2B(
                    selectionList: _timeSelection, 
                    text1: "hot", 
                    text2: "cold", 
                    setModalState: setModalState
                  ),
                ),
                SizedBox(height: 20),
                timePickerSpinn(),
                SizedBox(height: 20),
                toggleButtons2B(
                  selectionList: _visableSleepSchedual, 
                  text1: "hot", 
                  text2: "cold", 
                  setModalState: setModalState
                ),
              ],
            ),
          ),
        );
        });
      },
    );
  }
  ToggleButtons toggleButtons2B(
    {
      required StateSetter setModalState,
      required String text1,
      required String text2,
      required List<bool> selectionList
    }
  ){
    return ToggleButtons(
                    renderBorder: false,
                    color: Colors.deepPurple,
                    fillColor: Colors.deepPurple,
                    selectedColor: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    isSelected: selectionList,
                    children: <Widget> [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 36)/3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: <Widget>[
                            const SizedBox(width: 4.0),
                            Text(text1),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 36)/3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: <Widget>[
                            const SizedBox(width: 4.0,),
                            Text(text2),
                          ],
                        ),
                      ),
                    ],
                    onPressed: (index) { 
                      setModalState(() { 
                        for (int i = 0; i < selectionList.length; i++){
                          selectionList[i] = index == i;
                        }
                      });
                    },
                  );
  }
  TimePickerSpinner timePickerSpinn() {
    return TimePickerSpinner(
      is24HourMode: true,
      normalTextStyle: TextStyle(
        color: Colors.deepPurple.shade100,
        fontSize: 24,
      ),
      highlightedTextStyle: const TextStyle(
        color: Colors.deepPurple,
        fontSize: 24,
      ),
      spacing: 25,
      itemHeight: 40,
      onTimeChange: (time) {
        setState(() {
              _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
              //NotificationService().scheduledNotification(hour: selectedTime?.hour ?? 0, minutes: selectedTime?.minute ?? 0,title: 'Sample title', body: 'Sample body');
        });
      },
    );
  }
}
