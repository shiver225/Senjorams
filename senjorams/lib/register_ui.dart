import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:senjorams/login_ui.dart';
import 'package:senjorams/medicine_page_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseFirestore.instance;
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  DateTime? _dob;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    //_dobController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

   void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    //_pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Slaptažodžiai neatitinka'),
        ));
        return;
      }

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        final user = userCredential.user;
        final loginCode = _generateLoginCode();
        if (user != null) {
          // Save user data to Firebase Realtime Database
          await _database.collection('Users').doc(user.uid).set({
            'email': _emailController.text,
            'password': _passwordController.text,
            'name': _nameController.text,
            'surname': _surnameController.text,
            'dob': _dob?.toIso8601String(),
            'phoneNumber': _phoneNumberController.text,
            'loginCode': loginCode,
          });

          await _sendLoginCodeEmail(_emailController.text, loginCode);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(loginCode: loginCode)),
          );
        }
      } catch (e) {
        // Handle registration errors
        print('Registration failed: $e');
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registracija nepavyko: $e'),
        ));
      }
    }
  }

  String _generateLoginCode() {
    final random = Random();
    final roomNumber = random.nextInt(1000); // Generate a random 3-digit number
    final randomLetter = String.fromCharCode(random.nextInt(6) + 65); // Generate a random letter from A to F
    return 'RM$roomNumber$randomLetter';
  }
  
  Future<void> _sendLoginCodeEmail(String email, String loginCode) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendLoginCodeEmail');
    try {
      await callable.call({'email': email, 'loginCode': loginCode});
      print('Login code email sent successfully.');
    } catch (error) {
      print('Error sending login code email: $error');
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 30), // Adjust the left padding as needed
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
        backgroundColor: const Color(0xFF92C7CF),
        title: const Text(
          "Registracija",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swiping
          children: [
            _buildTextField("El. paštas", _emailController, TextInputType.emailAddress, _nextPage),
            // _buildTextField("Slaptažodis", _passwordController, TextInputType.visiblePassword, _nextPage),
            // _buildTextField("Patvirtinkite slaptažodį", _confirmPasswordController, TextInputType.visiblePassword, _nextPage),
            _buildPasswordFields(), // Combine Slaptažodis and Patvirtinkite slaptažodį on the same page
            _buildTextField("Vardas", _nameController, TextInputType.name, _nextPage),
            _buildTextField("Pavardė", _surnameController, TextInputType.name, _nextPage),
            _buildDatePicker("Gimimo data", _dobController, _nextPage),
            _buildRegisterField("Telefono numeris", _phoneNumberController, TextInputType.phone, _register),      
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _register, // Call the _register function when the button is pressed
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50), // Adjust button padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Add button border radius
          ),
        ),
        child: const Text(
          'Registruotis',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: 'Slaptažodis',
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Prašome įvesti slaptažodį';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(
              labelText: 'Patvirtinkite slaptažodį',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Prašome patvirtinti slaptažodį';
              }
              if (value != _passwordController.text) {
                return 'Slaptažodžiai nesutampa';
              }
              return null;
            },
            onFieldSubmitted: (_) => _nextPage(),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50), // Adjust button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Add button border radius
              ),
            ),
            child: const Text(
              'Kitas',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, void Function() onNext) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red), // Set error border color
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Prašome užpildyti šį lauką';
              }
              return null;
            },
            onFieldSubmitted: (_) => onNext(),
          ),
          const SizedBox(
            height: 10,
            width: 5,
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 50), // Adjust button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Add button border radius
              ),
            ),
            child: const Text(
              'Kitas',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterField(String label, TextEditingController controller, TextInputType keyboardType, void Function() onNext) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red), // Set error border color
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Prašome užpildyti šį lauką';
              }
              return null;
            },
            onFieldSubmitted: (_) => onNext(),
          ),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50), // Adjust button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Add button border radius
              ),
            ),
            child: const Text(
              'Registruotis',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller, void Function() onNext) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF92C7CF)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red), // Set error border color
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  _dob = pickedDate;
                });
              }
            },
          ),

          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50), // Adjust button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Add button border radius
              ),
            ),
            child: const Text(
              'Kitas',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}
