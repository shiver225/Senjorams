import 'package:flutter/material.dart';
import 'package:senjorams/models/medicine.dart';

class MedicineGridWidget extends StatelessWidget {
  final List<Medicine> medicines;
  final Function(int) onDelete;

  MedicineGridWidget({required this.medicines, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid
        crossAxisSpacing: 16.0, // Spacing between columns
        mainAxisSpacing: 16.0, // Spacing between rows
        childAspectRatio: 0.8,
      ),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        Medicine medicine = medicines[index];
        return MedicineItemWidget(
          medicine: medicine,
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}

class MedicineItemWidget extends StatelessWidget {
  final Medicine medicine;
  final Function() onDelete;

  MedicineItemWidget({required this.medicine, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      color: Color.fromARGB(255, 248, 225, 179),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  medicine.medicineName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black, // Matching color with MainScreen
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                'Interval: ${medicine.interval}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Matching color with MainScreen
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                'Start Time: ${medicine.startTime}',
                style: TextStyle(
                  color: Colors.black87, // Matching color with MainScreen
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                'Start Date: ${medicine.startDate}',
                style: TextStyle(
                  color: Colors.black87, // Matching color with MainScreen
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                'Take ${medicine.mealDepend}',
                style: TextStyle(
                  color: Colors.black87, // Matching color with MainScreen
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                  iconSize: 30,
                  color: Colors.red, // Matching color with MainScreen
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
