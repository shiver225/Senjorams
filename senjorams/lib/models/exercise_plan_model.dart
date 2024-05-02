import 'package:flutter/material.dart';
import 'package:senjorams/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExercisePlan {
  final String name;
  final List<dynamic> exercises;

  ExercisePlan({required this.name, required this.exercises});

  String get getName => name;
  List<dynamic> get getExercises => exercises;

  Map<String, dynamic> toJson() {
    return {"name": this.name, "exercises": this.exercises};
  }

  factory ExercisePlan.fromJson(Map<String, dynamic> parsedJson) {
    return ExercisePlan(
        name: parsedJson['name'], exercises: parsedJson['exercises']);
  }

  static Future<void> saveExercisePlan(ExercisePlan plan) async {
    String planChoice = json.encode(plan.toJson());
    await prefs?.setString('exercise_plan', planChoice);
  }

  static Future<ExercisePlan?> loadExercisePlan() async {
    String? planString = prefs?.getString('exercise_plan');
    if (planString != null) {
      return ExercisePlan.fromJson(json.decode(planString));
    }
    return null;
  }

  /*
  static void setExercises(List<Map<String, dynamic>> activities) {
    var act;
    for (act in activities) {
      Exercise ex = Exercise(
          name: act['name'], freq_unit: act['freq'], 
          interval: act['interval']);
      exercises.add(ex as Map<String, dynamic>);
    }
  }
  */
}

class Exercise {
  final String name;
  final String freq_unit;
  final int interval;

  Exercise(
      {required this.name, required this.freq_unit, required this.interval});

  String get getName => name;
  String get getFrequencyUnit => freq_unit;
  int get getInterval => interval;

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "freq_unit": this.freq_unit,
      "interval": interval
    };
  }
}
