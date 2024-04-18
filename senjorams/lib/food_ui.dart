import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchDailyCaloriesNeeded();
    _fetchFoodHistory();
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
        return AlertDialog(
          title: const Text('Dienos maistinės vertės'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Svoris (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Ūgis (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Amžius'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  _calculateDailyCaloriesNeeded();
                  Navigator.of(context).pop();
                },
                child: const Text('Skaičiuoti'),
              ),
            ],
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
          color: Colors.lightBlueAccent.withOpacity(0.1),
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
          color: Colors.lightBlueAccent.withOpacity(0.1),
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
        return AlertDialog(
          title: const Text('Dienos istorija'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _consumedFoodsHistory.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_consumedFoodsHistory[index]),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Uždaryti'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Maisto medžiagos',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
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
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.lightBlueAccent,
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
            ElevatedButton(
              onPressed: _openUserInfoDialog,
              child: const Text('Apskaičiuoti dienos maistines vertes'),
            ),
            if (_dailyCaloriesNeeded != null)
              _buildNutritionInfo('Per dieną reikia kalorijų: ', _dailyCaloriesNeeded),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _consumedFoodController,
              decoration: InputDecoration(
                labelText: 'Įveskite suvartotą maistą šiandien (atskirta kableliais)',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
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
              child: const Text('Apskaičiuoti visą maistinę vertę'),
            ),
            const SizedBox(height: 20.0),
            if (_totalNutritionIntake.isNotEmpty)
              _buildTotalNutritionIntake(),
            if (_consumedFoodsHistory.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _showConsumedFoodsHistory();
                },
                child: const Text('Dienos istorija'),
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
