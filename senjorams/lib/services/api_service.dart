import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:senjorams/models/channel_model.dart';
import 'package:senjorams/models/video_model.dart';
import 'package:senjorams/utilities/keys.dart';

class APIService {
  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';
  
}