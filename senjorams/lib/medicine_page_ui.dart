import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:alarm/alarm.dart';
import 'package:senjorams/models/medicine.dart';
import 'dart:math';
import 'package:senjorams/meds_grid_ui.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({Key? key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  late List<Medicine> medicines = []; // List to store medicine names
  final TextEditingController _medicineController = TextEditingController();

  final List<String> items = [
    'Every 6 hours',
    'Every 12 hours',
    'Once per day',
    'Once per week',
  ];
  String selectedValue = 'Every 6 hours';
  @override
  void initState() {
    super.initState();
    loadMedicines(); // Load medicines when the screen is initialized
  }

  @override
  void dispose() {
    Medicine.saveMedicines(medicines);
    super.dispose();
  }

  Future<void> loadMedicines() async {
    // Load medicines from storage
    medicines = await Medicine.loadMedicines();
    setState(() {}); // Update the UI after loading medicines
  }

  void deleteMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
      Medicine.saveMedicines(medicines);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              /*
            child: ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(medicines[index]),
                );
              },
            ),*/
              child: MedicineGridWidget(
            medicines: medicines,
            onDelete: deleteMedicine,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddMedicineDialog(
                items: items,
                onMedicineAdded: (medicineName, frequency, date, time) {
                  setState(() {
                    Medicine newMedicine = Medicine(
                        notificationID: generateInteger(),
                        medicineName: medicineName,
                        startTime: time,
                        startDate: date,
                        interval: frequency);
                    medicines.add(newMedicine);
                    Medicine.saveMedicines(medicines);
                  });
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddMedicineDialog extends StatefulWidget {
  final List<String> items;
  final Function(String, String, String, String) onMedicineAdded;

  const AddMedicineDialog({
    Key? key,
    required this.items,
    required this.onMedicineAdded,
  }) : super(key: key);

  @override
  _AddMedicineDialogState createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  String selectedValue = 'Every 6 hours';
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _medicineController;

  @override
  void initState() {
    super.initState();
    _medicineController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _medicineController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Medicine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _medicineController,
            decoration: InputDecoration(
              hintText: 'Medicine Name',
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              items: widget.items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedValue = value!;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Select Start Date'),
              ),
              SizedBox(width: 10),
              Text(_selectedDate.toString().split(' ')[0]),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text('Select Start Time'),
              ),
              SizedBox(width: 10),
              Text(_selectedTime.format(context)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onMedicineAdded(
              _medicineController.text,
              selectedValue,
              _selectedDate.toString().split(' ')[0],
              _selectedTime.format(context),
            );
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

int generateInteger() {
  DateTime now = DateTime.now();
  int year = now.year % 100; // taking only last two digits of the year
  int month = now.month;
  int day = now.day;
  int hour = now.hour;
  int minute = now.minute;

  int result = year * 10000000000 +
      month * 100000000 +
      day * 1000000 +
      hour * 10000 +
      minute * 100;

  // Adding a random integer between 1 and 99
  Random random = Random();
  int randomInt = random.nextInt(99) + 1;

  result += randomInt;

  return result;
}
