import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:senjorams/models/exercise_plan_model.dart';

class SportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExercisePlan?>(
      future: ExercisePlan.loadExercisePlan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData) {
            // User has a plan, navigate to the plan details screen
            //ExercisePlan plan = ExercisePlan.loadExercisePlan() as ExercisePlan;
            return ExercisePlanScreen(
                plan: snapshot.data as ExercisePlan, isChosen: true);
          } else {
            // User does not have a plan, navigate to another screen
            return ChoosePlanScreen();
          }
        }
      },
    );
  }
}

class ExercisePlanScreen extends StatelessWidget {
  final ExercisePlan plan;
  final bool isChosen;

  ExercisePlanScreen({required this.plan, required this.isChosen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Intensity levels"),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: 60,
            child: isChosen
                ? _displayText(
                    context,
                    "Your current exercise plan '${plan.getName}'",
                    40,
                    TextAlign.center)
                : _displayText(context, plan.getName, 40, TextAlign.center),
          ),
          SizedBox(
              height: 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: isChosen
                    ? _displayText(
                        context,
                        "Details of exercises and recommended frequencies. \nClick 'Change' to see other plans",
                        20,
                        TextAlign.left)
                    : _displayText(
                        context,
                        "Details of exercises and recommended frequencies. \nClick 'Choose' to pick this plan",
                        20,
                        TextAlign.left),
              )),
          _displayPlanInfo(context, plan),
          Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: isChosen
                  ? ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(minimumSize: Size(200, 60)),
                      onPressed: () {},
                      child: Text("CHANGE",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    )
                  : ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(minimumSize: Size(200, 60)),
                      onPressed: () {},
                      child: Text("CHOOSE",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ))
        ]));
  }
}

class ChoosePlanScreen extends StatelessWidget {
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
              padding: EdgeInsets.all(10.0),
              children: intensityOptions
                  .map((option) => _displayIntensityButton(context, option))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _displayText(
    BuildContext context, String text1, double size, TextAlign align) {
  return Row(children: [
    Expanded(
      child: Text(
        text1,
        style: TextStyle(
          color: Colors.black87, // Text color
          fontSize: size, // Font size
          //fontWeight: FontWeight.bold,
        ),
        textAlign: align,
        softWrap: true,
      ),
    )
  ]);
}

// Displays info of any plan as a row of exercises displayed in a column
Widget _displayPlanInfo(BuildContext context, ExercisePlan plan) {
  return Expanded(
      child: ListView(
    addAutomaticKeepAlives: true,
    padding: EdgeInsets.all(8.0),
    children:
        plan.exercises.map((ex) => _displayExerciseInfo(context, ex)).toList(),
  ));
}

// Displays information about a single exercise
Widget _displayExerciseInfo(
    BuildContext context, Map<String, dynamic> exercise) {
  return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child:
                      Icon(exercise['icon'], color: Colors.black12, size: 50),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Text(
                    exercise['name'],
                    style: TextStyle(
                      color: Colors.black87, // Text color
                      fontSize: 40, // Font size
                      //fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
                SizedBox(width: 40),
                Text(
                  '${exercise['interval'].toString()} ${exercise['freq'].toString()}',
                  style: TextStyle(
                    color: Colors.black87, // Text color
                    fontSize: 40, // Font size
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ));
}

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
        ExercisePlan plan = ExercisePlan(
            name: option['intensity'], exercises: option['activities']);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExercisePlanScreen(plan: plan, isChosen: false),
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
              child: Column(children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Icon(option['icon'], color: Colors.black12, size: 50),
                ),
                Text(
                  option['intensity'],
                  style: TextStyle(
                    color: Colors.black87, // Text color
                    fontSize: 20, // Font size
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
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
      {
        'name': 'Stretching',
        'freq': 'h',
        'interval': 2,
        'icon': FontAwesomeIcons.heartPulse
      },
      {
        'name': 'Walking',
        'freq': 'd',
        'interval': 1,
        'icon': FontAwesomeIcons.personWalking
      },
      {
        'name': 'Fast paced / long walk',
        'freq': 'd',
        'interval': 7,
        'icon': FontAwesomeIcons.stopwatch
      }
    ],
    'icon': FontAwesomeIcons.medal
  },
  {
    'intensity': 'Medium',
    'activities': [
      {
        'name': 'Walking ',
        'freq': 'h',
        'interval': 4,
        'icon': FontAwesomeIcons.personWalking
      },
      {
        'name': 'Riding a bike',
        'freq': 'd',
        'interval': 3,
        'icon': FontAwesomeIcons.personBiking
      },
      {
        'name': 'Hiking',
        'freq': 'd',
        'interval': 7,
        'icon': FontAwesomeIcons.personHiking
      }
    ],
    'icon': FontAwesomeIcons.medal
  },
  {
    'intensity': 'High',
    'activities': [
      {
        'name': 'Walking ',
        'freq': 'h',
        'interval': 4,
        'icon': FontAwesomeIcons.personWalking
      },
      {
        'name': 'Running',
        'freq': 'd',
        'interval': 1,
        'icon': FontAwesomeIcons.personRunning
      },
      {
        'name': 'Swimming',
        'freq': 'd',
        'interval': 4,
        'icon': FontAwesomeIcons.personSwimming
      }
    ],
    'icon': FontAwesomeIcons.medal
  }
];
