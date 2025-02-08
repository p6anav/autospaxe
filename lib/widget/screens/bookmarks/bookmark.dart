import 'package:autospaze/widget/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:autospaze/widget/main_screen.dart';

class Bookmarker extends StatelessWidget {
  const  Bookmarker  ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Bookmarker Screen"),
 actions: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(), // Navigate to your MainScreen
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Go Back", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    ),
  ],


      ),
      body: const Center(
        child: Text(
          "Welcome to the Bookmaggrker  Screen!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
