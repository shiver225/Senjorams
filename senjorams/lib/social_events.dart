import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialEventScreen extends StatefulWidget {
  const SocialEventScreen({Key? key}) : super(key: key);

  @override
  _SocialEventsScreenState createState() => _SocialEventsScreenState();
}

class _SocialEventsScreenState extends State<SocialEventScreen> {
  final Map<String, List<Map<String, String>>> cityEvents = {};

  late String _timeString = '';
  late var timer;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    //_loadData();

    _updateTime(); // Update time initially
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat.Hms().format(now);
    });
  }

  Future<List<Map<String, String>>> _loadData(city_key) async {
    // Replace 'your_json_file.json' with the actual path of your JSON file
    String jsonData = "";
    late List<dynamic> data;
    late List<Map<String, String>> city_events;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
        .collection('SocialEvents')
        .where('city', isEqualTo: city_key)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    data = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    if (data.isEmpty) {
      String jsonData = await rootBundle.loadString(
          'assets/events.json'); // Use rootBundle instead of DefaultAssetBundle
      data = json.decode(jsonData);
    }

    List<Map<String, String>> events = [];
    for (var event in data) {
      String city = event["city"];

      // Parse events for each city

      events.add({
        'type': event['type'].toString(),
        'title': event['title'].toString(),
        'location': event['location'].toString(),
        'start': event['start'].toString(),
        'end': event['end'].toString(),
        'link': event['link'].toString(),
      });

      // Update cityEvents map
    }
    city_events = events;

    return city_events;
  }

  // Future<void> _loadData() async {
  //   // Replace 'your_json_file.json' with the actual path of your JSON file
  //   String jsonData = await rootBundle.loadString(
  //       'assets/events.json'); // Use rootBundle instead of DefaultAssetBundle
  //   List<dynamic> data = json.decode(jsonData);

  //   db.collection("cities").where("capital", isEqualTo: true).get().then(
  //     (querySnapshot) {
  //       print("Successfully completed");
  //       for (var docSnapshot in querySnapshot.docs) {
  //         print('${docSnapshot.id} => ${docSnapshot.data()}');
  //       }
  //     },
  //     onError: (e) => print("Error completing: $e"),
  //   );
  //   setState(() {
  //     cityEvents.clear();
  //     for (var item in data) {
  //       String city = item['city'];
  //       List<Map<String, String>> events = [];

  //       // Parse events for each city
  //       for (var event in item['events']) {
  //         events.add({
  //           'type': event['type'],
  //           'title': event['title'],
  //           'location': event['location'],
  //           'start': event['start'],
  //           'end': event['end'],
  //           'link': event['link'],
  //         });
  //       }

  //       // Update cityEvents map
  //       cityEvents[city] = events;
  //     }
  //   });
  // }

  final Map<String, String> cities = {
    'Kaunas': 'kaunas',
    'Vilnius': 'vilnius',
    'Klaipėda': 'klaipeda',
    'Šiauliai': 'siauliai'
  }; // List of available cities

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 30), // Adjust the left padding as needed
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two buttons per row
              mainAxisSpacing: 30.0,
              crossAxisSpacing: 30.0,
              childAspectRatio:
                  0.9, // Adjust the aspect ratio for bigger buttons
            ),
            itemCount: cities.keys.length,
            itemBuilder: (context, index) {
              String cityName = cities.keys.elementAt(index);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFF4E4C1), // Light sand color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () async {
                  List<Map<String, String>> temp = [];
                  temp = await _loadData(cities[cityName]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventListScreen(
                          city: cityName,
                          city_key: cities[cityName]!,
                          city_events: temp),
                    ),
                  );
                },
                child: Text(
                  cityName,
                  style: TextStyle(fontSize: 24.0), // Adjust the font size
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class EventListScreen extends StatelessWidget {
  final String city;
  // Sample data for events. Replace this with your actual data source.
  final String city_key;
  final List<Map<String, String>> city_events;

  EventListScreen(
      {required this.city, required this.city_key, required this.city_events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 30), // Adjust the left padding as needed
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
        backgroundColor: const Color(0xFF92C7CF),
        title: Text(
          'Events in $city',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
          itemCount: city_events.length,
          itemBuilder: (context, index) {
            final event = city_events[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10, // Increased elevation for more shadow
              color: Color.fromARGB(
                  255, 253, 231, 182), // Light sand color for the card
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: Color(0xFF92C7CF), // Matching icon color
                          size: 40,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            event['title']!,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black),
                    SizedBox(height: 8.0),
                    Text(
                      'Type: ${event['type']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
                    ),
                    Text(
                      'Location: ${event['location']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
                    ),
                    Text(
                      'Starts at: ${event['start']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
                    ),
                    Text(
                      'Ends at: ${event['end']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          _launchURL(event['link']!);
                        },
                        child: Text(
                          'Event Link',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(
                                255, 95, 140, 199), // Matching link color
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  // Future<void> _loadData() async {
  //   // Replace 'your_json_file.json' with the actual path of your JSON file
  //   String jsonData = "";
  //   late List<dynamic> data;

  //   QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
  //       .collection('SocialEvents')
  //       .where('city', isEqualTo: city_key)
  //       .get();

  //   data = querySnapshot.docs
  //       .map((doc) => doc.data() as Map<String, dynamic>)
  //       .toList();

  //   city_events.clear();
  //   for (var item in data) {
  //     String city = item['city'];
  //     List<Map<String, String>> events = [];

  //     // Parse events for each city
  //     for (var event in item['events']) {
  //       events.add({
  //         'type': event['type'],
  //         'title': event['title'],
  //         'location': event['location'],
  //         'start': event['start'],
  //         'end': event['end'],
  //         'link': event['link'],
  //       });
  //     }

  //     // Update cityEvents map
  //     city_events = events;
  //   }
  // }
}
