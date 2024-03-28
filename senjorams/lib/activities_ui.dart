import 'package:flutter/material.dart';
import 'package:senjorams/youtube_ui.dart'; // Import the youtube_ui.dart file

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activities"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video option buttons
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: activityOptions
                  .map((option) => _buildActivityButton(context, option))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton(BuildContext context, Map<String, dynamic> option) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => YouTubeScreen(id: option['channelId'], name: option['name'])),
        );
      },
      child: Card(
        elevation: 5, // Add elevation for shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)), // Rounded top corners for image
              child: Image.asset(
                option['image'],
                fit: BoxFit.cover, // Image fills the available space
                height: 200, // Adjust the height of the image
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                option['name'],
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
  final List<Map<String, dynamic>> activityOptions = [
    {
      'name': 'Exercise',
      'channelId': 'UCkWYei5MULuRDhH7uxtZqqA',
      'image': 'assets/images/exercise_image.jpg',
    },
    {
      'name': 'Puzzle Games',
      'channelId': 'UCW7f0bXf4kXedQ6wP-QNl7Q',
      'image': 'assets/images/puzzle_games_image.jpg',
    },
    {
      'name': 'Music Therapy',
      'channelId': 'UC4B4KZ-_PtVSTvL67Fhfa8Q',
      'image': 'assets/images/music_therapy_image.png',
    },
    {
      'name': 'Art and Crafts',
      'channelId': 'UCjz0bp1sxpbtXNQ7vCwJ-gw',
      'image': 'assets/images/art_and_crafts_image.jpg',
    },
  ];
}
