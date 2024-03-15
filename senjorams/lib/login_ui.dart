import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senjorams/main_screen_ui.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid login code'),
        ));
      }
    } catch (e) {
      // Handle login errors
      print('Login failed: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: $e'),
      ));
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Login Code'),
                initialValue: widget.loginCode, // Set initial value here
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your login code';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _loginCode = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
