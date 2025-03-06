import 'dart:convert';

import 'package:autospaze/widget/models/user.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:autospaze/widget/screens/bookings/BookingPage.dart';
import 'package:autospaze/widget/screens/bookings/booking_page_widgets.dart';
import 'package:autospaze/widget/screens/bookings/circular_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DateTimePickerPage extends StatefulWidget {
  const DateTimePickerPage({super.key});

  @override
  _DateTimePickerPageState createState() => _DateTimePickerPageState();
}

class _DateTimePickerPageState extends State<DateTimePickerPage> with SingleTickerProviderStateMixin {
  // Controllers
  late RulerPickerController _rulerPickerController;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late BookingData _bookingData; // Ensure this is initialized

  // State variables
  num currentValue = 0;
  DateTime? selectedDate;
  int selectedHours = 1;
  bool _isInteracting = false;
  bool _showButton = false;
  
  // Time ranges for ruler picker
  List<RulerRange> timeRanges = const [
    RulerRange(begin: -12, end: 12, scale: 0.05),
  ];

  @override
  void initState() {
    super.initState();
    _rulerPickerController = RulerPickerController(value: currentValue);
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Create animations
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );

    // Initialize _bookingData here
    _bookingData = BookingData(
      fromLocation: "New York",
      toLocation: "Los Angeles",
      parkingSlot: "A1",
      bookingTime: "10:00 AM",
      parkingName: "Central Parking Lot",
      parkingAddress: "123 Main St, New York, NY 10001",
      parkingRating: 4.5,
      vehicleOptions: [
        VehicleOption(brand: "Toyota", model: "Camry", type: "Sedan", isDefault: true),
        VehicleOption(brand: "Honda", model: "Civic", type: "Sedan", isDefault: false),
        VehicleOption(brand: "Tesla", model: "Model S", type: "Electric", isDefault: false),
      ],
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Utility methods
  String formatTime(num value) {
    int totalMinutes = ((value + 12) * 60).toInt();
    int hour = (totalMinutes ~/ 60) % 24;
    int minutes = totalMinutes % 60;
    
    String period = hour >= 12 ? "PM" : "AM";
    int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return "$displayHour:${minutes.toString().padLeft(2, '0')} $period";
    
  }
String formatTimeForTerminal(num value) {
  if (selectedDate == null) {
    return "Date not selected";
  }
  int totalMinutes = ((value + 12) * 60).toInt();
  int hour = (totalMinutes ~/ 60) % 24;
  int minutes = totalMinutes % 60;

  // Combine the selected date with the calculated time
  DateTime combinedDateTime = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    hour,
    minutes,
  );

  // Format the combined date and time in ISO 8601 format
  return combinedDateTime.toIso8601String();
}
  String calculateEndTime() {
    int totalMinutes = ((currentValue + 12) * 60).toInt();
    int hour = (totalMinutes ~/ 60) % 24;
    int minutes = totalMinutes % 60;
    DateTime startTime = DateTime(2025, 1, 1, hour, minutes);
    DateTime endTime = startTime.add(Duration(hours: selectedHours));
    return DateFormat('hh:mm a').format(endTime);
  }

  int calculateFare() => selectedHours * 15;

  bool _areAllFieldsEntered() => selectedDate != null;

  // UI interaction methods
  Future<void> _selectDate(BuildContext context) async {
    setState(() {
      _isInteracting = true;
      _hideButton();
    });
    
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
    
    setState(() {
      _isInteracting = false;
      _checkAndShowButton();
    });
  }

  void _updateSelectedHours(int newHours) {
    setState(() {
      _isInteracting = true;
      _hideButton();
      selectedHours = newHours;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isInteracting = false;
          _checkAndShowButton();
        });
      }
    });
  }
  
  void _handleRulerValueChanged(num value) {
    setState(() {
      _isInteracting = true;
      _hideButton();
      currentValue = value;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isInteracting = false;
          _checkAndShowButton();
        });
      }
    });
  }
  
  void _hideButton() {
    if (_showButton) {
      setState(() {
        _showButton = false;
      });
      _animationController.reverse();
    }
  }
  
  void _checkAndShowButton() {
    if (!_isInteracting && _areAllFieldsEntered() && !_showButton) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_isInteracting && _areAllFieldsEntered()) {
          setState(() {
            _showButton = true;
          });
          _animationController.forward();
        }
      });
    } else if (!_areAllFieldsEntered() && _showButton) {
      _hideButton();
    }
  }
void _handleSubmit(BuildContext context) async {
  // Get the userProvider instance
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final User? user = userProvider.user;

  // Get the booking details as a custom object
  BookingDetails details = getBookingDetails();

  // Print the booking details to the terminal
  print('Booking Details:');
  print('From Time: ${formatTimeForTerminal(currentValue)}'); // Use formatTimeForTerminal
  print('To Time: ${formatTimeForTerminal(currentValue + selectedHours)}'); // Adjust for end time
  print('Fare: ${details.fare}');
  if (details.selectedDate != null) {
    print('Selected Date: ${DateFormat('yyyy-MM-dd').format(details.selectedDate!)}');
  } else {
    print('Selected Date: Not selected');
  }

  if (user != null) {
    // Retrieve the slotId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? slotId = prefs.getString('slot_id'); // Ensure the key matches what was saved

    // Print statement to verify the slotId retrieval
    print('Retrieved Slot ID: $slotId');

    if (slotId != null) {
      // Prepare the API request
      final String exitTime = formatTimeForTerminal(currentValue + selectedHours); // Use formatTimeForTerminal for exit time
      final String userId = user.id;

      // Print the request URL
      print('Request URL: http://localhost:8080/api/parking-slots/$slotId/exit-time?exitTime=$exitTime&userId=$userId');

      // Call the API to update the exit time
      final response = await http.patch(
        Uri.parse('http://localhost:8080/api/parking-slots/$slotId/exit-time?exitTime=$exitTime&userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Print the response status code and body
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Navigate to the BookingPage with the booking data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(
              bookingData: _bookingData,
            ),
          ),
        );
      } else {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update exit time')),
        );
      }
    } else {
      // Show an error message if slotId is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot ID not found')),
      );
    }
  } else {
    // Show an error message if user is not logged in
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not logged in')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.black, Colors.deepPurple],
                ).createShader(bounds),
                child: const Text(
                  "Please Select Further Information",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main scrollable content
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20),
            
                      // Date Picker Button
                      _buildDatePickerButton(),
            
                      const SizedBox(height: 30),
            
                      // Time Display
                      Text(
                        formatTime(currentValue),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
            
                      const SizedBox(height: 10),
            
                      // Time Ruler Picker
                      RulerPicker(
                        controller: _rulerPickerController,
                        onBuildRulerScaleText: (index, value) => formatTime(value),
                        ranges: timeRanges,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 100,
                        onValueChanged: _handleRulerValueChanged,
                      ),
            
                      const SizedBox(height: 10),
            
                      // "From - To" & Fare Display
                      _buildTimeAndFareDisplay(),
            
                      const SizedBox(height: 10),
            
                      // Circular Duration Picker
                      SizedBox(
                        height: 250,
                        child: CircleMenu(
                          onHoursChanged: _updateSelectedHours,
                        ),
                      ),
            
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            // Floating Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selectedDate == null ? Colors.redAccent : Colors.purple,
            width: 2,
          ),
          boxShadow: selectedDate == null ? [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              color: selectedDate == null ? Colors.redAccent : Colors.purple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(selectedDate!)
                  : "Select Date *",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selectedDate == null ? Colors.redAccent : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAndFareDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _timeBlock("From", formatTime(currentValue), Icons.access_time),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            _timeBlock("To", calculateEndTime(), Icons.timer_off),
            _timeBlock("Fare", "₹${calculateFare()}", Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _timeBlock(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Center(
                child: Container(
                  height: 60,
                  width: 220,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.deepPurple.shade700,
                        Colors.purple.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Material(
  color: Colors.transparent,
  child: InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: _showButton ? () => _handleSubmit(context) : null,
    splashColor: Colors.white.withOpacity(0.2),
    highlightColor: Colors.transparent,
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'CONFIRM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    ),
  ),
),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BookingDetails getBookingDetails() {
    String fromTime = formatTime(currentValue);
    String toTime = calculateEndTime();
    String fare = "₹${calculateFare()}";
    
    return BookingDetails(fromTime: fromTime, toTime: toTime, fare: fare,selectedDate: selectedDate);
  }
}

class BookingDetails {
  final String fromTime;
  final String toTime;
  final String fare;
  final DateTime? selectedDate;

  BookingDetails({required this.fromTime, required this.toTime, required this.fare, this.selectedDate,});
}

// Example usage
void main() {
  runApp(MaterialApp(home: DateTimePickerPage()));
}