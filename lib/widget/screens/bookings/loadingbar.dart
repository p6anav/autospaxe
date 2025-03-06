import 'package:autospaze/widget/screens/bookmarks/app.dart';
import 'package:autospaze/widget/screens/maps/maps.dart';
import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Loading Bar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Listen for the animation status
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to the next screen after the animation is completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SvgUpdater(searchQuery: '', parkingId: '', parkingSlots: '',)),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 34, 33), // Set the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Animated Loading Bar
            SizedBox(
              width: 200,
              height: 10,
              child: Stack(
                children: [
                  // Background of the loading bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300, // Light grey background
                    ),
                  ),
                  // Animated fill of the loading bar
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 200 * _animation.value,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.green], // Gradient fill
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


