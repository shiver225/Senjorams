import 'package:flutter/material.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final List<String> medicines = []; // List to store medicine names
  final TextEditingController _medicineController = TextEditingController();

  @override
  void initState(){
    super.initState();
    //
  }

  void addMedicine(String medicineName) {
    setState(() {
      if (medicineName.isNotEmpty) {
        medicines.add(medicineName);
        _medicineController.clear();
      }
    });
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicines'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _medicineController,
              decoration: InputDecoration(
                hintText: 'Enter medicine name',
              ),
              onSubmitted: (value) {
                addMedicine(value);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addMedicine(_medicineController.text);
              },
              child: Text('Add Medicine'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(medicines[index]),
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
