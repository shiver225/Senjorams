import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:senjorams/main_screen_ui.dart';
import 'package:senjorams/services/notification_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
    
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
      appBar: AppBar(
        title: Text('Sleep Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      child: const Text('Open time picker'),
                      onPressed: () async {
                        BottomPicker.time(
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
                          ).show(context);
                        
                      },
                    ),
                  ),
                  if (selectedTime != null)
                    Text('Selected time: ${selectedTime!.format(context)}'),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
