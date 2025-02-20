import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:autospaze/widget/screens/login/login_page.dart';
import 'package:autospaze/widget/screens/login/onboarding_screen.dart';
import 'package:autospaze/widget/screens/login/signup_page.dart';
import 'package:autospaze/widget/screens/login/test.dart';
import 'package:autospaze/widget/screens/home/test.dart';

import 'package:flutter/material.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/screens/login/splash_screen.dart';
import 'package:autospaze/widget/screens/Home/vehicle.dart';
import 'package:autospaze/widget/screens/maps/maps.dart';
import 'package:autospaze/widget/screens/maps/test.dart';
import 'package:autospaze/widget/screens/Home/vehi.dart';
import 'package:provider/provider.dart';
import 'package:autospaze/widget/screens/onboardingscreen/screen.dart';

// Import your MainScreen class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
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
      home:LoginPage(), // Use MainScreen as the home widget
    );
  }
}