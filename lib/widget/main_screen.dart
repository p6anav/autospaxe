import 'package:autospaze/widget/screens/invoice/invoice_page.dart';
import 'package:autospaze/widget/screens/status/status.dart';
import 'package:flutter/material.dart';
import 'package:autospaze/widget/screens/bottomnav.dart';
import 'package:autospaze/widget/screens/Home/home_screen.dart';
import 'package:autospaze/widget/screens/maps/maps.dart';
import 'package:autospaze/widget/screens/profile/profile.dart';
import 'package:autospaze/widget/screens/bookmarks/bookmark.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens corresponding to bottom navigation items
  final List<Widget> _screens = [
    HomeScreen(),
    SvgDisplayPage(),  // Maps screen with DateTimePicker
    InvoicePage(userId: '',),     // Bookmarks screen
    Profile(),        // Profile screen
  ];

  // List of colors corresponding to each screen
  final List<Color> _screenColors = [
    const Color.fromARGB(255, 39, 38, 38), // HomeScreen
    const Color.fromARGB(255, 39, 38, 38),  // SvgDisplayPage
    const Color.fromARGB(238, 214, 214, 225), // Bookmarker
    const Color.fromARGB(238, 225, 214, 225), // Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: _screenColors[_currentIndex], // Use the color from the list
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: Bottomnav(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}