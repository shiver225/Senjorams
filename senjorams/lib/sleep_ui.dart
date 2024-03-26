import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senjorams/main.dart';
import 'package:senjorams/services/notification_service.dart';


class Alarm{
  TimeOfDay time;
  int alarmId;
  bool enabled;
  String title;
  String body;
  bool isSelected = false;
  Color cardColor = Colors.white;
  Alarm({required this.time, required this.alarmId, required this.title, required this.body, this.enabled = true});

  Alarm.fromJson(Map<String, dynamic> json)
      : time = TimeOfDay(hour: int.parse(json['time'].split(":")[0]), minute: int.parse(json['time'].split(":")[1])),
        alarmId = json['alarmId'] as int,
        enabled = json['enabled'] as bool,
        title = json['title'] ?? "",
        body = json['body'] ?? "";
  Map<String, dynamic> toJson() => {
        'time': '${time.hour}:${time.minute}',
        'alarmId': alarmId,
        'enabled' : enabled,
        'title' : title,
        'body' : body,
      };
  Future<void> updateScheduledNotification() async{
    if(enabled){
      NotificationService().scheduledNotification(id: alarmId, hour: time.hour, minutes: time.minute,title: title, body: body);
    }
    else{
      await NotificationService().cancelScheduledNotification(alarmId);
    }
  }
}
class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final List<bool> _visableSleepSchedule = <bool> [true, false];
  final List<bool> _timeSelection = <bool> [true, false];
  
  var globalKey = GlobalKey();
  List<Alarm> alarmList = [];
  List<Alarm> alarmTrachCan = [];
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedTimeSleep = TimeOfDay.now();
  TimeOfDay? _selectedTimeWakeUp = TimeOfDay(hour: TimeOfDay.now().hour + 8, minute: TimeOfDay.now().minute);

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
                for (var element in alarmTrachCan) {
                  element.enabled = false;
                  await element.updateScheduledNotification();
                }
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
                              await alarmList[index].updateScheduledNotification();
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
      isScrollControlled:true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState){
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      child: const Icon(Icons.clear),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.65),
                    TextButton(
                      child: const Icon(Icons.check),
                      onPressed: () async {
                        setState(() {
                          alarmList.add(Alarm(time: _selectedTime ?? TimeOfDay.now(), alarmId: 0, title: 'sample title', body: 'sample body', enabled: true));
                          Navigator.pop(context);
                        });
                        await alarmList.last.updateScheduledNotification();
                        await _saveData();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: _visableSleepSchedule[1],
                  child: toggleButtons2B(
                    selectionList: _timeSelection, 
                    text1: "${_selectedTimeSleep?.hour}:${_selectedTimeSleep?.minute}", 
                    text2: "${_selectedTimeWakeUp?.hour}:${_selectedTimeWakeUp?.minute}", 
                    setModalState: setModalState,
                    textStyle: const TextStyle(
                      fontSize: 24,
                    ),
                    buttonWidth: (MediaQuery.of(context).size.width - 36)/2,
                    buttonHeight: (MediaQuery.of(context).size.width - 36)/10
                  ),
                ),
                SizedBox(height: 20),
                timePicker(setModalState),
                SizedBox(height: 20),
                inkButtons(
                  isSelected: _visableSleepSchedule,
                  setModalState: setModalState,
                  buttonText: ["Ring Once", "Schedule"],
                  spacing: MediaQuery.of(context).size.width * 0.3
                 ),
              ],
            ),
          ),
        );
        });
      },
    );
  }
  Ink inkButtons({required List<bool> isSelected, required StateSetter setModalState, required List<String> buttonText, double? spacing}){
    return Ink(
      height: 60, 
      width: spacing!=null ? spacing * 2.5 :200,
      child: GridView.count(
        primary: true,
        crossAxisCount: 2, //set the number of buttons in a row
        crossAxisSpacing: spacing ?? 20, //set the spacing between the buttons
        childAspectRatio: 2, //set the width-to-height ratio of the button, 
                             //>1 is a horizontal rectangle
        children: List.generate(isSelected.length, (index) {
          //using Inkwell widget to create a button
          return InkWell( 
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.deepPurple.shade100, //the default splashColor is grey
              onTap: () {
                //set the toggle logic
                setModalState(() { 
                  for (int indexBtn = 0;indexBtn < isSelected.length;indexBtn++) {
                    isSelected[indexBtn] = index == indexBtn;
                  }
                });
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected[index] ? Colors.deepPurple : Color.fromARGB(255, 247,246,250), 
                  borderRadius: BorderRadius.circular(20), 
                ),
                child: Center(
                  child: Text(
                    buttonText[index], 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: isSelected[index] ? Color.fromARGB(255, 247,246,250) : Colors.deepPurple,
                      fontSize: 15,
                    ),
                  ),
                ), 
              ),
            );
        }),
      ),
    );
  } 

  ToggleButtons toggleButtons2B(
    {
      required StateSetter setModalState,
      required String text1,
      required String text2,
      required List<bool> selectionList,
      double? buttonWidth,
      double? buttonHeight,
      TextStyle? textStyle
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
                        width: buttonWidth ?? (MediaQuery.of(context).size.width - 36)/3,
                        height: buttonHeight ?? (MediaQuery.of(context).size.height - 36)/20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: <Widget>[
                            const SizedBox(width: 4.0),
                            Text(text1, style: textStyle,),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth ?? (MediaQuery.of(context).size.width - 36)/3,
                        height: buttonHeight ?? (MediaQuery.of(context).size.height - 36)/20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: <Widget>[
                            const SizedBox(width: 4.0,),
                            Text(text2, style: textStyle),
                          ],
                        ),
                      ),
                    ],
                    onPressed: (index) { 
                      setModalState(() { 
                        for (int i = 0; i < selectionList.length; i++){
                          selectionList[i] = index == i;
                        }
                        if(selectionList[index] && index == 0){
                          _selectedTime = _selectedTimeSleep;
                        }
                        else{
                          _selectedTime = _selectedTimeWakeUp;
                        }
                        globalKey = GlobalKey();
                      });
                    },
                  );
  }
  Widget timePicker(StateSetter setSpinnerState){
    return Container(
      height: 200,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: CupertinoTheme(
        data: const CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                    fontSize: 45,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                ),
            ),
        ),
        child: CupertinoDatePicker(
          key: globalKey,
          itemExtent: 60,
          mode: CupertinoDatePickerMode.time,
          initialDateTime: _selectedTime != null ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, _selectedTime!.hour, _selectedTime!.minute) : DateTime.now(),
          use24hFormat: true,
          onDateTimeChanged: (DateTime value) 
          { 
            setState(() {
              _selectedTime = TimeOfDay(hour: value.hour, minute: value.minute);
              //NotificationService().scheduledNotification(hour: selectedTime?.hour ?? 0, minutes: selectedTime?.minute ?? 0,title: 'Sample title', body: 'Sample body');
            });
            setSpinnerState(() {
              if(_timeSelection[0]){
                _selectedTimeSleep = _selectedTime ?? TimeOfDay.now();
              }
              else{
                _selectedTimeWakeUp = _selectedTime ?? TimeOfDay.now();
              }
            });
          },
        )
      )
    );
  }
}
