import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Added QR code package

class InvoicePage extends StatefulWidget {
  final String fromLocation;
  final String toLocation;
  final String parkingSlot;
  final String bookingTime;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleType;
  final String parkingName;
  final String parkingAddress;
  final double parkingRating;
  final String invoiceNumber;
  final String bookingDate;
  final double amount;
  final String paymentMethod;
  final String transactionId;

  const InvoicePage({
    super.key,
    this.fromLocation = "Current Location",
    this.toLocation = "Destination",
    this.parkingSlot = "A1",
    this.bookingTime = "10:30 AM - 12:30 PM",
    this.vehicleBrand = "Mercedes-Benz",
    this.vehicleModel = "CL63 AMG",
    this.vehicleType = "Long coupe",
    this.parkingName = "Downtown Secure Parking",
    this.parkingAddress = "123 Main Street, City Center",
    this.parkingRating = 4.7,
    this.invoiceNumber = "INV-20250302-7842",
    this.bookingDate = "March 2, 2025",
    this.amount = 45.50,
    this.paymentMethod = "Credit Card",
    this.transactionId = "TXN-78943213",
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
        title: const Text("Invoice", 
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: AnimatedBuilder(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard() {
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
                  child: QrImageView(
                    data: widget.transactionId,
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
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Transaction ID
                Text(
                  "Transaction ID: ${widget.transactionId}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Invoice number and date
                Text(
                  "Invoice #${widget.invoiceNumber}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  "Issued on ${widget.bookingDate}",
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
                      widget.parkingName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      widget.parkingAddress,
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
                          widget.parkingRating.toString(),
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
                            "${widget.vehicleBrand} ${widget.vehicleModel}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.vehicleType,
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
                    _buildVehicleInfoItem("Slot", widget.parkingSlot),
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
          
          _buildPaymentRow("Parking Fee", "\$${(widget.amount - 5.50).toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _buildPaymentRow("Service Fee", "\$5.50"),
          const SizedBox(height: 12),
          
          _buildDottedDivider(),
          
          const SizedBox(height: 12),
          _buildPaymentRow("Total Amount", "\$${widget.amount.toStringAsFixed(2)}", 
            isTotal: true),
          
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
                      widget.paymentMethod,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Paid on ${widget.bookingDate}",
                      style: TextStyle(
                        fontSize: 13,
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
                    "Paid",
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
    return Row(
      children: [
        _buildLocationBadge(widget.fromLocation, true),
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
        _buildLocationBadge(widget.toLocation, false),
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
          _buildIconText(Icons.local_parking_rounded, widget.parkingSlot),
          Container(height: 24, width: 1, color: Colors.grey.shade300),
          _buildIconText(Icons.access_time_rounded, widget.bookingTime),
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