import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:autospaze/widget/screens/maps/datatime.dart';
import 'package:autospaze/widget/screens/maps/booking.dart';

class SvgUpdater extends StatefulWidget {
  @override
  _SvgUpdaterState createState() => _SvgUpdaterState();
}

class _SvgUpdaterState extends State<SvgUpdater> {
   int selectedImageIndex = -1;
  final int numRows = 26;
  final double labelSpacing = 2.0;

  List<Map<String, dynamic>> mockSlots = [];
  Map<String, double> slotProgress = {};
  Map<String, Duration> slotTimers = {};
  String? selectedSlotId;
  Timer? progressTimer;
  Offset dragOffset = Offset(0, 0);
  double dragSensitivity = 3.0;
  String selectedVehicleType = "any";

  @override
  void initState() {
  super.initState();

  // Show the initial bottom sheet after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showInitialBottomSheet(context, (selectedType) {
      setState(() {
        selectedVehicleType = selectedType;
      });

      // Ensure parking slots update when a vehicle is selected
      updateParkingSlots();
    });
  });

  // Load JSON data
  loadJson();

  // Start progress updates
  startProgressUpdates();
}
void updateParkingSlots() {
  setState(() {
    for (var slot in mockSlots) {
      if (slot['type'] == selectedVehicleType) {
        slot['status'] = 'reserved'; // Reserve only relevant slots
      } else {
        slot['status'] = 'available'; // Keep others unchanged
      }
    }
  });
}


  @override
  void dispose() {
    progressTimer?.cancel();
    super.dispose();
  }

  Duration parseDuration(String timeStr) {
    List<String> parts = timeStr.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  Future<void> loadJson() async {
    try {
      String jsonString = '''
    [
    {"id": "slot1", "x": 250, "y": 70, "width": 40, "height": 40,  "range": "1-17","availability": false,"reserved": "car"},
    {"id": "slot2", "x": 300, "y": 90, "width": 40, "height": 40,  "range": "1-17","availability": true},
    {"id": "slot3", "x": 350, "y": 60, "width": 40, "height": 40,  "range": "1-17","availability": true},
    {"id": "slot4", "x": 400, "y": 60, "width": 40, "height": 40, "range": "1-17","availability": true},
    {"id": "slot5", "x": 450, "y": 60, "width": 40, "height": 40, "range": "1-17","availability": true},
    {"id": "slot6", "x": 500, "y": 60, "width": 40, "height": 40,  "range": "1-17","availability": true},
    {"id": "slot7", "x": 550, "y": 60, "width": 40, "height": 40, "range": "1-17","availability": true},
    {"id": "slot8", "x": 600, "y": 60, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:01:40", "range": "1-17","availability": false},
    {"id": "slot9", "x": 650, "y": 60, "width": 40, "height": 40, "fill": "#FF0000", "type": "bike", "remainingTime": "00:01:30", "range": "1-17","availability": false},
    {"id": "slot10", "x": 700, "y": 60, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:01:50", "range": "1-17","availability": false},
    {"id": "slot11", "x": 750, "y": 60, "width": 40, "height": 40, "range": "1-17","availability": true},
    {"id": "slot12", "x": 800, "y": 60, "width": 40, "height": 40, "range": "1-17","availability": true},
    {"id": "slot13", "x": 850, "y": 60, "width": 40, "height": 40,  "range": "1-17","availability": true},
    {"id": "slot14", "x": 900, "y": 60, "width": 40, "height": 40,  "range": "1-17","availability": true, "startTime": "2025-01-18T08:00:00Z","exitTime": "2025-01-18T10:00:00Z"},
    {"id": "entry", "x": 950, "y": 60, "width": 100, "height": 100, "range": "1-17"},

     
    {"id": "slot15", "x": 1000, "y": 60, "width": 40, "height": 40, "fill": "#00FF00", "range": "18-33"},
    
    
   {"id": "slot16", "x": 250, "y": 120, "width": 40, "height": 40,"availability": true, "range": "18-33"},
    {"id": "slot17", "x": 300, "y": 120, "width": 40, "height": 40, "availability": true, "range": "18-33"},
    {"id": "slot18", "x": 350, "y": 120, "width": 40, "height": 40, "availability": true,"range": "18-33"},
    {"id": "slot19", "x": 400, "y": 120, "width": 40, "height": 40, "availability": true, "range": "18-33"},
    {"id": "slot20", "x": 450, "y": 120, "width": 40, "height": 40, "fill": "#ECECEC", "type": "car", "remainingTime": "00:50:00", "range": "18-33"},
    {"id": "slot21", "x": 500, "y": 120, "width": 40, "height": 40, "fill": "#00FF00", "type": "bike", "remainingTime": "00:25:00", "range": "18-33"},
    {"id": "slot22", "x": 550, "y": 120, "width": 40, "height": 40, "fill": "#ECECEC", "type": "car", "remainingTime": "00:40:00", "range": "18-33"},
    {"id": "slot23", "x": 600, "y": 120, "width": 40, "height": 40, "fill": "#00FF00", "type": "bike", "remainingTime": "00:20:00", "range": "18-33"},
    {"id": "slot24", "x": 650, "y": 120, "width": 40, "height": 40, "fill": "#ECECEC", "type": "car", "remainingTime": "00:55:00", "range": "18-33"},
    {"id": "slot25", "x": 700, "y": 120, "width": 40, "height": 40, "fill": "#00FF00", "type": "bike", "remainingTime": "00:35:00", "range": "18-33"},
    {"id": "slot26", "x": 750, "y": 120, "width": 40, "height": 40, "fill": "#ECECEC", "type": "car", "remainingTime": "01:10:00", "range": "18-33"},
    {"id": "slot27", "x": 800, "y": 120, "width": 40, "height": 40, "fill": "#00FF00", "type": "bike", "remainingTime": "00:25:00", "range": "18-33"},
    {"id": "slot28", "x": 850, "y": 120, "width": 40, "height": 40, "fill": "#ECECEC", "type": "car", "remainingTime": "00:30:00", "range": "18-33"},

    
   {"id": "slot29", "x": 900, "y": 120, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot30", "x": 950, "y": 120, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot31", "x": 1000, "y": 120, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot32", "x": 700, "y": 200, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot33", "x": 750, "y": 200, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot34", "x": 800, "y": 200, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot35", "x": 850, "y": 200, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot36", "x": 900, "y": 200, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot37", "x": 950, "y": 200, "width": 40, "height": 40, "availability": true, "range": "32-40", "reserved": "bike"},
  {"id": "slot38", "x": 600, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot39", "x": 650, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot40", "x": 700, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot41", "x": 750, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot42", "x": 800, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot43", "x": 850, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot44", "x": 900, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot45", "x": 950, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},
  {"id": "slot46", "x": 1000, "y": 350, "width": 40, "height": 40, "availability": true, "range": "40-48", "reserved": "bike"},


  {"id": "slot47", "x": 600, "y": 350, "width": 40, "height": 40, "fill": "#00FF00", "type": "bike", "remainingTime": "00:01:35", "range": "49-55"},
  {"id": "slot48", "x": 650, "y": 350, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:45", "range": "49-55"},
  {"id": "slot49", "x": 700, "y": 350, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:55", "range": "49-55"},
  {"id": "slot50", "x": 750, "y": 350, "width": 40, "height": 40,"availability": true, "range": "49-55"},
  {"id": "slot51", "x": 800, "y": 350, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:30", "range": "49-55"},
  {"id": "slot52", "x": 850, "y": 350, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:50", "range": "49-55"},
  {"id": "slot53", "x": 900, "y": 350, "width": 40, "height": 40, "availability": true, "range": "49-55"},
  {"id": "slot54", "x": 950, "y": 350, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:25", "range": "49-55"},
  {"id": "slot55", "x": 1000, "y": 350, "width": 40, "height": 40, "availability": true, "range": "49-55"},

   {"id": "slot56", "x": 250, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:30", "range": "56-64"},
  {"id": "slot57", "x": 300, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:40", "range": "56-64"},
  {"id": "slot58", "x": 350, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:50", "range": "56-64"},
  {"id": "slot59", "x": 400, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:45", "range": "56-64"},
  {"id": "slot60", "x": 450, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:55", "range": "56-64"},
  {"id": "slot61", "x": 500, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:40", "range": "56-64"},
  {"id": "slot62", "x": 550, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:30", "range": "56-64"},
  {"id": "slot63", "x": 600, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:50", "availability": false, "range": "56-64"},
  {"id": "slot64", "x": 650, "y": 490, "width": 40, "height": 40,  "availability": true, "range": "56-64"},

    {"id": "slot65", "x": 700, "y": 490, "width": 40, "height": 40, "availability": true, "range": "65-78","reserved": "car"},
  {"id": "slot66", "x": 750, "y": 490, "width": 40, "height": 40,"availability": true, "range": "65-78","reserved": "car"},
  {"id": "slot67", "x": 800, "y": 490, "width": 40, "height": 40,"availability": true, "range": "65-78","reserved": "car"},
  {"id": "slot68", "x": 400, "y": 490, "width": 40, "height": 40,"availability": true,"range": "65-78","reserved": "car"},
  {"id": "slot69", "x": 450, "y": 490, "width": 40, "height": 40, "availability": true, "range": "65-78","reserved": "car"},
  {"id": "slot70", "x": 500, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:40","range": "65-78","reserved": "car"},
  {"id": "slot71", "x": 550, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:30", "availability": false,"range": "65-78","reserved": "car"},
  {"id": "slot72", "x": 600, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:50", "availability": false,"range": "65-78","reserved": "car"},
  {"id": "slot73", "x": 650, "y": 490, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:35", "availability": false, "range": "65-78","reserved": "car"},
  {"id": "slot74", "x": 300, "y": 550, "width": 40, "height": 40, "availability": true,"range": "65-78","reserved": "car"},
  {"id": "slot75", "x": 350, "y": 550, "width": 40, "height": 40, "availability": true,"range": "65-78","reserved": "car"},
  {"id": "slot76", "x": 400, "y": 550, "width": 40, "height": 40, "fill": "#00FF00", "type": "car", "remainingTime": "00:00:50","range": "65-78","reserved": "car"},
  {"id": "slot77", "x": 450, "y": 550, "width": 40, "height": 40, "availability": true,"range": "65-78","reserved": "car"},
  {"id": "slot78", "x": 500, "y": 550, "width": 40, "height": 40, "availability": true,"range": "65-78","reserved": "car"},
   {"id": "exit", "x": 550, "y": 550, "width": 100, "height": 100, "fill": "#00FF00","range": "65-78","reserved": "car"},

   
   {"id": "slot79", "x": 600, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot80", "x": 650, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot81", "x": 700, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot82", "x": 750, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot83", "x": 800, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot84", "x": 850, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot85", "x": 900, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot86", "x": 950, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot87", "x": 1000, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot88", "x": 1050, "y": 550, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot89", "x": 1100, "y": 500, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot90", "x": 1150, "y": 500, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot91", "x": 1200, "y": 500, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"},
  {"id": "slot92", "x": 1250, "y": 500, "width": 40, "height": 40, "availability": true, "range": "79-89", "reserved": "car"}





    
    



  
  

]
    ''';

      List<dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        double initialX = 2; // Starting X value for the first slot
        double initialY = 50; // Starting Y value for the first row
        double xIncrement = 159; // Horizontal space between slots
        // Vertical space between rows
        double extraRangeGap = 80; // Extra vertical gap after each range
        int slotsPerRow = 18; // Maximum slots per row (adjustable)
        double x = initialX; // Initialize X
        double y = initialY; // Initialize Y
        String currentRange = '';
        // Track the current range

        mockSlots = [];
        List<Map<String, dynamic>> currentRangeSlots = [];

        for (var slot in jsonResponse) {
          String range = slot['range'] ?? '';
          List<String> rangeParts = range.split('-');
          int rangeStart = int.tryParse(rangeParts[0]) ?? 0;
          int rangeEnd = rangeParts.length > 1
              ? int.tryParse(rangeParts[1]) ?? 0
              : rangeStart;

          // If range changes, reset the position and start a new row
          if (currentRange != range) {
            if (currentRangeSlots.isNotEmpty) {
              mockSlots
                  .addAll(currentRangeSlots); // Add the processed range slots
              currentRangeSlots.clear(); // Clear for the next range
              // Move to the next range row
              x = initialX; // Reset X position
              y += extraRangeGap; // Add extra vertical gap after the range
            }
            currentRange = range; // Update current range
          }

          // Calculate x and y for the current slot
          double tempX = x; // Assign X coordinate
          double tempY = y; // Assign Y coordinate

          // **Swap logic**: Swap x and y for specific adjustments
          double temp = tempX;
          tempX = tempY;
          tempY = temp;

          // Assign the swapped coordinates to the slot
          slot['x'] = tempX;
          slot['y'] = tempY;

          // Add slot to the current range list
          currentRangeSlots.add(slot);

          // Update X for the next slot
          x += xIncrement;

          // Ensure consistent horizontal gap
          if (currentRangeSlots.length % slotsPerRow == 0) {
            x = initialX; // Reset X for the new row
            // Move to the next row
          }
        }

        // Add the last range's slots
        if (currentRangeSlots.isNotEmpty) {
          mockSlots.addAll(currentRangeSlots);
        }

        // Initialize slot progress and timers
        for (var slot in mockSlots) {
          String slotId = slot['id'] ?? 'unknown';
          String? remainingTimeStr = slot['remainingTime'];
          Duration remainingTime = remainingTimeStr != null
              ? parseDuration(remainingTimeStr)
              : Duration.zero;
          slotProgress[slotId] = 1.0;
          slotTimers[slotId] = remainingTime;
        }

        // Debugging print
        for (var slot in mockSlots) {
          print('Slot: id = ${slot['id']}, x = ${slot['x']}, y = ${slot['y']}');
        }
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  String formatRemainingTime(Duration duration) {
    if (duration == Duration.zero) return '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void startProgressUpdates() {
    progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        bool allZero = true;
        slotTimers.forEach((slotId, remainingTime) {
          if (remainingTime > Duration.zero) {
            allZero = false;
            slotTimers[slotId] = remainingTime - const Duration(seconds: 1);
            Duration initialTime = parseDuration(mockSlots
                .firstWhere((slot) => slot['id'] == slotId)['remainingTime']);
            slotProgress[slotId] =
                slotTimers[slotId]!.inSeconds / initialTime.inSeconds;
          } else {
            slotProgress[slotId] = 0;
          }
        });

        if (allZero) {
          timer.cancel();
        }
      });
    });
  }

  void selectSlot(String slotId) {
    setState(() {
      selectedSlotId = (selectedSlotId == slotId) ? null : slotId;
    });
  }

// Function to convert row index to A-Z, AA, AB, etc.

final List<String> imageUrls = [
    'https://res.cloudinary.com/dwdatqojd/image/upload/v1738778166/060c9fri-removebg-preview_lqj6eb.png',
    'https://res.cloudinary.com/dwdatqojd/image/upload/v1738776910/wmremove-transformed-removebg-preview_sdjfbl.png',
    'https://res.cloudinary.com/dwdatqojd/image/upload/v1738778166/060c9fri-removebg-preview_lqj6eb.png',
  ];

  

void showInitialBottomSheet(BuildContext context, Function(String) onVehicleSelected) {
  int selectedImageIndex = 0; // Local state for selected vehicle

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          List<Map<String, dynamic>> vehicleOptions = [
            {'icon': Icons.directions_car, 'label': "Car", 'type': "car"},
            {'icon': Icons.directions_bike, 'label': "Bike", 'type': "bike"},
            {'icon': Icons.directions_bus, 'label': "Bus", 'type': "bus"},
          ];

          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your vehicle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Vehicle selection list
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicleOptions.length,
                    itemBuilder: (context, index) {
                      var vehicle = vehicleOptions[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImageIndex = index;
                          });

                          // Send selected vehicle type to parent widget
                          onVehicleSelected(vehicle['type']);

                          // Print the selected vehicle type in the terminal
                          print("Selected Vehicle Type: ${vehicle['type']}");
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: Container(
                              width: 120,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedImageIndex == index
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    vehicle['icon'],
                                    size: 80,
                                    color: selectedImageIndex == index
                                        ? Colors.black
                                        : Colors.grey[700],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    vehicle['label'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Close Button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}



 void showSlotDetails(Map<String, dynamic> slot) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allow the bottom sheet to be as tall as its content
    backgroundColor: Colors.white, // Optional: Customize the background color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (BuildContext context) {
      String slotId = slot['id'] ?? 'Unknown';
      String type = slot['type'] ?? 'Unknown';
      String startTime = slot['startTime'] ?? 'Unknown';
      String exitTime = slot['exitTime'] ?? 'Unknown';

      Duration remainingTime = slotTimers[slotId] ?? Duration.zero;
      String formattedTime = formatRemainingTime(remainingTime);
      
      bool isAvailable = slot['availability'] ?? false;

      return Padding(
        padding: const EdgeInsets.all(16.0), // Optional: Customize padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot Details: $slotId',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black, size: 30),
                  onPressed: () => Navigator.of(context).pop(), // Close the bottom sheet
                ),
              ],
            ),
            SizedBox(height: 40),
            Text('Type: $type'),
            Text('Remaining Time: $formattedTime'),

            SizedBox(height: 40),
            if (isAvailable) // Show "Book Slot" button only if the slot is available
              ElevatedButton(
                onPressed: () {
                 
                  // Show dialog when the user books the slot
                 

                  // Optionally close bottom sheet after booking (if any)
                  Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => NextPage()),
                              );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(5),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                child: Text('Book Slot'),
              ),
            if (!isAvailable) // If the slot is not available, show a disabled button
              ElevatedButton(
                onPressed: null, // Disable the button
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey), // Disabled color
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )),
                  elevation: MaterialStateProperty.all(0), // Remove elevation for disabled state
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                child: Text('Slot Unavailable'),
              ),
          ],
        ),
      );
    },
  );
}


  Widget getSlotIcon(String? type) {
    switch (type) {
      case 'car':
        return Icon(Icons.directions_car, size: 18, color: Colors.white);
      case 'bike':
        return Icon(Icons.directions_bike, size: 18, color: Colors.white);
      default:
        return SizedBox();
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DateTimeRangePickerScreen(),
            ),
          );
        },
      ),
    ),
    backgroundColor: Colors.white,
    body: Column(
      children: [
        // Parking Slot Layout
        Expanded(
          child: mockSlots.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
              : GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      dragOffset = Offset(
                        dragOffset.dx +
                            details.localPosition.dx * dragSensitivity,
                        dragOffset.dy +
                            details.localPosition.dy * dragSensitivity,
                      );

                      // Implementing wraparound or infinite scroll horizontally
                      if (dragOffset.dx > 3000) {
                        dragOffset = Offset(dragOffset.dx - 3000, dragOffset.dy);
                      } else if (dragOffset.dx < 0) {
                        dragOffset = Offset(dragOffset.dx + 3000, dragOffset.dy);
                      }

                      // Implementing wraparound or infinite scroll vertically
                      if (dragOffset.dy > 3000) {
                        dragOffset = Offset(dragOffset.dx, dragOffset.dy - 3000);
                      } else if (dragOffset.dy < 0) {
                        dragOffset = Offset(dragOffset.dx, dragOffset.dy + 3000);
                      }
                    });
                  },
                  child: InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.8,
                    maxScale: 4.0,
                    onInteractionUpdate: (details) {
                      if (details.scale <= 0.3) {
                        setState(() {
                          dragOffset = Offset(0.0, 0.0);
                        });
                      }
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: 3000,
                          height: 3000,
                          child: Stack(children: [
                            for (int i = 0; i < numRows; i++)
                              Positioned(
                                left: 20,
                                top: (80.0 + labelSpacing) * i,
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ...mockSlots.map((slot) {
                              String slotId = slot['id'] ?? 'unknown';
                              bool isSelected = selectedSlotId == slotId;
                              return Positioned(
                                left: slot['x'] + dragOffset.dx,
                                top: slot['y'] + dragOffset.dy,
                                child: SlotWidget(
                                  slot: slot,
                                  progress: slotProgress[slotId] ?? 1.0,
                                  isSelected: isSelected,
                                  onSelect: () {
                                    selectSlot(slotId);
                                    showSlotDetails(slot);
                                  },
                                  getIcon: getSlotIcon,
                                  timerText: formatRemainingTime(
                                      slotTimers[slotId] ?? Duration.zero),
                                ),
                              );
                            }).toList(),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
        ),

        // Legend Section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendBox(Colors.blueAccent, "Bike"),
              SizedBox(width: 10),
              _buildLegendBox(Colors.orangeAccent, "Car"),
              SizedBox(width: 10),
              _buildLegendBox(const Color.fromARGB(255, 82, 23, 23), "Bus"),
            ],
          ),
        ),
      ],
    ),
  );
}

// Function to create the legend boxes
Widget _buildLegendBox(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
      SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

}

class SlotWidget extends StatelessWidget {
  final Map<String, dynamic> slot;
  final double progress;
  final bool isSelected;
  final VoidCallback onSelect;
  final Widget Function(String?) getIcon;
  final String timerText;

  const SlotWidget({
    Key? key,
    required this.slot,
    required this.progress,
    required this.isSelected,
    required this.onSelect,
    required this.getIcon,
    required this.timerText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double xPosition = (slot['x'] ?? 0).toDouble();
    double yPosition = (slot['y'] ?? 0).toDouble();

    if (screenWidth < 600) {
      xPosition /= 1.22;
      yPosition /= 2;
    }

    Color borderColor = isSelected
        ? Colors.green
        : (slot['reserved'] == 'car')
            ? Colors.orangeAccent
            : (slot['reserved'] == 'bike')
                ? Colors.blueAccent
                : const Color.fromARGB(255, 40, 237, 10);

    Color fillColor = isSelected
        ? const Color.fromARGB(255, 40, 237, 10)
        : slot['availability'] == null || slot['availability'] == false
            ? const Color.fromARGB(255, 37, 255, 44)
            : Colors.white;


Color textColor = isSelected 
    ? Colors.white // White text when selected
    : (slot['reserved'] == 'car')
        ? Colors.orangeAccent
        : (slot['reserved'] == 'bike')
            ? Colors.blue
            : const Color.fromARGB(255, 40, 237, 10);

    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onTap: onSelect,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress > 0)
              Container(
                width: (slot['width'] ?? 20).toDouble(),
                height: 6,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            Container(
              width: (slot['width'] ?? 20).toDouble(),
              height: (slot['height'] ?? 20).toDouble(),
              decoration: BoxDecoration(
  color: fillColor,
  borderRadius: BorderRadius.circular(4),
  border: Border.all(
    color: slot['availability'] == false ? const Color.fromARGB(255, 40, 237, 10) : borderColor, 
    width: 1.2,
  ),
),

              child: Stack(
                children: [
                  Center(
                    child: slot.containsKey('type') && slot['type'] != null
                        ? getIcon(slot['type'])
                        : Text(
  slot.containsKey('id') && slot['id'].contains(RegExp(r'\d+'))
      ? RegExp(r'\d+').firstMatch(slot['id'])!.group(0)! // Extract number
      : '', // Fallback if no number found
  style: TextStyle(
    color: textColor, // Apply dynamic text color
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

                  ),
                  if (timerText.isNotEmpty)
                    Positioned(
                      bottom: 1,
                      left: 4,
                      child: Text(
                        timerText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
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
}


 Color _parseColor(String colorString, bool isSelected) {
  // Check if the slot is selected
  if (isSelected) {
    return Colors.red; // Return red color if selected
  }

  // Handle custom color string parsing
  

  // Default color if the string is invalid
  return Colors.grey.shade400;
}



void showSlotDetailsBottomSheet(BuildContext context, Map<String, dynamic> slot) {
   showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full-height modal if needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        height: 300, // 👈 Fixed height for the popup
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Fixed Height Popup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('This popup has a fixed height of 300 pixels.'),
              Spacer(), // Pushes button to the bottom
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }