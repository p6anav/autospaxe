import 'package:autospaze/widget/screens/onboardingscreen/screen.dart';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart'; // Import the onboarding screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomInAnimation;
  late Animation<double> _zoomOutAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Total animation duration
    );

    // Define zoom-in and zoom-out animations
    _zoomInAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut), // First half for zoom-in
      ),
    );
    _zoomOutAnimation = Tween<double>(begin: 1.5, end: 2.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut), // Second half for zoom-out
      ),
    );

    // Start the animation
    _controller.forward();

    // Transition to the onboarding screen after splash animation completes
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>   ImageSlider()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Splash screen background color
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Combine zoom-in and zoom-out animations
            double scale = _zoomInAnimation.value;
            if (_controller.value > 0.5) {
              scale = _zoomOutAnimation.value;
            }
            return Opacity(
              opacity: _controller.value, // Fade in effect
              child: Transform.scale(
                scale: scale, // Apply combined zoom effect
                child: child,
              ),
            );
          },
          child: Image.network(
            'https://res.cloudinary.com/dwdatqojd/image/upload/v1738778483/knnx_ioyjrq.png', // Replace with your network image URL
            width: 80, // Adjust size of logo
            height: 80,
            fit: BoxFit.contain, // Adjust the fit property as needed
          ),
        ),
      ),
    );
  }
}