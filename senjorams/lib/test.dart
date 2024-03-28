import 'package:flutter/material.dart';
import 'package:senjorams/services/api_services.dart';
import 'package:translator/translator.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _foodNameController = TextEditingController();
  bool _isLoading = false;
  final translator = GoogleTranslator();
  Map<String, dynamic>? _foodData;

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
        backgroundColor: const Color(0xFF92C7CF),
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
              onPressed: _isLoading ? null : _fetchFoodNutrition,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: const Color(0xFF92C7CF),
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
                  color: const Color(0xFF92C7CF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
