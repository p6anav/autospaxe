import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:autospaze/widget/screens/Home/home_screen.dart';
import 'package:autospaze/widget/main_screen.dart';

class TomTomRoutingPage extends StatefulWidget {
  final LatLng currentLocation;
  final Function(List<LatLng>) onRouteUpdated;
   final String searchQuery; 

  const TomTomRoutingPage({
    Key? key,
    required this.currentLocation,
    required this.onRouteUpdated, 
    required this.searchQuery,
  }) : super(key: key);

  @override
  _TomTomRoutingPageState createState() => _TomTomRoutingPageState();
}

class _TomTomRoutingPageState extends State<TomTomRoutingPage> {
  late MapController _mapController;
  late TextEditingController _searchController;
  List<LatLng> _routeCoordinates = [];
  LatLng? _destination;

  // List of parking locations
  List<Map<String, dynamic>> _parkingLocations = [
    {
      "name": "Pranav Parking",
      "location": LatLng(9.3906, 76.5583),
      "isVisible": true,
    },
    {
      "name": "Gedi Parking",
      "location": LatLng(9.4000, 76.5650),
      "isVisible": true,
    },
    {
      "name": "Tech Park",
      "location": LatLng(9.4050, 76.5700),
      "isVisible": true,
    },
     {
      "name": "Auto Spaxe chengannur",
      "location": LatLng(9.3155, 76.6158),
      "isVisible": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  // Function to calculate the route and update the map with polyline
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

  // Function to fetch route from TomTom API
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

  // Function to handle location search
  void _onSearchDestination() {
    String input = _searchController.text.trim();

    // Find parking location by name
    var matchedParking = _parkingLocations.firstWhere(
      (parking) => parking['name'].toLowerCase() == input.toLowerCase(),
      
    );

    if (matchedParking != null) {
      LatLng parkingLocation = matchedParking['location'];
      _calculateRoute(parkingLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking area not found.')),
      );
    }
  }

  // Update visibility of parking markers based on zoom level
  void _updateMarkerVisibility(double zoomLevel) {
    setState(() {
      if (zoomLevel > 13.5) {
        _parkingLocations = _parkingLocations
            .map((parking) => {...parking, "isVisible": true})
            .toList();
      } else {
        _parkingLocations = _parkingLocations
            .map((parking) => {...parking, "isVisible": false})
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
       
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the home page
            Navigator.pop(context);

          },
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildMap(),
        ],
      ),
    );
  }

  // Build the search bar to input a destination
  Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      children: [
        Expanded(
        child: TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Enter parking area name...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
    filled: true, // Adds background color to the TextField
 // Set background color to black
    hintStyle: TextStyle(color: const Color.fromARGB(255, 156, 90, 90)), // Set hint text color to white for contrast
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    suffixIcon: IconButton(
      icon: const Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0)), // Set icon color to white
      onPressed: _onSearchDestination, // Search action on click
    ),
  ),
  onSubmitted: (value) => _onSearchDestination(), // Trigger search on 'Enter'
),

        ),
      ],
    ),
  );
}


  // Build the map for displaying the route and parking markers
  Widget _buildMap() {
    return Expanded(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.currentLocation,
          initialZoom: 15,
          onPositionChanged: (position, hasGesture) {
            if (position != null) {
              _updateMarkerVisibility(position.zoom ?? 15);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=8CKwch3uCDAuLbcrffLiAx8IdhU9bGKS',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routeCoordinates,
                strokeWidth: 6,
                color: const Color.fromARGB(255, 247, 2, 2),
              ),
            ],
          ),
          MarkerLayer(
            markers: _parkingLocations.map((parking) {
              return Marker(
                point: parking["location"],
                width: 150,
                height: parking["isVisible"] == true ? 80 : 0,
                child: parking["isVisible"] == true
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 40),
                          const SizedBox(height: 5),
                          Text(
                            parking["name"],
                            style: const TextStyle(
                              color: Color.fromARGB(255, 117, 35, 35),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
