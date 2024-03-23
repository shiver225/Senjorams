import 'package:flutter/material.dart';
import 'package:senjorams/models/channel_model.dart';
import 'package:senjorams/models/video_model.dart';
import 'package:senjorams/services/api_service.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {

  Channel _channel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'MrBeast');
    setState(() {
      _channel = channel;
    });
  }

  _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YouTube Channel"),
      ),
      body: ListView.builder(
        itemCount: 1 + _channel.videos.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildProfileInfo();
          }
          Video video = _channel.videos[index -1];
          return _buildVideo(video);
        },
      ),
    );
  }
}