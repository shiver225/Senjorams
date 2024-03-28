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

  void _fetchFoodNutrition() async {
    final foodName = _foodNameController.text.trim();
    if (foodName.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final translatedFoodName = await translator.translate(foodName, to: 'en');
        final foodToFetch = translatedFoodName.text.trim();
        print('Translated Food Name: $foodToFetch');
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
        title: Text('Maisto medžiagos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Įveskite maisto pavadinimą',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _fetchFoodNutrition(),
              child: Text('Gauti maistines medžiagas'),
            ),
            SizedBox(height: 16.0),
            if (_isLoading)
              CircularProgressIndicator(),
            if (!_isLoading && _foodData == null)
              Column(
                children: [
                  Text('Maistinės medžiagos bus padorytos čia'),
                ],
              ),
            if (_foodData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pavadinimas: ${_foodData!['name']}'),
                  Text('Kalorojos: ${_foodData!['calories']}'),
                  Text('Porcijos dydis (g): ${_foodData!['serving_size_g']}'),
                  Text('Bendras riebalų kiekis (g): ${_foodData!['fat_total_g']}'),
                  Text('Sotieji riebalai (g): ${_foodData!['fat_saturated_g']}'),
                  Text('Baltymai (g): ${_foodData!['protein_g']}'),
                  Text('Natris (mg): ${_foodData!['sodium_mg']}'),
                  Text('Kalis (mg): ${_foodData!['potassium_mg']}'),
                  Text('Cholesterolis (mg): ${_foodData!['cholesterol_mg']}'),
                  Text('Bendras angliavandenių kiekis (g): ${_foodData!['carbohydrates_total_g']}'),
                  Text('Skaidulos (g): ${_foodData!['fiber_g']}'),
                  Text('Cukrus (g): ${_foodData!['sugar_g']}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
