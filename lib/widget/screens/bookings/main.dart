import 'package:autospaze/widget/screens/bookings/BookingPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'booking_page_widgets.dart';

class ParkingApp extends StatelessWidget {
  const ParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BookingLauncher(),
    );
  }
}

class BookingLauncher extends StatefulWidget {
  const BookingLauncher({Key? key}) : super(key: key);

  @override
  State<BookingLauncher> createState() => _BookingLauncherState();
}

class _BookingLauncherState extends State<BookingLauncher> {
  bool _isLoading = true;
  late BookingData _bookingData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    try {
      // Fetch data from the API
      final userId = 35; // Replace with the actual user ID
      final url = Uri.parse('http://localhost:8080/api/users/details/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonString = response.body;
        final data = json.decode(jsonString);
        _bookingData = BookingData.fromJson(data);

        // Print the fetched data
        print('Fetched Booking Data: $data');

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load booking data: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load booking data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Booking'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : ElevatedButton(
                    child: const Text('Go to Booking Page'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            bookingData: _bookingData,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

void main() {
  runApp(const ParkingApp());
}