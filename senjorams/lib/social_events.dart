import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialEventScreen extends StatefulWidget {
  const SocialEventScreen({Key? key}) : super(key: key);

  @override
  _SocialEventsScreenState createState() => _SocialEventsScreenState();
}

class _SocialEventsScreenState extends State<SocialEventScreen> {
  final Map<String, List<Map<String, String>>> cityEvents = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Replace 'your_json_file.json' with the actual path of your JSON file
    String jsonData = await rootBundle.loadString(
        'assets/events.json'); // Use rootBundle instead of DefaultAssetBundle
    List<dynamic> data = json.decode(jsonData);

    setState(() {
      cityEvents.clear();
      for (var item in data) {
        String city = item['city'];
        List<Map<String, String>> events = [];

        // Parse events for each city
        for (var event in item['events']) {
          events.add({
            'type': event['type'],
            'title': event['title'],
            'location': event['location'],
            'start': event['start'],
            'end': event['end'],
            'link': event['link'],
          });
        }

        // Update cityEvents map
        cityEvents[city] = events;
      }
    });
  }

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
        title: Text('Choose a City'),
      ),
      body: ListView.builder(
        itemCount: cities.keys.length,
        itemBuilder: (context, index) {
          final city = cities[cities.keys.elementAt(index)];
          return ListTile(
            title: Text(cities.keys.elementAt(index)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventListScreen(
                        city: city!,
                        events:
                            cityEvents[cities[cities.keys.elementAt(index)]]!)),
              );
            },
          );
        },
      ),
    );
  }
}

class EventListScreen extends StatelessWidget {
  final String city;
  // Sample data for events. Replace this with your actual data source.
  final List<Map<String, String>> events;

  EventListScreen({required this.city, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events in $city'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event['title']!),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Type: ${event['type']}'),
              Text('Location: ${event['location']}'),
              Text('Starts at: ${event['start']}'),
              Text('Ends at ${event['end']}'),
              GestureDetector(
                onTap: () {
                  _launchURL(event['link']!);
                },
                child: Text(
                  'More at:',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
