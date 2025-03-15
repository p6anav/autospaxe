import 'package:flutter/material.dart';
import 'package:autospaze/widget/screens/Home/home_screen.dart';
import 'package:autospaze/widget/screens/maps/maps.dart';
import 'package:autospaze/widget/screens/profile/profile.dart';
import 'package:autospaze/widget/screens/bookmarks/bookmark.dart';

class Bottomnav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const Bottomnav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // List of colors corresponding to each screen
    final List<Color> _navBarColors = [
      const Color.fromARGB(255, 13, 54, 189),      // HomeScreen
     const Color.fromARGB(255, 13, 54, 189),  // SvgDisplayPage
     const Color.fromARGB(255, 13, 54, 189),    // Bookmarker
       const Color.fromARGB(255, 13, 54, 189), // Profile
    ];

    return SafeArea(
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.only(bottom: 16, left: 9, right: 9),
        decoration: BoxDecoration(
          color: _navBarColors[currentIndex], // Use the color from the list
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 49, 48, 48).withOpacity(1.0),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              isSelected: currentIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _buildNavItem(
              icon: Icons.timer_outlined,
              isSelected: currentIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _buildNavItem(
              icon: Icons.qr_code_2_outlined,
              isSelected: currentIndex == 2,
              onTap: () => onItemTapped(2),
            ),
            _buildNavItem(
              icon: Icons.person_2_outlined,
              isSelected: currentIndex == 3,
              onTap: () => onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    double iconSize = 30.0,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white,
            size: iconSize,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}