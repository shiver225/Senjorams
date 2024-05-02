import 'package:flutter/material.dart';
import 'login_ui.dart';
import 'register_ui.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
        backgroundColor: const Color(0xFF92C7CF),
        title: const Text(
        "Sveiki!",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ));
                },
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 206, 178, 129), // Change button color
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50), // Adjust button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Add button border radius
                  ),
                ),
                child: const Text(
                  'Registruotis',
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
