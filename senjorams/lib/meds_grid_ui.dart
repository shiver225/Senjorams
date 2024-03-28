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
          crossAxisSpacing: 8.0, // Spacing between columns
          mainAxisSpacing: 8.0, // Spacing between rows
        ),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          Medicine medicine = medicines[index];
          return Column(
            children: [
              MedicineItemWidget(
                  medicine: medicine, onDelete: () => onDelete(index)),
            ],
          );
        });
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
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(medicine.medicineName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 4.0),
            Text('${medicine.interval}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 4.0),
            Text('Time: ${medicine.startTime}'),
            SizedBox(height: 4.0),
            Text('Since: ${medicine.startDate}'),
            Center(
              child: IconButton(
                  icon: Icon(Icons.delete), onPressed: onDelete, iconSize: 32),
            )
          ],
        ),
      ),
    );
  }
}

/* List<Medicine> medicines = [
  Medicine(
    notificationID: 1,
    medicineName: 'Medicine 1',
    interval: '8 hours',
    startTime: '08:00 AM',
    startDate: '2024-03-27',
  ),
  Medicine(
    notificationID: 2,
    medicineName: 'Medicine 2',
    interval: '12 hours',
    startTime: '12:00 PM',
    startDate: '2024-03-27',
  ),
  // Add more Medicine objects as needed
]; */
