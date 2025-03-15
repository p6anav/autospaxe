import 'package:autospaze/widget/screens/bookings/loadingbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Dark background
        primaryColor: const Color.fromARGB(255, 13, 54, 189),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 251, 250, 250)), // White text for readability
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 13, 54, 189),
            foregroundColor: const Color.fromARGB(255, 253, 253, 253),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const QRHomePage(),
    );
  }
}

class QRHomePage extends StatelessWidget {
  const QRHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define responsive sizes based on screen dimensions
    final qrSize = screenWidth * 0.4; // QR code size as 40% of screen width
    final fontSize = screenWidth * 0.04; // Font size scales with screen width
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.08, // 8% of screen width
      vertical: screenHeight * 0.02, // 2% of screen height
    );
    final spacing = screenHeight * 0.05; // Spacing as 5% of screen height

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)], // Dark gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Expanded to push the bottom content down
            Expanded(
              child: Center(
                child: Container(
                  width: qrSize, // Responsive QR code size
                  height: qrSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 13, 54, 189),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(255, 44, 42, 42), // Keep white background for QR code
                  ),
                  child: Image.network(
                    'https://res.cloudinary.com/dwdatqojd/image/upload/v1741974724/qr_nbuplk.png', // Path to your PNG file
                    fit: BoxFit.contain, // Ensures the image fits within the container
                  ),
                ),
              ),
            ),
            // Bottom section with Text and Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.08), // 5% padding from the bottom
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text below QR code
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // 10% padding on sides
                      child: Text(
                        'Go and enjoy our features for free and\nmake your life easy with us.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 251, 251),
                          fontSize: fontSize, // Responsive font size
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 0.5), // Smaller spacing between Text and Button
                    // Let's Start Button
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Button Pressed!')),
                        );
                         Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen(),
                      ),
                    );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 13, 54, 189),
                        padding: buttonPadding, // Responsive padding
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Let\'s Start',
                            style: TextStyle(fontSize: fontSize * 1.2), // Slightly larger font for button
                          ),
                          SizedBox(width: screenWidth * 0.02), // Responsive spacing
                          Icon(
                            Icons.arrow_forward,
                            size: fontSize * 1.2, // Responsive icon size
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}