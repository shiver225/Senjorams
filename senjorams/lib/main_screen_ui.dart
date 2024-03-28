import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:senjorams/activities_ui.dart';
import 'package:senjorams/food_ui.dart';
import 'package:senjorams/medicine_page_ui.dart';
import 'package:senjorams/social_events.dart';
import 'package:senjorams/start_sreen_ui.dart';
import 'package:senjorams/sleep_ui.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
        backgroundColor: const Color(0xFF92C7CF),
        title: Text(
          _timeString,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2, // 2 buttons per row
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            buildElevatedButton('assets/images/medicine.svg', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicineScreen()),
              );
            }),
            buildElevatedButton('assets/images/food.svg', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodScreen()),
              );
            }),
            buildElevatedButton('assets/images/social_events.svg', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SocialEventScreen()),
              );
            }),
            buildElevatedButton('assets/images/sleep.svg', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SleepScreen()),
              );
            }),
            buildElevatedButton('assets/images/activities.svg', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivitiesScreen()),
              );
            }),
            buildElevatedButton('assets/images/logout.svg', () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StartScreen()),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFBF9F1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ElevatedButton(
            onPressed: () {
              // Display popup window
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text(
                      "Pagalba iškviesta!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Close",
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Pagalba!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildElevatedButton(String svgPath, void Function() onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(100, 75),
      backgroundColor: const Color(0xFFF5E5BA), // Sand color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgPath,
          height: 50,
          width: 50,
        ),
      ],
    ),
  );
}
}
