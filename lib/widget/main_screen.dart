import 'package:flutter/material.dart';
import 'package:autospaze/core/colors/colors.dart';
import 'package:autospaze/widget/screens/bottomnav.dart';

class MainScreen extends StatelessWidget {
  final String welcomeMessage;

  const MainScreen({super.key, this.welcomeMessage = 'Welcome to the Main Screen!'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        backgroundColor: Colors.blue, // Optional: Customize the AppBar color
         // Removes the back button
      ),
      backgroundColor: backgroundcolor, // Use the custom background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            welcomeMessage,
            textAlign: TextAlign.center, // Center the text
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Bottomnav(),
    );
  }
}
