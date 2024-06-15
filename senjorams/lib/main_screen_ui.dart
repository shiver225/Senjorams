import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:senjorams/activities_ui.dart';
import 'package:senjorams/sports_ui.dart';
import 'package:senjorams/map_ui.dart';
import 'package:senjorams/test.dart';
import 'package:senjorams/youtube_ui.dart';
import 'package:senjorams/food_ui.dart';
import 'package:senjorams/medicine_page_ui.dart';
import 'package:senjorams/social_events.dart';
import 'package:senjorams/start_sreen_ui.dart';
import 'package:senjorams/sleep_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _timeString = '';
  late var timer;

  @override
  void initState() {
    super.initState();
    _updateTime(); // Update time initially
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MedicineScreen()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(Icons.medical_information,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FoodScreen()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: FaIcon(FontAwesomeIcons.appleWhole,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SocialEventScreen()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(Icons.attractions,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SleepScreen()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(Icons.alarm,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivitiesScreen()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(FontAwesomeIcons.brain,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MapSample()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(FontAwesomeIcons.map,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SportScreen()));
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(Icons.sports,
                        color: Color.fromARGB(255, 206, 178, 129), size: 50),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 75)),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StartScreen()),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(Icons.logout, color: Colors.black, size: 50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFBF9F1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ElevatedButton(
            onPressed: () => _showCallButtonsDialog(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.black),
            child: const Text(
              'Pagalba!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _showCallButtonsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pasirinkite liniją'),
          content: CallButtons(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Atšaukti'),
            ),
          ],
        );
      },
    );
  }
}

class CallButtons extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'Vyrų linija', 'number': 'tel:+37068272974'},
    {'name': 'Moterų linija', 'number': 'tel:+37068272974'},
    {'name': 'Vilties linija', 'number': 'tel:+37068272974'},
    {'name': 'Sidabrinė linija', 'number': 'tel:+37068272974'},
  ];

  void _makePhoneCall(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Nepavyko paskambinti numeriu $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: contacts.map((contact) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _makePhoneCall(contact['number']!),
              child: Text(
                '${contact['name']}',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Color.fromARGB(255, 221, 195, 149),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
