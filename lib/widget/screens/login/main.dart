import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the splash_screen.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}
