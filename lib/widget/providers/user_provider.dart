import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String _slotId = '';
  String _fare = '0.0'; // Fare is now a String
  String _vehicleId = ''; // Vehicle ID

  User? get user => _user;
  String get slotId => _slotId;
  String get fare => _fare; // Getter returns a String
  String get vehicleId => _vehicleId; // Getter for vehicle ID

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();

    // Save user data to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();

    // Clear user data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('fare'); // Clear fare
    await prefs.remove('vehicle_id'); // Clear vehicle ID
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? userEmail = prefs.getString('user_email');
    String? fare = prefs.getString('fare'); // Read fare as String
    String? vehicleId = prefs.getString('vehicle_id'); // Read vehicle ID

    if (userId != null && userEmail != null) {
      _user = User(id: userId, email: userEmail);
      _fare = fare ?? '0.0'; // Default to '0.0' if fare is not found
      _vehicleId = vehicleId ?? ''; // Default to empty string if vehicle ID is not found
      notifyListeners();
    }
  }

  Future<void> setSlotId(String slotId) async {
    _slotId = slotId;
    notifyListeners();

    // Save slotId to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('slot_id', slotId);

    // Print statement to verify the slotId is saved
    print('Slot ID saved: $slotId');
  }

  Future<void> setFare(String fare) async {
    _fare = fare;
    notifyListeners();

    // Save fare to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fare', fare);

    // Print statement to verify the fare is saved
    print('Fare saved: $fare');
  }

  Future<void> setVehicleId(String vehicleId) async {
    _vehicleId = vehicleId;
    notifyListeners();

    // Save vehicleId to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicle_id', vehicleId);

    // Print statement to verify the vehicleId is saved
    print('Vehicle ID saved: $vehicleId');
  }
}