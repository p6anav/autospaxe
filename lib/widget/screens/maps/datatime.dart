import 'package:autospaze/widget/screens/maps/payment.dart';
import 'package:flutter/material.dart';
import 'package:autospaze/widget/screens/maps/maps.dart'; // Import your map screen
import 'package:autospaze/widget/screens/Home/home_screen.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DateTimeRangePickerScreen extends StatefulWidget {
  final String parkingId;

  const DateTimeRangePickerScreen({
    Key? key,
    required this.parkingId,
  }) : super(key: key);

  @override
  _DateTimeRangePickerScreenState createState() =>
      _DateTimeRangePickerScreenState();
}

Map<String, dynamic>? parkingSpot;

class _DateTimeRangePickerScreenState extends State<DateTimeRangePickerScreen> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  // Function to pick the start DateTime
  Future<void> _selectStartDateTime(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedStartDate != null) {
      final TimeOfDay? pickedStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedStartTime != null) {
        setState(() {
          startDateTime = DateTime(
            pickedStartDate.year,
            pickedStartDate.month,
            pickedStartDate.day,
            pickedStartTime.hour,
            pickedStartTime.minute,
          );
        });
      }
    }
  }
 
  Future<void> fetchParkingDetails() async {
    try {
      int parkingId =
          int.parse(widget.parkingId); // Ensure this is coming from the widget

      Map<String, dynamic>? fetchedSpot = await fetchParkingSpotById(parkingId);

      if (fetchedSpot != null) {
        setState(() {
          parkingSpot = fetchedSpot;
        });
        print("Fetched Parking Spot: $parkingSpot");
      } else {
        print("No parking spot found with ID: $parkingId");
      }
    } catch (e) {
      print("Error fetching parking spot: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchParkingSpotById(int parkingId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/parking-spots/$parkingId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'id': data['id'],
          'name': data['name'],
          'description': data['description'],
          'imageUrl': data['imageUrl'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        };
      } else {
        throw Exception("Failed to load parking spot: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching parking spot: $e");
      return null;
    }
  }

  // Function to pick the end DateTime
  Future<void> _selectEndDateTime(BuildContext context) async {
    final DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedEndDate != null) {
      final TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedEndTime != null) {
        setState(() {
          endDateTime = DateTime(
            pickedEndDate.year,
            pickedEndDate.month,
            pickedEndDate.day,
            pickedEndTime.hour,
            pickedEndTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Date and Time"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the home page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MainScreen(), // Replace with your next page
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Start DateTime: ${startDateTime ?? 'Not selected'}"),
              onTap: () => _selectStartDateTime(context),
            ),
            ListTile(
              title: Text("End DateTime: ${endDateTime ?? 'Not selected'}"),
              onTap: () => _selectEndDateTime(context),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDateTime != null && endDateTime != null) {
                 Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>SvgUpdater(
      parkingId: widget.parkingId, searchQuery: '', parkingSlots: '',
    ),
  ),
);  // Navigate to the map screen
                  
                } else {
                  // Show an alert if date/time is not selected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content:
                            Text("Please select both start and end times."),
                        actions: <Widget>[
                          ElevatedButton(onPressed: () async {
                try {
      int parkingId = int.parse(widget.parkingId); // Convert String to int
      Map<String, dynamic>? parkingSpot = await fetchParkingSpotById(parkingId); // Fetch details

      if (parkingSpot != null) {
        print("Fetched Parkitenext Spot:");
        print("ID: ${parkingSpot['id']}, Name: ${parkingSpot['name']}");
        print("Latitude: ${parkingSpot['latitude']}, Longitude: ${parkingSpot['longitude']}");
        print("Description: ${parkingSpot['description']}");
        print("Image URL: ${parkingSpot['imageUrl']}");

        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>SvgUpdater(
      parkingId: widget.parkingId, searchQuery: '', parkingSlots: '',
    ),
  ),
);

      } else {
        print("No parking spot found with ID: $parkingId");
      }
    }  catch (e) {
                  print("Error fetching parking spots: $e");
                }
              }, child: null,),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
