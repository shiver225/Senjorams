import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';


class AlarmScreen extends StatelessWidget {
  final AudioPlayer player;

  const AlarmScreen({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final format = DateFormat('Hm');

    return Container(
      color: Color.fromARGB(255, 247,246,250),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Container(
              width: 325,
              height: 325,
              decoration: ShapeDecoration(
                  shape: CircleBorder(
                      side: BorderSide(
                          color: Colors.deepPurple,
                          style: BorderStyle.solid,
                          width: 4))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                  DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800),
                    child :Text(
                      format.format(now),
                    ),
                  )
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SlideAction(
              height: 80,
              sliderButtonIcon: Icon(
                Icons.chevron_right,
                size: 36,
              ),
              child: Center(
                  child: Text(
                'Turn off alarm!',
                style: TextStyle(fontSize: 26),
              )),
              onSubmit: () async {
                player.stop();
                SystemNavigator.pop();
              },
              innerColor: Colors.deepPurple,
              outerColor: Color.fromARGB(255, 196, 183, 235),
            ),
          )
        ],
      ),
    );
  }
}