import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          initialEntryMode: entryMode,
                          orientation: orientation,
                          builder: (BuildContext context, Widget? child) {
                            // We just wrap these environmental changes around the
                            // child in this builder so that we can apply the
                            // options selected above. In regular usage, this is
                            // rarely necessary, because the default values are
                            // usually used as-is.
                            return Theme(
                              data: Theme.of(context).copyWith(
                                materialTapTargetSize: tapTargetSize,
                              ),
                              child: Directionality(
                                textDirection: textDirection,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    alwaysUse24HourFormat: use24HourTime,
                                  ),
                                  child: child!,
                                ),
                              ),
                            );
                          },
                        );
                        setState(() {
                          NotificationService().showNotification(title: 'Sample title', body: 'Sample body');
                          selectedTime = time;
                        });
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
