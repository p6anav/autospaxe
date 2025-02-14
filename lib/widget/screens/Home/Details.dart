import 'package:flutter/material.dart';
import 'package:autospaze/widget/screens/Home/SearchPage.dart';
import 'package:latlong2/latlong.dart'; 
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
final LatLng _currentLocation = LatLng(9.31741, 76.61764);

class ParkingSpotButton extends StatefulWidget {
   
  final Map<String, dynamic> parkingSpot;
  
  var onRouteUpdated;
  
  var currentLocation;
  
  

  ParkingSpotButton({
    required this.parkingSpot,
    required this.onRouteUpdated, 
    required this.currentLocation

    });
  

  @override
  _ParkingSpotButtonState createState() => _ParkingSpotButtonState();
 
}

class _ParkingSpotButtonState extends State<ParkingSpotButton> {
  
 
  List<LatLng> _routeCoordinates = [];
  
   LatLng? _destination;
  Color _buttonColor = Colors.green;

  void _handleButtonClick() {
    setState(() {
      _buttonColor = Colors.red;
    });

    _navigateToDetailsPage(context, widget.parkingSpot);
  }

Future<void> _calculateRoute(LatLng destination) async {
    try {
      List<LatLng> route = await _getRouteFromTomTom(widget.currentLocation, destination);

      // Update route coordinates and callback to HomeScreen
      widget.onRouteUpdated(route);
      setState(() {
        _routeCoordinates = route;
        _destination = destination;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating route: $e')),
      );
    }
  }
  void _navigateToSearchPage(BuildContext context, String parkingName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TomTomRoutingPage(
          currentLocation: _currentLocation,
          onRouteUpdated: (route) {
             setState(() {
        _routeCoordinates = route;
        _destination = _destination;
      });
            // Pass updated route to HomeScreen
          },
          searchQuery: parkingName,
        ),
      ),
    );
  }

  void _navigateToDetailsPage(BuildContext context, Map<String, dynamic> parkingSpot) {
    String capacity = parkingSpot['capacity']?.toString() ?? 'N/A';
    String location = parkingSpot['location'] != null
        ? '${parkingSpot['location'].latitude}, ${parkingSpot['location'].longitude}'
        : 'Unknown location';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingSpotDetailsPage(
           idk:parkingSpot ['id']!,
          name: parkingSpot['name'] ?? 'Unknown',
          description: parkingSpot['description'] ?? 'No description available',
          imageUrl: parkingSpot['imageUrl'] ?? '',
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
    required this.location, required idk,
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
            Image.network(imageUrl, errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported)),
            const SizedBox(height: 16),
            Text('Description: $description'),
            const SizedBox(height: 8),
            Text('Capacity: $capacity'),
            const SizedBox(height: 8),
            Text('Location: $location'),
          ],
        ),
      ),
    );
  }
}


// Function to calculate route and call back to HomeScreen
Future<void> _calculateRoute(LatLng destination, Function(List<LatLng>) onRouteUpdated) async {
  try {
    List<LatLng> route = await _getRouteFromTomTom(_currentLocation, destination);

    // Update the route and callback to HomeScreen
    onRouteUpdated(route);
  } catch (e) {
    print('Error calculating route: $e');
  }
}
Future<List<LatLng>> _getRouteFromTomTom(LatLng start, LatLng end) async {
    String apiKey = '8CKwch3uCDAuLbcrffLiAx8IdhU9bGKS';
    String url = 'https://api.tomtom.com/routing/1/calculateRoute/'
        '${start.latitude},${start.longitude}:${end.latitude},${end.longitude}/json?key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> geometry = data['routes'][0]['legs'][0]['points'];
      List<LatLng> routeCoordinates = geometry.map((point) {
        return LatLng(point['latitude'], point['longitude']);
      }).toList();

      return routeCoordinates;
    } else {
      throw Exception('Failed to load route');
    }
  }