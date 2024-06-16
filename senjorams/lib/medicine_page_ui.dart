import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:senjorams/models/medicine.dart';
import 'package:senjorams/meds_grid_ui.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({Key? key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  late List<Medicine> medicines = [];
  final TextEditingController _medicineController = TextEditingController();

  late String _timeString = '';
  late var timer;

  @override
  void initState() {
    super.initState();
    loadMedicines();

    _updateTime(); // Update time initially
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    if (!mounted) return;
    setState(() {
      _timeString = DateFormat.Hms().format(now);
    });
  }

  @override
  void dispose() {
    Medicine.saveMedicines(medicines);
    super.dispose();
  }

  Future<void> loadMedicines() async {
    medicines = await Medicine.loadMedicines();
    setState(() {});
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
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 30), // Adjust the left padding as needed
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 25), // Adjust the padding as needed
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showMedicineDialog,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: MedicineGridWidget(
                medicines: medicines,
                onDelete: deleteMedicine,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMedicineDialog(
          onMedicineAdded: (medicineName, frequency, date, time, meal) {
            setState(() {
              Medicine newMedicine = Medicine(
                notificationID: generateInteger(),
                medicineName: medicineName,
                startTime: time,
                startDate: date,
                interval: frequency,
                mealDepend: meal,
              );
              medicines.add(newMedicine);
              Medicine.saveMedicines(medicines);
            });
          },
        );
      },
    );
  }
}

class AddMedicineDialog extends StatefulWidget {
  final Function(String, String, String, String, String) onMedicineAdded;

  const AddMedicineDialog({Key? key, required this.onMedicineAdded})
      : super(key: key);

  @override
  _AddMedicineDialogState createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final TextEditingController _medicineController = TextEditingController();
  String selectedValue = 'Every 6 hours';
  String mealDepend = 'Before meal';

  @override
  void initState() {
    super.initState();
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Medicine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _medicineController,
            decoration: InputDecoration(
              hintText: 'Medicine Name',
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
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedValue,
            items: [
              'Every 6 hours',
              'Every 12 hours',
              'Once per day',
              'Once per week',
            ].map((String item) {
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
            decoration: const InputDecoration(
              labelText: 'Frequency',
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: mealDepend,
            items: [
              "Before meal",
              "During meal",
              "After meal",
            ].map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                mealDepend = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Meal Dependency',
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: const Color(0xFF92C7CF)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Color.fromARGB(255, 221, 195, 149),
                ),
                child: const Text(
                  'Select Start Date',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 10),
              Text(_selectedDate.toString().split(' ')[0]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Color.fromARGB(255, 221, 195, 149),
                ),
                child: const Text(
                  'Select Start Time',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 10),
              Text(_selectedTime.format(context)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black, fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  widget.onMedicineAdded(
                    _medicineController.text,
                    selectedValue,
                    _selectedDate.toString().split(' ')[0],
                    _selectedTime.format(context),
                    mealDepend,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Color.fromARGB(255, 221, 195, 149),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int generateInteger() {
  DateTime now = DateTime.now();
  int year = now.year % 100;
  int month = now.month;
  int day = now.day;
  int hour = now.hour;
  int minute = now.minute;

  int result = year * 10000000000 +
      month * 100000000 +
      day * 1000000 +
      hour * 10000 +
      minute * 100;

  Random random = Random();
  int randomInt = random.nextInt(99) + 1;

  result += randomInt;

  return result;
}
