import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:autospaze/widget/providers/ParkingProvider.dart';
import 'package:autospaze/widget/screens/bookings/bookings.dart';

class TomTomRoutD extends StatefulWidget {
  final String parkingId;

  const TomTomRoutD({
    Key? key,
    required this.parkingId,
  }) : super(key: key);

  @override
  _TomTomRoutingPageState createState() => _TomTomRoutingPageState();
}

class _TomTomRoutingPageState extends State<TomTomRoutD> {
  Map<String, dynamic>? parkingSpot;
  bool isLoading = true;
  String? errorMessage;
  Timer? _timer;

  Future<void> fetchParkingDetails() async {
    try {
      int parkingId = int.parse(widget.parkingId); // Ensure this is coming from the widget

      Map<String, dynamic>? fetchedSpot = await fetchParkingSpotById(parkingId);

      if (fetchedSpot != null) {
        setState(() {
          parkingSpot = fetchedSpot;
          isLoading = false;
        });
        print("Fetched Parking Spot: $parkingSpot");
      } else {
        setState(() {
          errorMessage = "No parking spot found with ID: $parkingId";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching parking spot: $e";
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchParkingSpotById(int parkingId) async {
    try {
      final response = await http.get(Uri.parse('https://genuine-sindee-43-76539613.koyeb.app/api/properties/$parkingId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'property_id': data['property_id'],
          'name': data['name'],
          'description': data['description'],
          'imageUrl': data['imageUrl'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'ratePerHour': data['ratePerHour'],
        };
      } else {
        throw Exception("Failed to load parking spot: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching parking spot: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    print("Opened TomTomRoutingPage with Parking ID: ${widget.parkingId}");
    fetchParkingDetails();
    // Start polling every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 2), (Timer t) => fetchParkingDetails());_timer = Timer.periodic(Duration(seconds: 2), (Timer t) => fetchParkingDetails());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 242, 242),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 38, 38),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 300, // Adjust the height as needed
              child: Align(
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  child: Image.network(
                    parkingSpot != null
                        ? parkingSpot!['imageUrl']
                        : 'https://via.placeholder.com/150',
                    height: 250, // Adjust the height as needed
                    width: double.infinity, // Adjust the width as needed
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image_not_supported, size: 120),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Add some space below the image
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      CircularProgressIndicator()
                    else if (errorMessage != null)
                      Text(errorMessage!)
                    else
                      Column(
                        children: [
                          Text("Parking Spot Details:"),
                          Text("Name: ${parkingSpot!['name']}"),
                          Text("Description: ${parkingSpot!['description']}"),
                          Text("Rate per Hour: ${parkingSpot!['ratePerHour']}"),
                        ],
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          int parkingId = int.parse(widget.parkingId); // Convert String to int
                          Map<String, dynamic>? fetchedSpot = await fetchParkingSpotById(parkingId);

                          if (fetchedSpot != null) {
                            // Update the ParkingProvider with the fetched details
                            Provider.of<ParkingProvider>(context, listen: false).setParkingSpot(
                              id: fetchedSpot['id'].toString(),
                              name: fetchedSpot['name'],
                              description: fetchedSpot['description'],
                              imageUrl: fetchedSpot['imageUrl'],
                              latitude: fetchedSpot['latitude'],
                              longitude: fetchedSpot['longitude'],
                              ratePerHour: fetchedSpot['ratePerHour'],
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookScreen(),
                              ),
                            );
                          } else {
                            print("No parking spot found with ID: $parkingId");
                          }
                        } catch (e) {
                          print("Error fetching parking spot: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Proceed to Booking",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}