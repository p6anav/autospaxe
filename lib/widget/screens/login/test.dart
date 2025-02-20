// test_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:autospaze/widget/services/api_service.dart'; // Import ApiService
// test_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 // Import ApiService

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final apiService = ApiService();
      _vehicles = await apiService.getVehiclesByUserId(userId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vehicles: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVehicles(); // Fetch vehicles when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicles:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ..._vehicles.map((vehicle) => ListTile(
                        title: Text(vehicle['vehicleNumber']),
                        subtitle: Text('${vehicle['brand']} ${vehicle['model']} - ${vehicle['color']}'),
                      )),
                ],
              ),
            ),
    );
  }
}