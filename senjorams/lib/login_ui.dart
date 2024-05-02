// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senjorams/main_screen_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, this.loginCode}) : super(key: key);
  final String? loginCode;
  

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseFirestore.instance;
  


  String _loginCode = '';

  @override
  void initState() {
    super.initState();
    // Set the login code from the widget parameter when available
    _loginCode = widget.loginCode ?? '';
  }

  Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Query Firestore for the document with a field 'loginCode' equal to the entered login code
      final querySnapshot = await _database.collection('Users').where('loginCode', isEqualTo: _loginCode).get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        print(userDoc);
        final userEmail = userDoc.data()['email'];
        print(userEmail);
        final userPassword = userDoc.data()['password'];
        print(userPassword);

        // Sign in the user using custom token authentication
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );
        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Neteisingas prisijungimo kodas'),
        ));
      }
    } catch (e) {
      // Handle login errors
      print('Login failed: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Prisijungimas nepavyko: $e'),
      ));
    }
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
          "Prisijungimas",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prisijungimo kodas',
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
                initialValue: widget.loginCode, // Set initial value here
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prašau įvesti prisijungimo kodą';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _loginCode = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50), // Adjust button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Add button border radius
                  ),
                ),
                child: const Text(
                  'Prisijungti',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
