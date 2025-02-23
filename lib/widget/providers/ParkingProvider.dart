import 'package:flutter/foundation.dart';

class ParkingProvider extends ChangeNotifier {
  String _parkingId = '';
  String _parkingName = '';
  String _parkingDescription = '';
  String _parkingImageUrl = '';
  double _parkingLatitude = 0.0;
  double _parkingLongitude = 0.0;
  double _ratePerHour = 0.0; // Add this line

  String get parkingId => _parkingId;
  String get parkingName => _parkingName;
  String get parkingDescription => _parkingDescription;
  String get parkingImageUrl => _parkingImageUrl;
  double get parkingLatitude => _parkingLatitude;
  double get parkingLongitude => _parkingLongitude;
  double get ratePerHour => _ratePerHour; // Add this line

  void setParkingSpot({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required double latitude,
    required double longitude,
    required double ratePerHour, // Add this line
  }) {
    _parkingId = id;
    _parkingName = name;
    _parkingDescription = description;
    _parkingImageUrl = imageUrl;
    _parkingLatitude = latitude;
    _parkingLongitude = longitude;
    _ratePerHour = ratePerHour; // Add this line
    notifyListeners();
    print('Parking details updated: $_parkingId, $_parkingName, Rate per Hour: $_ratePerHour');
  }
}