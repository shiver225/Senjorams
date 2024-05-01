import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Medicine {
  final int notificationID;
  final String medicineName;
  final String interval;
  final String startTime;
  final String startDate;
  final String mealDepend;

  Medicine(
      {required this.notificationID,
      required this.medicineName,
      required this.startTime,
      required this.startDate,
      required this.interval,
      required this.mealDepend});

  String get getName => medicineName;
  String get getInterval => interval;
  String get getStartTime => startTime;
  int get getIDs => notificationID;
  String get getMealDepend => mealDepend;

  Map<String, dynamic> toJson() {
    return {
      "ids": this.notificationID,
      "name": this.medicineName,
      "interval": this.interval,
      "start_time": this.startTime,
      "start_date": this.startDate,
      'meal_dependency': this.mealDepend
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> parsedJson) {
    return Medicine(
        notificationID: parsedJson['ids'],
        medicineName: parsedJson['name'],
        interval: parsedJson['interval'],
        startTime: parsedJson['start_time'],
        startDate: parsedJson['start_date'],
        mealDepend: parsedJson['meal_dependency']);
  }

  // Save list of medicines to SharedPreferences
  static Future<void> saveMedicines(List<Medicine> medicines) async {
    SharedPreferences prefs_ = await SharedPreferences.getInstance();
    List<String> medicineStrings =
        medicines.map((med) => json.encode(med.toJson())).toList();
    await prefs_.setStringList('medicines', medicineStrings);
  }

  // Retrieve list of medicines from SharedPreferences
  static Future<List<Medicine>> loadMedicines() async {
    SharedPreferences prefs_ = await SharedPreferences.getInstance();
    List<String>? medicineStrings = prefs_.getStringList('medicines');
    if (medicineStrings != null) {
      return medicineStrings
          .map((str) => Medicine.fromJson(json.decode(str)))
          .toList();
    }
    return [];
  }
}
