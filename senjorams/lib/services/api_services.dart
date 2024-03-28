import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:senjorams/models/channel_model.dart';
import 'package:senjorams/models/video_model.dart';
import 'package:senjorams/utilities/keys.dart';
import 'package:senjorams/models/food_model.dart';

class YouTubeAPI {

  YouTubeAPI._instantiate();

  static final YouTubeAPI instance = YouTubeAPI._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';

  Future<Channel> fetchChannel({required String channelId}) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': channelId,
      'key': YT_API_KEY,
    };
    
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    var response = await http.get(uri, headers: headers);
    if(response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);

      // Fetch first batch of videos from playlist
      channel.videos = await fetchVideosFromPlaylist(
        playlistId: channel.uploadPlaylistId,
      );
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<List<Video>> fetchVideosFromPlaylist({required String playlistId}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playlistId,
      'maxResults': '8',
      'pageToken': _nextPageToken,
      'key': YT_API_KEY,
    };

    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Playlist Videos
    var response = await http.get(uri, headers: headers);
    if(response.statusCode == 200) {
      var data = json.decode(response.body);
      print(response.body);
      
      _nextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];

      // Fetch first 8 videos from playlist
      List<Video> videos = [];
      videosJson.forEach(
        (json) => videos.add(
          Video.fromMap(json['snippet']),
        ),
      );
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}

class FoodAPI {
  static Future<List<dynamic>> fetchFoodNutrition(String foodName) async {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/nutrition?query=$foodName'),
      headers: {
        'X-Api-Key': Food_API_KEY,
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw json.decode(response.body)['error']['message'];
    }
  }
}