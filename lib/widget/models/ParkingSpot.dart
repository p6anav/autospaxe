// lib/models/parking_spot.dart
class ParkingSpot {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String capacity;
  final String location;

  ParkingSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.capacity,
    required this.location, required ratePerHour,
  });

  get ratePerHour => null;
}