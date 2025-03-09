import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/models/user.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Added QR code package
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model class for User

class VehicleOption {
  final int id;
  final String brand;
  final String model;
  final String type;
  final bool isDefault;

  const VehicleOption({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    this.isDefault = false,
  });

  factory VehicleOption.fromJson(Map<String, dynamic> json) {
    return VehicleOption(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['vehicleNumber'] ?? '',
      type: json['color'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

// Model class for QrCodeData
class QrCodeData {
  final int qrCodeId;
  final int bookingId;
  final int userId;
  final String qrCodeData;
  final String createdAt;
  final String status;

  QrCodeData({
    required this.qrCodeId,
    required this.bookingId,
    required this.userId,
    required this.qrCodeData,
    required this.createdAt,
    required this.status,
  });

  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      qrCodeId: json['qrCodeId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      userId: json['userId'] ?? 0,
      qrCodeData: json['qrCodeData'] ?? '',
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

// Model class for PaymentData
class PaymentData {
  final int paymentId;
  final int bookingId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;

  PaymentData({
    required this.paymentId,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      paymentId: json['paymentId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      userId: json['userId'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

// Model class for BookingData
class BookingData {
  final String fromLocation;
  final String toLocation;
  final String parkingSlot;
  final String bookingTime;
  final String parkingName;
  final String parkingAddress;
  final double parkingRating;
  final String parkingImage;
  final List<VehicleOption> vehicleOptions;
  final int propertyId;
  final List<QrCodeData> qrCodes;
  final List<PaymentData> payments;

  BookingData({
    required this.fromLocation,
    required this.toLocation,
    required this.parkingSlot,
    required this.bookingTime,
    required this.parkingName,
    required this.parkingAddress,
    required this.parkingRating,
    required this.parkingImage,
    required this.vehicleOptions,
    required this.propertyId,
    required this.qrCodes,
    required this.payments,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
  final user = json['user'] ?? {};
  final vehicles = json['vehicles'] ?? [];
  final parkingSlots = json['parkingSlots'] ?? [];
  final qrCodes = json['qrCodes'] ?? [];
  final payments = json['payments'] ?? [];
  final bookings = json['bookings'] ?? [];

  // Find the latest booking based on bookingId
  final latestBooking = bookings.reduce((current, next) =>
      current['bookingId'] > next['bookingId'] ? current : next);

  final latestBookingId = latestBooking['bookingId'];

  // Filter the payments and qrCodes related to the latest booking
  final latestPayments = payments.where((payment) => payment['bookingId'] == latestBookingId).toList();
  final latestQrCodes = qrCodes.where((qrCode) => qrCode['bookingId'] == latestBookingId).toList();

  final usedParkingSlots = parkingSlots.where((slot) => slot['used'] == true).toList();

  if (usedParkingSlots.isEmpty) {
    throw Exception('No used parking slots found');
  }

  final firstUsedSlot = usedParkingSlots.first;

  final property = firstUsedSlot['property'] ?? {};
  final parkingName = property['name'] ?? 'Unknown';
  final parkingAddress = property['city'] ?? 'Unknown';
  final parkingRating = (property['ratePerHour'] as num?)?.toDouble() ?? 0.0;
  final parkingImage = property['imageUrl'] ?? '';
  final propertyId = property['propertyId'] ?? 0;

  final parkingSlot = firstUsedSlot['slotNumber'] is int
      ? firstUsedSlot['slotNumber'].toString()
      : firstUsedSlot['slotNumber'] ?? 'Unknown';

  // Filter vehicles that are marked as 'used'
  final usedVehicles = vehicles.where((vehicle) => vehicle['used'] == true).toList();

  if (usedVehicles.isEmpty) {
    throw Exception('No used vehicles found');
  }

  // Map the list of dynamic to a list of VehicleOption
  final vehicleOptions = usedVehicles.map((v) => VehicleOption.fromJson(v)).toList().cast<VehicleOption>();

  // Ensure proper casting for qrCodes and payments
  final qrCodeList = (latestQrCodes as List).map((q) => QrCodeData.fromJson(q)).toList().cast<QrCodeData>();
  final paymentList = (latestPayments as List).map((p) => PaymentData.fromJson(p)).toList().cast<PaymentData>();

  return BookingData(
    fromLocation: user['location'] ?? 'Chengannur',
    toLocation: property['name'] ?? 'Unknown',
    parkingSlot: parkingSlot,
    bookingTime: firstUsedSlot['exitTime'] ?? 'Unknown',
    parkingName: parkingName,
    parkingAddress: parkingAddress,
    parkingRating: parkingRating,
    parkingImage: parkingImage,
    propertyId: propertyId,
    vehicleOptions: vehicleOptions,
    qrCodes: qrCodeList,
    payments: paymentList,
  );
}
}

// UserProvider


// Function to fetch booking data
Future<BookingData> fetchBookingData(BuildContext context) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final User? user = userProvider.user;

  if (user == null) {
    throw Exception('User data is not available');
  }

  final userId = user.id;
  final response = await http.get(Uri.parse('http://localhost:8080/api/users/details/$userId'));

  if (response.statusCode == 200) {
    return BookingData.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load booking data: ${response.statusCode}');
  }
}

// InvoicePage
class InvoicePage extends StatefulWidget {
  final String userId;

  const InvoicePage({super.key, required this.userId});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  BookingData? _bookingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
    _fetchBookingData();
  }

  Future<void> _fetchBookingData() async {
    try {
      final bookingData = await fetchBookingData(context);
      setState(() {
        _bookingData = bookingData;
        _isLoading = false;
      });

      // Print QR code strings
      if (_bookingData?.qrCodes != null) {
        for (var qrCode in _bookingData!.qrCodes) {
          print('QR Code Data: ${qrCode.qrCodeData}');
        }
      }
    } catch (e) {
      print('Error fetching booking data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load booking data: $e')),
      );
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade50,
    appBar: AppBar(
      title: const Text("Invoice", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: child,
              );
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildInvoiceCard(),
                  const SizedBox(height: 16),
                  _buildParkingDetailsCard(),
                  const SizedBox(height: 16),
                  _buildVehicleDetailsCard(),
                  const SizedBox(height: 16),
                  _buildPaymentDetailsCard(),
                  const SizedBox(height: 30),
                  _buildPoweredBy(),
                  const SizedBox(height: 30),
                  // Add the "Back to Home" button here
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to the BookingSlidingPanel
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  MainScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Extra space at the bottom
                ],
              ),
            ),
          ),
  );
}

  Widget _buildInvoiceCard() {
    if (_bookingData == null) return Container();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top gradient header
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.deepPurple.shade700,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Parking Confirmation",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Payment Successful",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Invoice number and QR section
          Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    children: [
      // QR Code - Using QrImageView from qr_flutter package
      Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: _bookingData?.qrCodes.isNotEmpty ?? false
            ? QrImageView(
                data: _bookingData!.qrCodes.first.qrCodeData, // Use the latest QR code data
                version: QrVersions.auto,
                size: 150,
                backgroundColor: Colors.white,
                errorStateBuilder: (context, error) {
                  return const Center(
                    child: Text(
                      "Error generating QR",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
                embeddedImage: const AssetImage('assets/logo.png'), // Optional: Add your logo in the center
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(30, 30),
                ),
              )
            : const Center(child: Text('No QR code available')),
      ),
      
      const SizedBox(height: 16),
      
      // Transaction ID
      Text(
        "Transaction ID: ${_bookingData?.parkingSlot ?? 'N/A'}", // Use actual transaction ID from _bookingData
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
      
      const SizedBox(height: 4),
      
      // Invoice number and date
      Text(
        "Invoice #${_bookingData?.parkingSlot ?? 'N/A'}", // Use actual invoice number from _bookingData
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      
      const SizedBox(height: 2),
      
      Text(
        "Issued on ${_bookingData?.bookingTime ?? 'N/A'}", // Use actual booking time from _bookingData
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Route illustration
      _buildRouteDisplay(),
    ],
  ),
),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDottedDivider(),
          ),
          
          const SizedBox(height: 16),
          
          // Booking time and slot
          _buildDetailsSingleLine(),
        ],
      ),
    );
  }

  Widget _buildParkingDetailsCard() {
    if (_bookingData == null) return Container();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          _buildSectionHeader("Parking Details", Icons.local_parking_rounded),
          
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small parking image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: -2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.local_parking,
                    size: 40,
                    color: Colors.deepPurple.shade400,
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
                      _bookingData!.parkingName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      _bookingData!.parkingAddress,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _bookingData!.parkingRating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard() {
    if (_bookingData == null) return Container();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          _buildSectionHeader("Vehicle Information", Icons.directions_car),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.deepPurple.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_bookingData!.vehicleOptions.first.brand} ${_bookingData!.vehicleOptions.first.model}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _bookingData!.vehicleOptions.first.type,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Additional vehicle info (could be license plate, color, etc.)
                Row(
                  children: [
                    _buildVehicleInfoItem("Slot", _bookingData!.parkingSlot),
                    _buildVehicleInfoDivider(),
                    _buildVehicleInfoItem("Floor", "P2"),
                    _buildVehicleInfoDivider(),
                    _buildVehicleInfoItem("Section", "East"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

 Widget _buildPaymentDetailsCard() {
  if (_bookingData == null || _bookingData!.payments.isEmpty) {
    return Center(
      child: Text(
        _bookingData == null
            ? 'No booking data available'
            : 'No payment details available',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  final payment = _bookingData!.payments.first;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
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
      children: [
        _buildSectionHeader("Payment Details", Icons.payment),
        
        const SizedBox(height: 16),
        
        _buildPaymentRow("Parking Fee", "\$${(payment.amount - 5.50).toStringAsFixed(2)}"),
        const SizedBox(height: 10),
        _buildPaymentRow("Service Fee", "\$5.50"),
        const SizedBox(height: 12),
        
        _buildDottedDivider(),
        
        const SizedBox(height: 12),
        _buildPaymentRow("Total Amount", "\$${payment.amount.toStringAsFixed(2)}", isTotal: true),
        
        const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card,
                  color: Colors.deepPurple.shade600,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.paymentMethod,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Paid on ${payment.createdAt}",
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  payment.paymentStatus,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.deepPurple.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.deepPurple.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPoweredBy() {
    return Column(
      children: [
        Text(
          "Thank you for your business",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Powered by ParkEasy",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

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

  Widget _buildRouteDisplay() {
    if (_bookingData == null) return Container();
    return Row(
      children: [
        _buildLocationBadge(_bookingData!.fromLocation, true),
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
        _buildLocationBadge(_bookingData!.toLocation, false),
      ],
    );
  }

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

  Widget _buildDetailsSingleLine() {
    if (_bookingData == null) return Container();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconText(Icons.local_parking_rounded, _bookingData!.parkingSlot),
          Container(height: 24, width: 1, color: Colors.grey.shade300),
          _buildIconText(Icons.access_time_rounded, _bookingData!.bookingTime),
        ],
      ),
    );
  }
  
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

// Keep the DottedLinePainter class since it's still needed for route display
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