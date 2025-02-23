import 'dart:convert';

import 'package:flutter/foundation.dart';

class ParkingData with ChangeNotifier {
  List<Map<String, dynamic>> _parkingDetails = [];

  List<Map<String, dynamic>> get parkingDetails => _parkingDetails;

  void loadParkingDetails(String jsonData) {
    final List<dynamic> data = jsonDecode(jsonData);
    _parkingDetails = data.map((item) => item as Map<String, dynamic>).toList();
    notifyListeners();
  }
}