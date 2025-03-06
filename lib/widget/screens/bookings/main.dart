import 'package:autospaze/widget/screens/bookings/BookingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'booking_page_widgets.dart';


// Example of how to load the booking data from JSON and navigate to the BookingPage
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
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString('assets/booking_data.json');
      
      // Parse the JSON and create a BookingData object
      _bookingData = BookingData.parseJson(jsonString);
      
      setState(() {
        _isLoading = false;
      });
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

// Add this to your main.dart file
void main() {
  runApp(const ParkingApp());
}