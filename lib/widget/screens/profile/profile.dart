import 'package:flutter/material.dart';


class Profile extends StatelessWidget {
  const  Profile  ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
      ),
      body: const Center(
        child: Text(
          "Welcome to the Profile Screen!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
