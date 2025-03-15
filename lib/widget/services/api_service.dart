import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://genuine-sindee-43-76539613.koyeb.app/api';

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/authenticate')
        .replace(queryParameters: {'email': email, 'password': password});

    final response = await http.post(
      url,
    );

    return response;
  }


  Future<http.Response> signup(String username, String email, String password) async {
  final baseUrl = 'https://genuine-sindee-43-76539613.koyeb.app/api/users/register'; // Adjust the base URL as needed
  final url = Uri.parse(baseUrl);
  Map<String, String> signupData = {
    "username": username,
    "email": email,
    "password": password,
    "rolename": "USER", // Default role
  };

  final response = await http.post(
    url,
    body: signupData,
  );

  return response;
}


  Future<http.Response> addVehicle(String vehicleNumber, String brand, String model, String color, int userId) async {
    final url = Uri.parse('$baseUrl/vehicles');
    Map<String, dynamic> vehicleData = {
      "vehicleNumber": vehicleNumber,
      "brand": brand,
      "model": model,
      "color": color,
      "user": {"id": userId}
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(vehicleData),
    );

    return response;
  }
 

Future<List<Map<String, dynamic>>> getNearbyParkingSpots() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/properties'));

    if (response.statusCode == 200) {
      // Check if the response body is valid JSON
      try {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((spot) => {
          'property_id': spot['property_id'],  // Include the parking spot ID
          'name': spot['name'],
          'description': spot['description'],
          'imageUrl': spot['imageUrl'],
        }).toList();
      } catch (e) {
        throw Exception("Invalid JSON response: $e");
      }
    } else {
      // Handle non-200 status codes
      throw Exception("Failed to load parking spots: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetchibacng parking spots: $e");
    throw Exception("Network error: $e");
  }
}


  Future<List<Map<String, dynamic>>> getVehiclesByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/vehicles/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((vehicle) => {
        'vehicleNumber': vehicle['vehicleNumber'],
        'brand': vehicle['brand'],
        'model': vehicle['model'],
        'color': vehicle['color'],
      }).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

 Future<Map<String, dynamic>?> fetchParkingSpotById(int parkingId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/$parkingId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'property_id': data['property_id'],
          'name': data['name'],
          'floor': data['floor'],
          'city': data['city'],
          'district': data['district'],
          'state': data['state'],
          'country': data['country'],
          'google_location': data['google_location'],
          'property_type': data['property_type'],
          'total_slots': data['total_slots'],
          'available_slots': data['available_slots'],
          'rate_per_hour': data['rate_per_hour'],
          'description': data['description'],
          'image_url': data['image_url'],
          'status': data['status'],
          'manager_id': data['manager_id'],
        };
      } else {
        throw Exception("Failed to load parking spot: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching parking spot: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>> getNearbyParkingSdpots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((spot) => {
          'propertyId': spot['propertyId'].toString(),  // Convert int to String
          'name': spot['name'] ?? 'N/A',
          'description': spot['description'] ?? 'N/A',
          'imageUrl': spot['imageUrl'] ?? 'https://via.placeholder.com/150x150',  // Updated fallback image URL
        }).toList();
      } else {
        throw Exception("Failed to load parking spots: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching parking spots: $e");
      throw Exception("Network error: $e");
    }
  }

}