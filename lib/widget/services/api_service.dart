import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    Map<String, String> loginData = {
      "email": email,
      "password": password,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginData),
    );

    return response;
  }

  
  Future<http.Response> signup(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    Map<String, String> signupData = {
      "username": username,
      "email": email,
      "password": password,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(signupData),
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
      final response = await http.get(Uri.parse('$baseUrl/parking-spots'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((spot) => {
          'id': spot['id'],  // Include the parking spot ID
          'name': spot['name'],
          'description': spot['description'],
          'imageUrl': spot['imageUrl'],
        }).toList();
      } else {
        throw Exception("Failed to load parking spots: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching parking spots: $e");
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


}
