import 'package:flutter/material.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  List<String> foods = []; // List to store the entered foods

  TextEditingController foodController = TextEditingController(); // Controller for the text field

  // Function to add food to the list
  void addFood(String food) {
    setState(() {
      foods.add(food);
      foodController.clear(); // Clear the text field after adding the food
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: foodController,
              decoration: InputDecoration(labelText: 'Enter food'),
              onSubmitted: (value) {
                addFood(value);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addFood(foodController.text);
              },
              child: Text('Add Food'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(foods[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}