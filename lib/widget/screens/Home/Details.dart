import 'package:flutter/material.dart';
import 'package:autospaze/widget/screens/Home/SearchPage.dart';
import 'package:latlong2/latlong.dart'; // Assuming this page is for searching


final LatLng _currentLocation = LatLng(9.31741, 76.61764);
class ParkingSpotButton extends StatefulWidget {
  final Map<String, String> parkingSpot;

  ParkingSpotButton({required this.parkingSpot});

  @override
  _ParkingSpotButtonState createState() => _ParkingSpotButtonState();
}

class _ParkingSpotButtonState extends State<ParkingSpotButton> {
  Color _buttonColor = Colors.green;

  void _handleButtonClick() {
    setState(() {
      _buttonColor = Colors.red;
    });

    _navigateToDetailsPage(context, widget.parkingSpot);
  }

  void _navigateToSearchPage(BuildContext context, String parkingName) {
    // Navigate to search page, passing the parking name
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TomTomRoutingPage(
          currentLocation: _currentLocation,
          onRouteUpdated: (route) {
            // Handle route update here if needed
          },
          searchQuery: parkingName, // Pass parking name as the search query
        ),
      ),
    );
  }

  void _navigateToDetailsPage(
      BuildContext context, Map<String, String> parkingSpot) {
    String capacity = parkingSpot['capacity'] ?? 'N/A';
    String location = parkingSpot['location'] ?? 'Unknown location';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingSpotDetailsPage(
          name: parkingSpot['name']!,
          description: parkingSpot['description']!,
          imageUrl: parkingSpot['imageUrl']!,
          capacity: capacity,
          location: location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleButtonClick,
      style: ElevatedButton.styleFrom(
        foregroundColor: _buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      child: const Text('Details'),
    );
  }
}

class ParkingSpotDetailsPage extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final String capacity;
  final String location;

  ParkingSpotDetailsPage({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.capacity,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl),
            const SizedBox(height: 16),
            Text('Description: $description'),
            const SizedBox(height: 8),
            Text('Capacity: $capacity'),
            const SizedBox(height: 8),
            Text('Location: $location'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
               
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to the SearchPage
  
}
