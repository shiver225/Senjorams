import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:senjorams/login_ui.dart';
import 'package:senjorams/main_screen_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _name = '';
  String _surname = '';
  DateTime? _dob;
  String _phoneNumber = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final user = userCredential.user;
        if (user != null) {
          // Save user data to Firebase Realtime Database
          await _database.child('users').child(user.uid).set({
            'email': _email,
            'name': _name,
            'surname': _surname,
            'dob': _dob?.toIso8601String(),
            'phoneNumber': _phoneNumber,
          });
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen())
          );
        }
      } catch (e) {
        // Handle registration errors
        print('Registration failed: $e');
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration failed: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _confirmPassword = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Surname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your surname';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _surname = value;
                  });
                },
              ),
              // Date of Birth picker
              // You can use a DatePicker or any other widget to select date of birth
              // Here's a basic example using a TextFormField
              TextFormField(
                decoration: InputDecoration(labelText: 'Date of Birth'),
                readOnly: true,
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dob = selectedDate;
                    });
                  }
                },
                validator: (value) {
                  if (_dob == null) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: _dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : '',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
