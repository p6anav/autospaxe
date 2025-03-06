import 'package:autospaze/widget/providers/ParkingProvider.dart';
import 'package:autospaze/widget/screens/Home/tesingmap.dart';
import 'package:autospaze/widget/screens/Home/vehicle.dart';
import 'package:autospaze/widget/screens/bookings/DateTimePickerPage.dart';

import 'package:autospaze/widget/screens/login/login_page.dart';
import 'package:autospaze/widget/screens/login/test.dart';
import 'package:autospaze/widget/screens/maps/maps.dart';
import 'package:autospaze/widget/screens/status/status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/screens/login/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Example of handling async initialization (if needed)
  try {
    // Perform any async initialization here
    // await someAsyncInitialization();
  } catch (e) {
    // Handle initialization errors
    print('Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ParkingProvider()),
        // Add other providers here
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:LoginPage(), // Use SplashScreen as the home widget
    );
  }
}