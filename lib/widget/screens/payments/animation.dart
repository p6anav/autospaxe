import 'package:autospaze/widget/models/user.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:autospaze/widget/screens/invoice/invoice_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessAnimationPage extends StatefulWidget {
  const SuccessAnimationPage({super.key});

  @override
  State<SuccessAnimationPage> createState() => _SuccessAnimationPageState();
}

class _SuccessAnimationPageState extends State<SuccessAnimationPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.green).animate(_controller);
    _controller.forward();

    // Release the slot and navigate after 5 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       // First, update the parking slot status
      await updateParkingSlotStatus(context, status: 'BOOKED');
      print('Parking slot status updated to BOOKED');

      // Then, release the slot
      await releaseSlot(context);
      print('Slot released successfully');

      // Navigate to the InvoicePage after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InvoicePage(userId: ''),
          ),
        );
      });
    });
  }
Future<void> updateParkingSlotStatus(BuildContext context, {String status = 'BOOKED'}) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final User? user = userProvider.user;

  if (user == null) {
    throw Exception('User data is not available');
  }

  final userId = user.id;
  final statusUrl = Uri.parse('https://genuine-sindee-43-76539613.koyeb.app/api/parking-slots/status');

  print('Updating status for userId: $userId with status: $status');
  print('Query Parameters: userId=$userId, status=$status');
  print('Request URL: ${statusUrl.replace(queryParameters: {'userId': userId, 'status': status})}');

  try {
    // Make the PUT request with query parameters
    final response = await http.put(
      statusUrl.replace(queryParameters: {
        'userId': userId,
        'status': status,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Check the response status code
    if (response.statusCode == 204) {
      // Request was successful (no content)
      print('Parking slot status updated successfully');
    } else if (response.statusCode == 404) {
      // Resource not found
      throw Exception('User not found');
    } else {
      // Other error
      print('Response Body: ${response.body}');
      throw Exception('Failed to update parking slot status: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    print('Error updating parking slot status: $e');
    throw Exception('Error updating parking slot status: $e');
  }
}
  Future<void> releaseSlot(BuildContext context) async {
    // Get the user ID from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User? user = userProvider.user;

    if (user == null) {
      throw Exception('User data is not available');
    }

    final userId = user.id;

    // Get the slot ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? slotId = prefs.getString('slot_id');

    if (slotId == null) {
      throw Exception('Slot ID is not available');
    }

    // Define the base URL for releasing the slot
    String baseUrl = 'https://genuine-sindee-43-76539613.koyeb.app/api/parking-slots/$slotId/release';

    // Define the query parameters
    Map<String, String> queryParams = {
      'userId': userId,
    };

    // Construct the full URL with query parameters
    Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    // Make the PATCH request to release the slot
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      print('Slot released successfully');
    } else {
      print('Failed to release slot: ${response.body}');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: _colorAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: const Icon(
                      Icons.check_circle,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment successful',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}