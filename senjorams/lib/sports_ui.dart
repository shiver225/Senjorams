import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData) {
            return ExercisePlanScreen(
                plan: snapshot.data as ExercisePlan, isChosen: true);
          } else {
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 30),
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
        title: _buildTimeWidget(),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20), // Add additional top padding
            child: _displayText(
                context,
                isChosen ? "Your current plan '${plan.getName}'" : plan.getName,
                40,
                TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 20, top: 20),
            child: _displayText(
              context,
              isChosen
                  ? ""
                  : "Details of exercises and recommended frequencies.",
              20,
              TextAlign.left,
            ),
          ),
          _displayPlanInfo(context, plan),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 255, 225, 179), // Light sand color
                minimumSize: const Size(200, 60),
              ),
              onPressed: () {
                if (!isChosen) {
                  ExercisePlan.saveExercisePlan(plan);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExercisePlanScreen(plan: plan, isChosen: true),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChoosePlanScreen(),
                    ),
                  ).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(
                isChosen ? "Change" : "Choose",
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChoosePlanScreen extends StatelessWidget {
  bool isPersonalized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 30),
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
        title: _buildTimeWidget(),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: intensityOptions
                  .map((option) => _displayIntensityButton(context, option))
                  .toList(),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                if (!isPersonalized) {
                  isPersonalized = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChoosePlanScreen(), //Yra PersonalizeCreen() metodas tai ten gal reiktu kazkas prikurt
                    ),
                  );
                }
              },
              child: Card(
                elevation: 5,
                color: const Color.fromARGB(
                    255, 255, 225, 179), // Light sand color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: const Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Icon(
                          Icons.question_mark_outlined,
                          color: Colors.black12,
                          size: 50,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Personalize",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalizeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 30),
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
        title: _buildTimeWidget(),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Personalize Screen",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

Widget _buildTimeWidget() {
  return StreamBuilder(
    stream: Stream.periodic(const Duration(seconds: 1)),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      return Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Text(
          _formatTime(DateTime.now()),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      );
    },
  );
}

String _formatTime(DateTime time) {
  return DateFormat.Hms().format(time);
}

Widget _displayText(
    BuildContext context, String text1, double size, TextAlign align) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text1,
          style: TextStyle(
            color: Colors.black,
            fontSize: size,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          textAlign: align,
        ),
      ],
    ),
  );
}

Widget _displayPlanInfo(BuildContext context, ExercisePlan plan) {
  return Expanded(
    child: ListView(
      addAutomaticKeepAlives: true,
      padding: const EdgeInsets.all(8.0),
      children: plan.exercises
          .map((ex) => _displayExerciseInfo(context, ex))
          .toList(),
    ),
  );
}

Widget _displayExerciseInfo(
    BuildContext context, Map<String, dynamic> exercise) {
  return Card(
    elevation: 5.0,
    color: const Color.fromARGB(255, 255, 225, 179),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icons[exercise['icon']],
                color: Colors.black,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  exercise['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Every ${exercise['interval'].toString()} ${exercise['freq'].toString()}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 56, 56, 56),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _displayIntensityButton(
    BuildContext context, Map<String, dynamic> option) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: GestureDetector(
      onTap: () {
        ExercisePlan plan = ExercisePlan(
          name: option['intensity'],
          exercises: option['activities'],
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ExercisePlanScreen(plan: plan, isChosen: false),
          ),
        );
      },
      child: Card(
        elevation: 5,
        color: const Color.fromARGB(255, 255, 225, 179),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Icon(
                  icons[option['icon']],
                  color: Colors.black,
                  size: 50,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                option['intensity'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
      {'name': 'Stretching', 'freq': 'h', 'interval': 2, 'icon': 'heartPulse'},
      {'name': 'Walking', 'freq': 'd', 'interval': 1, 'icon': 'personWalking'},
      {
        'name': 'Fast paced / long walk',
        'freq': 'd',
        'interval': 7,
        'icon': "stopwatch"
      }
    ],
    'icon': "medal"
  },
  {
    'intensity': 'Medium',
    'activities': [
      {'name': 'Walking ', 'freq': 'h', 'interval': 4, 'icon': "personWalking"},
      {
        'name': 'Riding a bike',
        'freq': 'd',
        'interval': 3,
        'icon': "personBiking"
      },
      {'name': 'Hiking', 'freq': 'd', 'interval': 7, 'icon': "personHiking"}
    ],
    'icon': "medal"
  },
  {
    'intensity': 'High',
    'activities': [
      {'name': 'Walking ', 'freq': 'h', 'interval': 4, 'icon': "personWalking"},
      {'name': 'Running', 'freq': 'd', 'interval': 1, 'icon': "personRunning"},
      {'name': 'Swimming', 'freq': 'd', 'interval': 4, 'icon': "personSwimming"}
    ],
    'icon': "medal"
  }
];

Map<String, IconData> icons = {
  "heartPulse": FontAwesomeIcons.heartPulse,
  "personWalking": FontAwesomeIcons.personWalking,
  "stopwatch": FontAwesomeIcons.stopwatch,
  "medal": FontAwesomeIcons.medal,
  "personBiking": FontAwesomeIcons.personBiking,
  "personHiking": FontAwesomeIcons.personHiking,
  "personRunning": FontAwesomeIcons.personRunning,
  "personSwimming": FontAwesomeIcons.personSwimming
};
