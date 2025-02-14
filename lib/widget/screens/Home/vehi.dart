import 'package:flutter/material.dart';

class VehicleTypeProvider with ChangeNotifier {
  String _selectedVehicleType = 'Unknown';

  String get selectedVehicleType => _selectedVehicleType;

  void setSelectedVehicleType(String vehicleType) {
    _selectedVehicleType = vehicleType;
    notifyListeners(); // Notify listeners when the state changes
  }
}
