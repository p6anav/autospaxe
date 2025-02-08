import 'package:flutter/material.dart';


class Bookmarker extends StatelessWidget {
  const  Bookmarker  ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Bookmarker Screen"),
      ),
      body: const Center(
        child: Text(
          "Welcome to the Bookmarker  Screen!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
