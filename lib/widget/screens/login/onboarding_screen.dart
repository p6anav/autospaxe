import 'package:flutter/material.dart';
import 'login_page.dart'; // Corrected import for LoginPage
import 'signup_page.dart'; // Corrected import for SignUpPage

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: <Widget>[
           Container(
          width: double.infinity, // Full width
          height: double.infinity, // Full height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C2B34), // First color
                Color(0xFF232325), // Second color
              ],
              begin: Alignment.topLeft, // Gradient starts from the top-left corner
              end: Alignment.bottomRight, // Gradient ends at the bottom-right corner
            ),
          ),
        ),
          // Onboarding screen content
          SizedBox(
            width: double.infinity, // Full width
            height: double.infinity, // Full height
            // 90 degrees in radians
        child: Image.network(
          'https://res.cloudinary.com/dwdatqojd/image/upload/v1738773303/Acar_cznfm1.png', // Your network image URL
          width: 600, // Adjust size of logo
          height: 800,
          fit: BoxFit.contain, // Adjust the fit property as needed
        
      ),
    ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  '',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 550),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
