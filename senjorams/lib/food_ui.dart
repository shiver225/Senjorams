import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:senjorams/services/api_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';
import 'package:flutter/services.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _consumedFoodController = TextEditingController();
  bool _isLoading = false;
  final translator = GoogleTranslator();
  Map<String, dynamic>? _foodData;
  double? _dailyCaloriesNeeded;
  Map<String, dynamic> _totalNutritionIntake = {};
  List<String> _consumedFoodsHistory = [];

  late String _timeString = '';
  late var timer;

  @override
  void initState() {
    super.initState();
    _fetchDailyCaloriesNeeded();
    _fetchFoodHistory();

    _updateTime(); // Update time initially
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat.Hms().format(now);
    });
  }

  // Function to retrieve daily calories needed from Firestore
  void _fetchDailyCaloriesNeeded() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('dailyCaloriesNeeded')) {
            setState(() {
              _dailyCaloriesNeeded = userData['dailyCaloriesNeeded'];
            });
          } else {
            // Show dialog to input user information and calculate daily calories needed
            _openUserInfoDialog();
          }
        } else {
          // Show dialog to input user information and calculate daily calories needed
          _openUserInfoDialog();
        }
      } catch (e) {
        print('Error fetching daily calories needed: $e');
      }
    }
    setState(() {});
  }

  // Function to retrieve daily calories needed from Firestore
  void _fetchFoodHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('consumedFoodHistory')) {
            setState(() {
              _consumedFoodsHistory = userData['consumedFoodHistory'];
            });
          } else {
            // Show dialog to input user information and calculate daily calories needed
            _openUserInfoDialog();
          }
        } else {
          // Show dialog to input user information and calculate daily calories needed
          _openUserInfoDialog();
        }
      } catch (e) {
        print('Error fetching food history: $e');
      }
    }
    setState(() {});
  }


  // Function to open dialog for inputting user information
  void _openUserInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Colors.white.withOpacity(0.9), // Change background color
          ),
          child: AlertDialog(
            title: const Text(
              'Dienos maistinės vertės',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Change title font and color
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Svoris (kg)',
                    labelStyle: TextStyle(color: Colors.black), // Change label text color
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Ūgis (cm)',
                    labelStyle: TextStyle(color: Colors.black), // Change label text color
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Amžius',
                    labelStyle: TextStyle(color: Colors.black), // Change label text color
                  ),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    _calculateDailyCaloriesNeeded();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF92C7CF).withOpacity(0.7), // Change button color
                    textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Change button text style
                  ),
                  child: const Text(
                    'Skaičiuoti',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      },
    );
  }


  // Function to calculate daily calories needed and save user info to Firestore
  void _calculateDailyCaloriesNeeded() async {
    // Retrieve user input
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    int age = int.tryParse(_ageController.text) ?? 0;

    // Perform calculation (example formula)
    // You can replace this with a formula suitable for your app
    double basalMetabolicRate = 10 * weight + 6.25 * height - 5 * age + 5;
    _dailyCaloriesNeeded = basalMetabolicRate * 1.2; // Assuming light activity level

    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save user info and daily calories needed to Firestore
      try {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'weight': weight,
          'height': height,
          'age': age,
          'dailyCaloriesNeeded': _dailyCaloriesNeeded,
          'consumedFoodHistory': _consumedFoodsHistory,
        });
      } catch (e) {
        print('Error saving user info to Firestore: $e');
      }
    }

    setState(() {}); // Trigger a rebuild to update the UI with the calculated value
  }

  get foodName => _foodNameController.text.trim();

  void _fetchFoodNutrition() async {
    final foodName = _foodNameController.text.trim();
    if (foodName.isNotEmpty) {
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });
      try {
        final translatedFoodName = await translator.translate(foodName, to: 'en');
        final foodToFetch = translatedFoodName.text.trim();
        final List<dynamic> foodList = await FoodAPI.fetchFoodNutrition(foodToFetch);
        if (foodList.isNotEmpty) {
          setState(() {
            _foodData = foodList.first;
          });
        }
      } catch (e) {
        print('Klaida: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFoodNutrition() {
    if (_foodData != null) {
      return Expanded(
        child: Card(
          color: const Color(0xFF92C7CF).withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          _buildNutritionInfo('Pavadinimas', foodName),
                          _buildNutritionInfo('Kalorojos', _foodData!['calories']),
                          _buildNutritionInfo('Porcijos dydis (g)', _foodData!['serving_size_g']),
                          _buildNutritionInfo('Bendras riebalų kiekis (g)', _foodData!['fat_total_g']),
                          _buildNutritionInfo('Sotieji riebalai (g)', _foodData!['fat_saturated_g']),
                          _buildNutritionInfo('Baltymai (g)', _foodData!['protein_g']),
                          _buildNutritionInfo('Natris (mg)', _foodData!['sodium_mg']),
                          _buildNutritionInfo('Kalis (mg)', _foodData!['potassium_mg']),
                          _buildNutritionInfo('Cholesterolis (mg)', _foodData!['cholesterol_mg']),
                          _buildNutritionInfo('Bendras angliavandenių kiekis (g)', _foodData!['carbohydrates_total_g']),
                          _buildNutritionInfo('Skaidulos (g)', _foodData!['fiber_g']),
                          _buildNutritionInfo('Cukrus (g)', _foodData!['sugar_g']),
                        ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(); // Return an empty container if food data is null
    }
  }

  void _calculateTotalNutritionIntake(String consumedFood) async {
    _totalNutritionIntake.clear();
    final List<String> foodItems = consumedFood.split(',');
    for (String foodItem in foodItems) {
      final translatedFoodName = await translator.translate(foodItem.trim(), to: 'en');
      final foodToFetch = translatedFoodName.text.trim();
      final List<dynamic> foodList = await FoodAPI.fetchFoodNutrition(foodToFetch);
      if (foodList.isNotEmpty) {
        final Map<String, dynamic> foodData = foodList.first;
        foodData.forEach((key, value) {
          if (_totalNutritionIntake.containsKey(key)) {
            _totalNutritionIntake[key] += value;
          } else {
            _totalNutritionIntake[key] = value;
          }
        });
      }
    }
    setState(() {});
  }
  

  Widget _buildTotalNutritionIntake() {
    return Expanded(
      child: SingleChildScrollView(
        child: Card(
          color: const Color(0xFF92C7CF).withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Visos maistinės vertės',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                              _buildNutritionInfo('Kalorojos', _totalNutritionIntake['calories']),
                              _buildNutritionInfo('Porcijos dydis (g)', _totalNutritionIntake['serving_size_g']),
                              _buildNutritionInfo('Bendras riebalų kiekis (g)', _totalNutritionIntake['fat_total_g']),
                              _buildNutritionInfo('Sotieji riebalai (g)', _totalNutritionIntake['fat_saturated_g']),
                              _buildNutritionInfo('Baltymai (g)', _totalNutritionIntake['protein_g']),
                              _buildNutritionInfo('Natris (mg)', _totalNutritionIntake['sodium_mg']),
                              _buildNutritionInfo('Kalis (mg)', _totalNutritionIntake['potassium_mg']),
                              _buildNutritionInfo('Cholesterolis (mg)', _totalNutritionIntake['cholesterol_mg']),
                              _buildNutritionInfo('Bendras angliavandenių kiekis (g)', _totalNutritionIntake['carbohydrates_total_g']),
                              _buildNutritionInfo('Skaidulos (g)', _totalNutritionIntake['fiber_g']),
                              _buildNutritionInfo('Cukrus (g)', _totalNutritionIntake['sugar_g']),
                            ],
                  ),
                const SizedBox(height: 10.0),
                if (_dailyCaloriesNeeded != null && _totalNutritionIntake.isNotEmpty)
                  ..._buildRemainingNutritionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRemainingNutritionInfo() {
    final remainingCaloriesIntake = _calculateRemainingCaloriesIntake();
    if (remainingCaloriesIntake != null) {
      return [
        const SizedBox(height: 20.0),
        Text(
          'Liko suvartoti kalorijų: $remainingCaloriesIntake',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ];
    }
    return [];
  }

  String _calculateRemainingCaloriesIntake() {
    if (_dailyCaloriesNeeded != null && _totalNutritionIntake.isNotEmpty) {
      // Calculate total calories intake
      double totalCaloriesIntake = 0;
      _totalNutritionIntake.forEach((key, value) {
        if (key == 'calories') {
          totalCaloriesIntake += value;
        }
      });
      // Calculate remaining calories intake
      double remainingCalories = _dailyCaloriesNeeded! - totalCaloriesIntake;
      return remainingCalories.toStringAsFixed(2); // Convert to string with 2 decimal places
    }
    return '';
  }

  void _showConsumedFoodsHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Colors.white.withOpacity(0.9), // Change background color
            textTheme: TextTheme( // Change text font and color
              bodyText1: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          child: AlertDialog(
            title: const Text(
              'Dienos istorija',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Change title font and color
            ),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _consumedFoodsHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      _consumedFoodsHistory[index],
                      style: TextStyle(color: Colors.black), // Change content text color
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 206, 178, 129).withOpacity(0.1), // Change button color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text(
                    'Uždaryti',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Change button text style
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 30), // Adjust the left padding as needed
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Adjust the padding as needed
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openUserInfoDialog,
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
        backgroundColor: const Color(0xFF92C7CF),
        title: Text(
          _timeString,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Įveskite norimą maistą ar produktą',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZĄąČčĘęĖėĮįŠšŲųŪūŽž\s]')),
              ],
            ),
            const SingleChildScrollView(child: SizedBox(height: 20.0)),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                _fetchFoodNutrition();
                FocusScope.of(context).unfocus(); // Hide keyboard
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Color.fromARGB(255, 206, 178, 129),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Gauti maistines medžiagas',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
            ),
            const SingleChildScrollView(child: SizedBox(height: 20.0)),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_foodData != null)
              _buildFoodNutrition(),
            if (_dailyCaloriesNeeded != null)
              _buildNutritionInfo('Per dieną reikia kalorijų: ', _dailyCaloriesNeeded),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _consumedFoodController,
              decoration: InputDecoration(
                labelText: 'Įveskite suvartotą maistą šiandien (atskirta kableliais)',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZĄąČčĘęĖėĮįŠšŲųŪūŽž\s,]')),
              ],
            ),
            const SingleChildScrollView(child: SizedBox(height: 20.0)),
            ElevatedButton(
              onPressed: () {
                _calculateTotalNutritionIntake(_consumedFoodController.text);
                _consumedFoodsHistory.add(_consumedFoodController.text);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Color.fromARGB(255, 206, 178, 129),
              ),
              child: const Text(
                'Apskaičiuoti visas maistines medžiagas',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
            ),
            const SizedBox(height: 20.0),
            if (_totalNutritionIntake.isNotEmpty)
              _buildTotalNutritionIntake(),
            if (_consumedFoodsHistory.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _showConsumedFoodsHistory();
                },
                style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Color.fromARGB(255, 206, 178, 129),
              ),
                child: const Text(
                  'Dienos istorija',
                  style: TextStyle(color: Colors.white, fontSize: 16.0)
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            '$value',
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
