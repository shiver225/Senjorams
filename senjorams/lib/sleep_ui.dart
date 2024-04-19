import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senjorams/main.dart';
import 'package:senjorams/models/alarm_model.dart';
import 'package:uuid/v1.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final List<bool> _visableSleepSchedule = <bool> [true, false];
  final List<bool> _timeSelection = <bool> [true, false];
  final List<Alarm> _alarmTrachCan = [];
  
  var _globalKey = GlobalKey();
  List<Alarm> _alarmList = [];
  TimeOfDay? _selectedTime;
  TimeOfDay _selectedTimeSleep = TimeOfDay.now();
  TimeOfDay _selectedTimeWakeUp = TimeOfDay(hour: (TimeOfDay.now().hour + 8)%24, minute: TimeOfDay.now().minute);

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  void _loadData() {
    final String? saved = prefs?.getString('alarmList');
    print(saved);
    if(saved != null){
      final List<dynamic> decoded = json.decode(saved);
      _alarmList = decoded.map((alarm) => Alarm.fromJson(Map<String, dynamic>.from(alarm))).toList();
    }
  }
  Future<void> _saveData() async {
    final String alarmL = json.encode(_alarmList);
    await prefs?.setString('alarmList', alarmL);
  }
  
  void _toggleSelection(Alarm alarm) {
    setState(() {
      if (alarm.isSelected) {
        alarm.cardColor=Colors.white;
        alarm.isSelected = false;
        _alarmTrachCan.remove(alarm);
      } else {
        alarm.cardColor=const Color.fromARGB(255, 223, 222, 222);
        alarm.isSelected = true;
        alarm.activationDate = DateTime.now();
        _alarmTrachCan.add(alarm);
      }
    });
  }
  void _modalScrollPicker({required BuildContext context, int? index}){
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
                    SizedBox(width: MediaQuery.of(context).size.width * 0.55),
                    TextButton(
                      child: const Icon(Icons.check),
                      onPressed: () async {
                        setState(() {
                          if(_visableSleepSchedule[1]){
                            if(index != null){
                              _alarmList[index] = Alarm(
                                time: [_selectedTimeSleep,_selectedTimeWakeUp],
                                alarmId: _alarmList[index].alarmId,
                                title: _alarmList[index].title, 
                                body: _alarmList[index].body, 
                                enabled: true, 
                                linkedAlarmAmm: 1
                                );
                            }
                            else{
                              _alarmList.add(Alarm(
                                time: [_selectedTimeSleep,_selectedTimeWakeUp],
                                 alarmId: UuidV1().hashCode,
                                  title: ['Miegas', 'Keltis'],
                                  body: ['Miegas','Keltis'],
                                  enabled: true,
                                  linkedAlarmAmm: 1
                                  ));
                            }
                          }
                          else{
                            if(index != null){
                              _alarmList[index] = Alarm(
                                time: [_selectedTime ?? TimeOfDay.now()], 
                                alarmId: _alarmList[index].alarmId, 
                                title: _alarmList[index].title, 
                                body: _alarmList[index].body, 
                                enabled: true
                                );
                            }
                            else{
                              _alarmList.add(Alarm(
                                time: [_selectedTime ?? TimeOfDay.now()],
                                  alarmId: UuidV1().hashCode,
                                  title: ['Miegas'], 
                                  body: ['Miegas'], 
                                  enabled: true
                                  ));
                            }
                          }
                          Navigator.pop(context);
                        });
                        if(index != null){
                          await _alarmList[index].updateScheduledNotification();
                        }
                        else {
                          await _alarmList.last.updateScheduledNotification();
                        }
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
                  child: _toggleButtons2B(
                    selectionList: _timeSelection, 
                    text1: _selectedTimeSleep.format(context), 
                    text2: _selectedTimeWakeUp.format(context), 
                    setModalState: setModalState,
                    textStyle: const TextStyle(
                      fontSize: 24,
                    ),
                    buttonWidth: (MediaQuery.of(context).size.width - 36)/2,
                    buttonHeight: (MediaQuery.of(context).size.width - 36)/10
                  ),
                ),
                SizedBox(height: 20),
                _timePicker(setModalState),
                SizedBox(height: 20),
                _inkButtons(
                  isSelected: _visableSleepSchedule,
                  setModalState: setModalState,
                  buttonText: ["Vieną kartą", "Tvarkaraštis"],
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
  Card _alarmCard(int index){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: _alarmList[index].cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          InkWell(
            onTap: _alarmTrachCan.isEmpty ? () => _modalScrollPicker(context: context, index: index) : () => _toggleSelection(_alarmList[index]),
            onLongPress: () {_toggleSelection(_alarmList[index]);Feedback.forTap(context);},
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              enabled: _alarmList[index].enabled, 
              selected: _alarmList[index].isSelected,
              title: Text(
                _alarmList[index].linkedAlarmAmm == 0 ? _alarmList[index].time[0].format(context)
                : _alarmList[index].time[1].format(context),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _alarmList[index].linkedAlarmAmm == 0 ? "Vieną kartą" : "Kasdienis | ${_alarmList[index].time[0].format(context)}"
              ),
              trailing:_alarmTrachCan.isEmpty ? Switch(
                value: _alarmList[index].enabled,
                onChanged: (bool value) async {
                  // This is called when the user toggles the switch.
                  setState(() {
                    _alarmList[index].enabled = value;
                  });
                  Feedback.forTap(context);
                  await _alarmList[index].updateScheduledNotification();
                  await _saveData();
                },
              ) 
              : Checkbox(
                value: _alarmList[index].isSelected,
                onChanged: (bool? value) { 
                  Feedback.forTap(context);
                  _toggleSelection(_alarmList[index]);            
                },
              ),
              
              ),
            )
          ],
        ),
      );
  }
  Ink _inkButtons({required List<bool> isSelected, required StateSetter setModalState, required List<String> buttonText, double? spacing}){
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

  ToggleButtons _toggleButtons2B(
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
          _globalKey = GlobalKey();
        });
      },
    );
  }
  Widget _timePicker(StateSetter setSpinnerState){
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
          key: _globalKey,
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
                _selectedTimeSleep = _selectedTime ?? _selectedTimeSleep;
              }
              else{
                _selectedTimeWakeUp = _selectedTime ?? _selectedTimeWakeUp;
              }
            });
          },
        )
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _alarmTrachCan.isEmpty ? 
      AppBar(
        title: const Text('Sleep Tracker'),
      )
      :AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            for (var element in _alarmTrachCan) {
              element.isSelected = false;
              element.cardColor = Colors.white;
            }
            setState(() {
              _alarmTrachCan.clear();
            });
          },
        ),
        title: Text(
          _alarmTrachCan.length.toString(), 
          style: const TextStyle(color:Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                for (var element in _alarmTrachCan) {
                  element.enabled = false;
                  await element.updateScheduledNotification();
                }
                _alarmList.removeWhere((item) => _alarmTrachCan.contains(item));
                //disable alarm
                await _saveData();
                setState(() {_alarmTrachCan.clear();});
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
                  itemCount: _alarmList.length,
                  itemBuilder: (context, index){
                    _alarmList.sort((a, b) {
                      if (b.linkedAlarmAmm.compareTo(a.linkedAlarmAmm) > 0) {return 1;}
                      else if (b.linkedAlarmAmm.compareTo(a.linkedAlarmAmm) == 0) {
                        int compare(a, b, index) => (a.time[index].hour + a.time[index].minute/60).compareTo(b.time[index].hour + b.time[index].minute/60);
                        if(b.linkedAlarmAmm == 0){
                          return compare(a,b, 0);
                        }
                        else{
                          if(compare(b,a, 0) > 0) {return 1;}
                          else if (compare(b,a, 0) == 0) {return compare(b,a, 1);}
                          else {return -1;}
                        }
                      }
                      else {return -1;}
                      }
                    );
                    return _alarmCard(index);
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
          onPressed: () => _modalScrollPicker(context: context),
          child: const Icon(Icons.add, color: Colors.white, size: 24,)
        ),
      ),
    );
  }
}
