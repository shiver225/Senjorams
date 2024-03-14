import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senjorams/medicine_page_ui.dart';

class MainScreen extends StatefulWidget {
   const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _timeString = '';

  @override
  void initState() {
    super.initState();
    _updateTime(); // Update time initially
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat.Hms().format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          )
        ),
        backgroundColor: const Color(0xFF92C7CF),
        title: Text(
          _timeString, 
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicineScreen())
                );
              },
              child: const FittedBox(
                fit: BoxFit.fitWidth,
                child: Icon(Icons.medical_information),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to another page
              },
              child: const FittedBox(
                fit: BoxFit.fitWidth,
                child: Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to another page
              },
              child: const FittedBox(
                fit: BoxFit.fitWidth,
                child: Icon(Icons.alarm),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ElevatedButton(
            onPressed: () {
              // Display popup window
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Popup Window"),
                    content: const Text("This is a popup window."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Show Popup'),
          ),
        ),
      ),
    );
  }
}