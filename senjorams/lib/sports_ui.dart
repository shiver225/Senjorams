import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Intensity levels"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: intensityOptions
                  .map((option) => _displayIntensityButton(context, option))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayIntensityButton(
      BuildContext context, Map<String, dynamic> option) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IntensityScreen(option: option),
              ));
        },
        child: Card(
          elevation: 5, // Add elevation for shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  option['intensity'],
                  style: TextStyle(
                    color: Colors.black87, // Text color
                    fontSize: 20, // Font size
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List of activity options with their corresponding channel IDs and images
  final List<Map<String, dynamic>> intensityOptions = [
    {
      'intensity': 'Light',
      'activities': [
        {'name': 'stretching', 'freq': 'h', 'interval': 2},
        {'name': 'walking', 'freq': 'd', 'interval': 1},
        {'name': 'fast paced / long walk', 'freq': 'd', 'interval': 7}
      ]
    },
  ];
}

class IntensityScreen extends StatelessWidget {
  final Map<String, dynamic> option;
  const IntensityScreen({Key? key, required this.option}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(option['intensity']),
        ),
        body: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Intensity: ${option['intensity']}',
                style: TextStyle(fontSize: 50),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  children: option['activities']
                      .map<Widget>((activity) =>
                          _displayActivityDetails(context, activity))
                      .toList(),
                ),
              ),
              SizedBox(
                height: 80, // Adjust height as needed
                child: ElevatedButton(
                  onPressed: () {
                    _saveOption(option);
                  },
                  child: Text(
                    'CHOOSE',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _displayActivityDetails(
      BuildContext context, Map<String, dynamic> activity) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              ),
              Text(
                'Repeat every ${activity['interval']}${activity['freq']}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              )
            ],
          ),
        ));
  }

  // Save the displayed option locally using SharedPreferences
  void _saveOption(Map<String, dynamic> option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert the option map to a string using json.encode
    String optionString = json.encode(option);
    // Save the option string to SharedPreferences
    await prefs.setString('displayed_option', optionString);
  }
}
