import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:senjorams/main_screen_ui.dart';
import 'package:senjorams/services/notification_service.dart';


class Alarm{
  TimeOfDay? time;
  int? alarmId;
  bool enabled;
  bool isSelected;
  Color cardColor;
  Alarm({this.time, this.alarmId, this.enabled = true, this.isSelected = false, this.cardColor = Colors.white});
}
class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  List<Alarm> alarmList = [];
  List<Alarm> alarmTrachCan = [];
  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  TextDirection textDirection = TextDirection.ltr;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = true;

  @override
  void initState() {
    super.initState();
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
              onPressed: () {
                alarmList.removeWhere((item) => alarmTrachCan.contains(item));
                //disable alarm
                alarmTrachCan.clear();
                setState(() {});
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
                                  onChanged: (bool value) {
                                    // This is called when the user toggles the switch.
                                    setState(() {
                                      alarmList[index].enabled = value;
                                    });
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
                      onPressed: () async {
                        bottomScrollPicker().show(context);
                      },
                      child: const Icon(Icons.add, color: Colors.white, size: 24,)
                    ),
                  ),
    );
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
  BottomPicker bottomScrollPicker(){
      return BottomPicker.time(
        pickerTitle: const Text(
          'Set your sleep time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        buttonContent: const Text(
          'select',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 16,
          ),
        ),
        buttonStyle: BoxDecoration(
          border: const Border(
              bottom:BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
          ),
          
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 247,242,249),
        ),
        onSubmit: (index) {
          setState(() {
            selectedTime = TimeOfDay(hour: index.hour, minute: index.minute);
            NotificationService().scheduledNotification(hour: selectedTime?.hour ?? 0, minutes: selectedTime?.minute ?? 0,title: 'Sample title', body: 'Sample body');
            alarmList.add(Alarm(time: selectedTime, alarmId: 0, enabled: true));
          });
        },
        pickerTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        onClose: () {
          print('Picker closed');
        },
        bottomPickerTheme: BottomPickerTheme.blue,
        use24hFormat: true,
        initialTime: Time.now(),
    );
  }
}
