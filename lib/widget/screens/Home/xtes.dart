import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController userIdController = TextEditingController(text: '10');
  final TextEditingController vehicleIdController = TextEditingController(text: '6');
  final TextEditingController slotIdController = TextEditingController(text: '2');
  final TextEditingController bookingStartTimeController = TextEditingController(text: '2025-02-16T10:00:00');
  final TextEditingController bookingEndTimeController = TextEditingController(text: '2025-02-16T12:00:00');
  final TextEditingController statusController = TextEditingController(text: 'Active');
  final TextEditingController parkingSpotIdController = TextEditingController(text: '1');
  final TextEditingController parkingSlotsIdController = TextEditingController(text: '53');

  Future<void> createBooking() async {
    final String userId = userIdController.text;
    final String vehicleId = vehicleIdController.text;
    final String slotId = slotIdController.text;
    final String bookingStartTime = bookingStartTimeController.text;
    final String bookingEndTime = bookingEndTimeController.text;
    final String status = statusController.text;
    final String parkingSpotId = parkingSpotIdController.text;
    final String parkingSlotsId = parkingSlotsIdController.text;

    final Map<String, dynamic> bookingData = {
      "userId": int.parse(userId),
      "vehicleId": int.parse(vehicleId),
      "slotId": slotId,
      "bookingStartTime": bookingStartTime,
      "bookingEndTime": bookingEndTime,
      "status": status,
      "parkingSpotId": int.parse(parkingSpotId),
      "parkingSlotsId": int.parse(parkingSlotsId),
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create booking. Status Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: vehicleIdController,
              decoration: InputDecoration(labelText: 'Vehicle ID'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: slotIdController,
              decoration: InputDecoration(labelText: 'Slot ID'),
            ),
            TextFormField(
              controller: bookingStartTimeController,
              decoration: InputDecoration(labelText: 'Booking Start Time'),
            ),
            TextFormField(
              controller: bookingEndTimeController,
              decoration: InputDecoration(labelText: 'Booking End Time'),
            ),
            TextFormField(
              controller: statusController,
              decoration: InputDecoration(labelText: 'Status'),
            ),
            TextFormField(
              controller: parkingSpotIdController,
              decoration: InputDecoration(labelText: 'Parking Spot ID'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: parkingSlotsIdController,
              decoration: InputDecoration(labelText: 'Parking Slots ID'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: createBooking,
              child: Text('Create Booking'),
            ),
          ],
        ),
      ),
    );
  }
}