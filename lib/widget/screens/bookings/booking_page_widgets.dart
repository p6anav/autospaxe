import 'package:autospaze/widget/screens/payments/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

/// Model class for vehicle options
class VehicleOption {
  final String brand;
  final String model;
  final String type;
  final bool isDefault;

  const VehicleOption({
    required this.brand,
    required this.model,
    required this.type,
    this.isDefault = false,
  });

  factory VehicleOption.fromJson(Map<String, dynamic> json) {
    return VehicleOption(
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

/// Model class for booking data
class BookingData {
  final String fromLocation;
  final String toLocation;
  final String parkingSlot;
  final String bookingTime;
  final String parkingName;
  final String parkingAddress;
  final double parkingRating;
  final List<VehicleOption> vehicleOptions;

  BookingData({
    required this.fromLocation,
    required this.toLocation,
    required this.parkingSlot,
    required this.bookingTime,
    required this.parkingName,
    required this.parkingAddress,
    required this.parkingRating,
    required this.vehicleOptions,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      parkingSlot: json['parkingSlot'] ?? '',
      bookingTime: json['bookingTime'] ?? '',
      parkingName: json['parkingName'] ?? '',
      parkingAddress: json['parkingAddress'] ?? '',
      parkingRating: json['parkingRating'] ?? 0.0,
      vehicleOptions: (json['vehicleOptions'] as List?)
          ?.map((v) => VehicleOption.fromJson(v))
          .toList() ??
          [],
    );
  }

  static BookingData parseJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return BookingData.fromJson(data);
  }
}

class BookingSlidingPanel extends StatelessWidget {
  final BookingData bookingData;
  final VehicleOption selectedVehicle;
  final bool isVehicleMenuExpanded;
  final VoidCallback onVehicleMenuToggle;
  final Function(VehicleOption) onVehicleSelected;

  const BookingSlidingPanel({
    Key? key,
    required this.bookingData,
    required this.selectedVehicle,
    required this.isVehicleMenuExpanded,
    required this.onVehicleMenuToggle,
    required this.onVehicleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildCard([
                    _buildRouteDisplay(),
                    const SizedBox(height: 16),
                    _buildDottedDivider(),
                    const SizedBox(height: 12),
                    _buildDetailsSingleLine(),
                  ], padding: 16),

                  const SizedBox(height: 16),

                  // Vehicle selection container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.12),
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Selected vehicle display
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      Icons.directions_car,
                                      selectedVehicle.brand,
                                      trailing: Text(
                                        selectedVehicle.model,
                                        style: TextStyle(
                                          color: Colors.deepPurple.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: Text(
                                        selectedVehicle.type,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Toggle button for vehicle menu
                              InkWell(
                                onTap: onVehicleMenuToggle,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isVehicleMenuExpanded
                                        ? Colors.deepPurple.shade200
                                        : Colors.deepPurple.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isVehicleMenuExpanded
                                        ? Icons.remove
                                        : Icons.add,
                                    color: Colors.deepPurple.shade700,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expandable vehicle selection menu
                        AnimatedCrossFade(
                          firstChild: const SizedBox(height: 0),
                          secondChild: _buildVehicleSelectionMenu(),
                          crossFadeState: isVehicleMenuExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),

                        // Parking details section
                        _buildParkingDetails(),

                        // Availability status
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDottedDivider(),
                              const SizedBox(height: 12),

                              _buildInfoRow(
                                Icons.event_available,
                                "Available Now",
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "Ready",
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Confirm booking button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentApp(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Confirm Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the parking details section
  Widget _buildParkingDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDottedDivider(),
          const SizedBox(height: 16),

          // Parking header label
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Parking Area",
              style: TextStyle(
                color: Colors.deepPurple.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small parking image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://picsum.photos/100/100",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: Colors.deepPurple.shade400,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey.shade500),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Parking details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingData.parkingName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      bookingData.parkingAddress,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          bookingData.parkingRating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${(bookingData.parkingRating * 100).toInt()} reviews)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Amenities row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildAmenityBadge(Icons.security, "24/7 Security"),
                _buildAmenityBadge(Icons.wheelchair_pickup, "Accessible"),
                _buildAmenityBadge(Icons.camera_alt, "CCTV"),
                _buildAmenityBadge(Icons.family_restroom, "Family Friendly"),
                _buildAmenityBadge(Icons.lightbulb, "Well Lit"),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Build an amenity badge
  Widget _buildAmenityBadge(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.deepPurple.shade500),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // Build the vehicle selection menu
  Widget _buildVehicleSelectionMenu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Suggested Vehicles",
              style: TextStyle(
                color: Colors.deepPurple.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          // List of vehicle options
          ...bookingData.vehicleOptions.map((vehicle) => _buildVehicleOption(vehicle)),

          _buildDottedDivider(),
          const SizedBox(height: 12),

          // Add new vehicle option
          InkWell(
            onTap: onVehicleMenuToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.deepPurple.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Add New Vehicle",
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Build a single vehicle option item
  Widget _buildVehicleOption(VehicleOption vehicle) {
    final isSelected = vehicle.brand == selectedVehicle.brand &&
        vehicle.model == selectedVehicle.model;

    return InkWell(
      onTap: () => onVehicleSelected(vehicle),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.deepPurple.shade600 : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.deepPurple.shade600 : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vehicle.brand,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        vehicle.model,
                        style: TextStyle(
                          color: Colors.deepPurple.shade600,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicle.type,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a card widget with children
  Widget _buildCard(List<Widget> children, {double padding = 20}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  // Build information row with icon and text
  Widget _buildInfoRow(IconData icon, String text, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.deepPurple.shade600, size: 16),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // Build the route display with start and end locations
  Widget _buildRouteDisplay() {
    return Row(
      children: [
        _buildLocationBadge(bookingData.fromLocation, true),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 2),
                painter: DottedLinePainter(
                  color: Colors.deepPurple.shade400,
                  dashWidth: 5,
                  dashSpace: 3,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: -1,
                    )
                  ],
                ),
                child: Icon(Icons.directions_car, color: Colors.deepPurple.shade400, size: 16),
              ),
            ],
          ),
        ),
        _buildLocationBadge(bookingData.toLocation, false),
      ],
    );
  }

  // Get location code from full location name (e.g. "New York" -> "NY")
  String getLocationCode(String location) {
    if (location.isEmpty) return "";

    final words = location.split(" ");
    if (words.length >= 2) {
      String code = "";
      for (int i = 0; i < 3 && i < words.length; i++) {
        if (words[i].isNotEmpty) code += words[i][0];
      }
      return code.toUpperCase();
    }
    return location.length >= 3 ? location.substring(0, 3).toUpperCase() : location.toUpperCase();
  }

  // Build location badge with circular icon
  Widget _buildLocationBadge(String location, bool isStart) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isStart ? Colors.deepPurple.shade300 : Colors.deepPurple.shade400,
                isStart ? Colors.deepPurple.shade400 : Colors.deepPurple.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.25),
                blurRadius: 8,
                spreadRadius: -2,
              )
            ],
          ),
          child: Center(
            child: Text(
              getLocationCode(location),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          location,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          isStart ? "Start" : "End",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
      ],
    );
  }

  // Build a dotted divider line
  Widget _buildDottedDivider() {
    return SizedBox(
      height: 1,
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: DottedLinePainter(
          color: Colors.grey.shade300,
          dashWidth: 6,
          dashSpace: 4,
        ),
      ),
    );
  }

  // Build single line details display
  Widget _buildDetailsSingleLine() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconText(Icons.local_parking_rounded, bookingData.parkingSlot),
          Container(height: 24, width: 1, color: Colors.grey.shade300),
          _buildIconText(Icons.access_time_rounded, bookingData.bookingTime),
        ],
      ),
    );
  }

  // Build icon with text for information display
  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.deepPurple.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Painter for drawing dotted lines
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DottedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}

// Example usage:
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Booking Sliding Panel Example'),
        ),
        body: BookingSlidingPanelExample(),
      ),
    );
  }
}

class BookingSlidingPanelExample extends StatefulWidget {
  @override
  _BookingSlidingPanelExampleState createState() => _BookingSlidingPanelExampleState();
}

class _BookingSlidingPanelExampleState extends State<BookingSlidingPanelExample> {
  late BookingData bookingData;
  late VehicleOption _selectedVehicle;
  bool _isVehicleMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load dummy JSON data
    String jsonString = '''
    {
      "fromLocation": "New York",
      "toLocation": "Los Angeles",
      "parkingSlot": "A1",
      "bookingTime": "10:00 AM",
      "parkingName": "Central Parking Lot",
      "parkingAddress": "123 Main St, New York, NY 10001",
      "parkingRating": 4.5,
      "vehicleOptions": [
        {
          "brand": "Toyota",
          "model": "Camry",
          "type": "Sedan",
          "isDefault": true
        },
        {
          "brand": "Honda",
          "model": "Civic",
          "type": "Sedan",
          "isDefault": false
        },
        {
          "brand": "Tesla",
          "model": "Model S",
          "type": "Electric",
          "isDefault": false
        }
      ]
    }
    ''';

    bookingData = BookingData.parseJson(jsonString);

    // Find default vehicle or use first one if available
    _selectedVehicle = bookingData.vehicleOptions.isNotEmpty
        ? bookingData.vehicleOptions.firstWhere(
            (v) => v.isDefault,
            orElse: () => bookingData.vehicleOptions.first,
          )
        : VehicleOption(
            brand: 'Default Brand',
            model: 'Default Model',
            type: 'Default Type',
          );
  }

  @override
  Widget build(BuildContext context) {
    return BookingSlidingPanel(
      bookingData: bookingData,
      selectedVehicle: _selectedVehicle,
      isVehicleMenuExpanded: _isVehicleMenuExpanded,
      onVehicleMenuToggle: () {
        setState(() {
          _isVehicleMenuExpanded = !_isVehicleMenuExpanded;
        });
      },
      onVehicleSelected: (vehicle) {
        setState(() {
          _selectedVehicle = vehicle;
          _isVehicleMenuExpanded = false;
        });
      },
    );
  }
}