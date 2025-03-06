import 'dart:convert';
import 'package:autospaze/widget/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autospaze/widget/services/api_service.dart'; // Import the ApiService

class VehicleForm extends StatefulWidget {
  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  final ApiService apiService = ApiService(); // Create an instance of ApiService

  Future<void> addVehicle() async {
    final vehicleNumber = _vehicleNumberController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final color = _colorController.text.trim();

    if (vehicleNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vehicle number is required")),
      );
      return;
    }
    if (brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Brand is required")),
      );
      return;
    }
    if (model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Model is required")),
      );
      return;
    }
    if (color.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Color is required")),
      );
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userIdString = prefs.getString('user_id');

      if (userIdString == null) {
        print("❌ User ID not found! Please login first.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User not logged in!")),
        );
        return;
      }

      int userId = int.parse(userIdString);

      final response = await apiService.addVehicle(vehicleNumber, brand, model, color, userId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Vehicle added successfully!")),
        );

        _clearFields();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()), // Change to your screen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to add vehicle: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void _clearFields() {
    _vehicleNumberController.clear();
    _brandController.clear();
    _modelController.clear();
    _colorController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Change this to your desired color
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Padding(
        padding: EdgeInsets.all(2.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                'https://res.cloudinary.com/dwdatqojd/image/upload/v1739456170/image_15_awxcuz.png', // Replace with actual image URL
                height: 380,
                width: 600,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Container(
                height: 520,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 239, 239),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 151, 8, 8).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Vehicle Number",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 52, 51, 51))),
                    SizedBox(height: 5),
                    TextField(
                      controller: _vehicleNumberController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 175, 169, 169),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 211, 191, 9),
                              width: 1.5),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Brand",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 52, 51, 51))),
                    SizedBox(height: 5),
                    TextField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 175, 169, 169),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Model",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 52, 51, 51))),
                    SizedBox(height: 5),
                    TextField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 175, 169, 169),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Color",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 52, 51, 51))),
                    SizedBox(height: 5),
                    TextField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 175, 169, 169),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            addVehicle();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 3, 3, 3),
                            foregroundColor: const Color.fromARGB(255, 255, 254, 254),
                            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            "Add Vehicle",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()), // Change to your screen
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 3, 3, 3),
                            foregroundColor: const Color.fromARGB(255, 255, 254, 254),
                            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            "Skip",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}