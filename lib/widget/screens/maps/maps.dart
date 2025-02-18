import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:autospaze/widget/screens/maps/datatime.dart';
import 'package:autospaze/widget/screens/maps/booking.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SvgUpdater extends StatefulWidget {
  final String searchQuery;
  final String parkingId;
  final String parkingSlots;

  const SvgUpdater({
    Key? key,
    required this.searchQuery,
    required this.parkingId,
    required this.parkingSlots,

  }) : super(key: key);

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
  List<Map<String, dynamic>> parkingSlots = [];
  String errorMessage = "";
  bool showErrorImage = false;

  
@override
void initState() {
  super.initState();

  // Show the initial bottom sheet
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showInitialBottomSheet(context, (selectedType) {
      setState(() {
        selectedVehicleType = selectedType;
      });
      updateParkingSlots();
    });
  });

  // Fetch slots from API and load them
  fetchParkingDetails().then((_) {
    if (parkingSlots.isNotEmpty) {
      loadJson(jsonEncode(parkingSlots)); // Pass fetched slots
    }
  });

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

 // Add this at the top
Future<void> fetchParkingDetails() async {
  try {
    int parkingId = int.parse(widget.parkingId);
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/parking-slots/spot/$parkingId'),
    );

    if (response.statusCode == 200) {
      await loadJson(response.body); // Pass API response to loadJson
      setState(() {
        errorMessage = 'Please select a parking area first'; // Clear any previous error messages on success
        showErrorImage = false; // Ensure no error image is shown
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load parking details. Status code: ${response.statusCode}';
        showErrorImage = false; // Ensure no error image is shown
      });
    }
  } catch (e) {
    setState(() {
      showErrorImage = true; // Show error image
    });
    print("Error fetching parking spot: $e");
  }
}




Future<Map<String, dynamic>?> fetchParkingSpotById(int parkingId) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/parking-slots/spot/$parkingId'),
    );

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);

      // Check if the response is a List or a Map
      if (decodedData is List && decodedData.isNotEmpty) {
        // Use the first item from the list
        Map<String, dynamic> data = decodedData.first;

        return {
          'id': data['id'],
          'name': data['parkingSpot']['name'],
          'description': data['parkingSpot']['description'],
          'imageUrl': data['parkingSpot']['imageUrl'],
          'latitude': data['parkingSpot']['latitude'],
          'longitude': data['parkingSpot']['longitude'],
          'x': data['x'],
          'y': data['y'],
        };
      } else if (decodedData is Map<String, dynamic>) {
        // If it's already a Map
        return {
          'id': decodedData['id'],
          'name': decodedData['parkingSpot']['name'],
          'description': decodedData['parkingSpot']['description'],
          'imageUrl': decodedData['parkingSpot']['imageUrl'],
          'latitude': decodedData['latitude'],
          'longitude': decodedData['longitude'],
          'x': decodedData['x'],
          'y': decodedData['y'],
        };
      } else {
        print("Unexpected response format: $decodedData");
        return null;
      }
    } else {
      print("Failed to load parking spot. Status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error fetching parking spot by ID: $e");
    return null;
  }
}

Future<void> loadJson(String jsonEncode) async {
  try {
    List<dynamic> jsonResponse = jsonDecode(jsonEncode); // Use passed JSON
    setState(() {
      double initialX = 2; 
      double initialY = 50; 
      double xIncrement = 159; 
      double extraRangeGap = 80; 
      int slotsPerRow = 18; 
      double x = initialX; 
      double y = initialY; 
      String currentRange = ''; 

      mockSlots = [];
      List<Map<String, dynamic>> currentRangeSlots = [];

      for (var slot in jsonResponse) {
        String range = slot['range'] ?? '';
        List<String> rangeParts = range.split('-');
        int rangeStart = int.tryParse(rangeParts[0]) ?? 0;
        int rangeEnd = rangeParts.length > 1
            ? int.tryParse(rangeParts[1]) ?? 0
            : rangeStart;

        if (currentRange != range) {
          if (currentRangeSlots.isNotEmpty) {
            mockSlots.addAll(currentRangeSlots); 
            currentRangeSlots.clear(); 
            x = initialX; 
            y += extraRangeGap; 
          }
          currentRange = range; 
        }

        double tempX = x; 
        double tempY = y; 

        // Swap x and y
        double temp = tempX;
        tempX = tempY;
        tempY = temp;

        slot['x'] = tempX;
        slot['y'] = tempY;

        currentRangeSlots.add(slot);
        x += xIncrement;

        if (currentRangeSlots.length % slotsPerRow == 0) {
          x = initialX; 
        }
      }

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

      // Debug print
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

  void showInitialBottomSheet(
      BuildContext context, Function(String) onVehicleSelected) {
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
      isScrollControlled:
          true, // Allow the bottom sheet to be as tall as its content
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
                    onPressed: () =>
                        Navigator.of(context).pop(), // Close the bottom sheet
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text('Type: $type'),
              Text('Remaining Time: $formattedTime'),
              SizedBox(height: 40),
              if (isAvailable) // Show "Book Slot" button only if the slot is available
                ElevatedButton(
                  onPressed: () async {
                    if (widget.parkingId == null ||
                        widget.parkingId.trim().isEmpty) {
                      print("Error: Parking ID is empty");
                      return;
                    }
                    try {
                      int parkingId = int.parse(widget.parkingId.trim());
                      Map<String, dynamic>? parkingSpot =
                          await fetchParkingSpotById(parkingId);
                      if (parkingSpot != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NextPage(
                              parkingId: widget.parkingId,
                              searchQuery: '',
                            ),
                          ),
                        );
                      } else {
                        print("No spot found for ID: $parkingId");
                      }
                    } catch (e) {
                      print("Error fetching parking spots: $e");
                    } catch (e) {
                      print("Error fetching parking spots: $e");
                    }
                  },

                  // Show dialog when the user books the slot

                  // Optionally close bottom sheet after booking (if any)

                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    elevation: MaterialStateProperty.all(5),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  child: Text('Book Slot'),
                ),
              if (!isAvailable) // If the slot is not available, show a disabled button
                ElevatedButton(
                  onPressed: null, // Disable the button
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.grey), // Disabled color
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    )),
                    elevation: MaterialStateProperty.all(
                        0), // Remove elevation for disabled state
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          print("Back button pressed. Parking ID: ${widget.parkingId}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DateTimeRangePickerScreen(
                parkingId: '',
              ),
            ),
          );
        },
      ),
    ),
    backgroundColor: Colors.white,
    body: Column(
      children: [
        // Error Image and Text
        if (showErrorImage)
          Align(
            alignment: Alignment.bottomCenter, // Align to the bottom center
            child: Column(
              mainAxisSize: MainAxisSize.min, // Minimize the height of the column
              children: [
                Image.network(
                  'https://res.cloudinary.com/dwdatqojd/image/upload/v1738778166/060c9fri-removebg-preview_lqj6eb.png', // Replace with your error image URL
                  width: 200,
                  height: 200,
                ),
                Text(
                  'Please select a parking area first',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
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
                        dragOffset =
                            Offset(dragOffset.dx - 3000, dragOffset.dy);
                      } else if (dragOffset.dx < 0) {
                        dragOffset =
                            Offset(dragOffset.dx + 3000, dragOffset.dy);
                      }

                      // Implementing wraparound or infinite scroll vertically
                      if (dragOffset.dy > 3000) {
                        dragOffset =
                            Offset(dragOffset.dx, dragOffset.dy - 3000);
                      } else if (dragOffset.dy < 0) {
                        dragOffset =
                            Offset(dragOffset.dx, dragOffset.dy + 3000);
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
                          width: 800,
                          height: 1500,
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
            ?   const Color.fromARGB(255, 40, 237, 10)
            :  Colors.white;

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
  color: slot['type'] == 'bike' 
      ? Colors.blue // Blue for bike
      : slot['type'] == 'car' 
          ? Colors.orange // Orange for car
          : borderColor, // Default color
  width: 1.2,
),

              ),
              child: Stack(
                children: [
                  Center(
                    child: slot.containsKey('type') && slot['type'] != null
                        ? getIcon(slot['type'])
                        : Text(
                            slot.containsKey('id') &&
                                    slot['id'].contains(RegExp(r'\d+'))
                                ? RegExp(r'\d+')
                                    .firstMatch(slot['id'])!
                                    .group(0)! // Extract number
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

void showSlotDetailsBottomSheet(
    BuildContext context, Map<String, dynamic> slot) {
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
