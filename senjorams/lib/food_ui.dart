import 'package:flutter/material.dart';
import 'package:senjorams/services/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';

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
  bool _isLoading = false;
  final translator = GoogleTranslator();
  Map<String, dynamic>? _foodData;
  double? _dailyCaloriesNeeded;

  // Function to open dialog for inputting user information
  void _openUserInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Daily Nutrition Needs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  _calculateDailyCaloriesNeeded();
                  Navigator.of(context).pop();
                },
                child: Text('Calculate'),
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

    // Save user info and daily calories needed to Firestore
    try {
      await FirebaseFirestore.instance.collection('Users').add({
        'weight': weight,
        'height': height,
        'age': age,
        'dailyCaloriesNeeded': _dailyCaloriesNeeded,
      });
    } catch (e) {
      print('Error saving user info to Firestore: $e');
    }

    setState(() {}); // Trigger a rebuild to update the UI with the calculated value
  }

  get foodName => _foodNameController.text.trim();

  void _fetchFoodNutrition() async {
    final foodName = _foodNameController.text.trim();
    if (foodName.isNotEmpty) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });
      try {
        final translatedFoodName = await translator.translate(foodName, to: 'en');
        final foodToFetch = translatedFoodName.text.trim();
        final List<dynamic> foodList = await FoodAPI.fetchFoodNutrition(foodToFetch);
        // Handle retrieved food data
        if (foodList.isNotEmpty) {
          setState(() {
            _foodData = foodList.first;
          });
        }
      } catch (e) {
        // Handle error
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Maisto medžiagos',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0, // Remove app bar shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Įveskite maisto pavadinimą',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                _fetchFoodNutrition();
                FocusScope.of(context).unfocus(); // Hide keyboard
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Gauti maistines medžiagas',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
            ),
            ElevatedButton(
              onPressed: _openUserInfoDialog, // Open user info dialog
              child: Text('Calculate Daily Nutrition Needs'),
            ),
            // Display daily nutrition needs if calculated
            if (_dailyCaloriesNeeded != null)
              _buildNutritionInfo('Daily Calories Needed', _dailyCaloriesNeeded),
            SizedBox(height: 20.0),
            if (_isLoading)
              Center(child: CircularProgressIndicator()),
            if (!_isLoading && _foodData == null)
              Center(
                child: Text(
                  'Maistinės medžiagos bus padorytos čia',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_foodData != null)
              Expanded(
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            '$value',
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}