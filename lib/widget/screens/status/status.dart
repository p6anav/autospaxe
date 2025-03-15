import 'dart:async';
import 'package:autospaze/widget/models/user.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:autospaze/widget/screens/invoice/invoice_page.dart';
import 'package:autospaze/widget/screens/route/dateandtimetwo.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CountdownPage extends StatefulWidget {
  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int _remainingTimeInSeconds = 0; // Initialize to 0
  final CountDownController _controller = CountDownController();
  Timer? _timer;
  List<String?> svgDataList = [];
  double horizontalOffset = 0.0;
  int currentPage = 0;
  bool isAvailable = true;
  List<Map<String, String>> carData = [];
  bool isLoading = true;
  String? errorMessage;
  BookingData? bookingData;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  Future<void> _fetchBookingData() async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User? user = userProvider.user;

    if (user == null) {
      throw Exception('User data is not available');
    }

    final userId = user.id;
    final fetchedBookingData = await fetchBookingData(context);

    // Filter QR codes to only include those with status 'USED'
    final usedQrCodes = fetchedBookingData.qrCodes.where((qrCode) => qrCode.status == 'USED').toList();

    if (usedQrCodes.isEmpty) {
      throw Exception('No used QR codes found');
    }

    setState(() {
      bookingData = fetchedBookingData;
      carData = fetchedBookingData.vehicleOptions.map((vehicle) {
        // Hardcoded default image URL
        String imageUrl = 'https://res.cloudinary.com/dwdatqojd/image/upload/v1741951059/minicar_p5kkpn.png'; // Dummy PNG image URL
        return {
          'carName': vehicle.model,
          'licensePlate': vehicle.brand,
          'svgUrl': imageUrl,
          'exitTime': fetchedBookingData.bookingTime,
        };
      }).toList();
      isLoading = false;
    });

    if (carData.isNotEmpty) {
      svgDataList = List<String?>.filled(carData.length, null); // Initialize svgDataList
      _calculateRemainingTime();
      _startCountdown();
    }
  } catch (e) {
    print('Error fetching booking data: $e');
    setState(() {
      isLoading = false;
      errorMessage = 'Failed to load data. Please try again later.';
    });
  }
}
  void _calculateRemainingTime() {
    if (carData.isEmpty) {
      print('carData is empty, cannot calculate remaining time');
      return;
    }

    String exitTimeStr = carData[currentPage]['exitTime']!;
    DateTime exitTime = DateTime.parse(exitTimeStr);
    DateTime currentTime = DateTime.now().toUtc();

    int remainingTimeInSeconds = exitTime.difference(currentTime).inSeconds;
    if (remainingTimeInSeconds < 0) {
      remainingTimeInSeconds = 0; // Ensure remaining time is not negative
    }

    if (mounted) {
      setState(() {
        _remainingTimeInSeconds = remainingTimeInSeconds;
        if (_remainingTimeInSeconds > 0) {
          _controller.reset();
          _controller.start();
        } else {
          _controller.pause(); // Ensure the circular timer stops
        }
      });
    }
  }

  void _changePage(int index) {
    if (mounted) {
      setState(() {
        currentPage = index;
        horizontalOffset = 0;
      });
      _calculateRemainingTime(); // Recalculate remaining time when page changes
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Check if the widget is still mounted

      if (_remainingTimeInSeconds > 0) {
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        _timer?.cancel();
        _controller.pause(); // Ensure the circular timer stops
        debugPrint('Countdown Ended');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCarName(),
            SizedBox(height: 20),
            _buildSvgPageView(),
            SizedBox(height: 20),
            _buildButtonSection(),
            _buildTextTimer(),
            SizedBox(height: 20),
            _buildCircularCountDownTimer(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCarName() {
    if (carData.isEmpty) {
      return Text(
        'No car data available',
        style: TextStyle(
          color: const Color.fromARGB(255, 93, 200, 40),
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 26, left: 32),
        child: Text(
          carData[currentPage]['carName']!,
          style: TextStyle(
            color: const Color.fromARGB(255, 93, 200, 40),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSvgPageView() {
    if (carData.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Expanded(
      child: PageView.builder(
        itemCount: carData.length,
        onPageChanged: _changePage,
        itemBuilder: (context, index) {
          return GestureDetector(
            onPanUpdate: (details) {
              if (mounted) {
                setState(() {
                  horizontalOffset += details.delta.dx;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(horizontalOffset, 0),
              child: Container(
                width: 400,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 38, 38),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        carData[index]['svgUrl']!,
                        width: 400,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 120, left: 25),
                      child: Container(
                        width: 130,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_parking,
                                color: isAvailable ? Colors.green : Colors.red,
                                size: 24,
                              ),
                              SizedBox(width: 5),
                              Text(
                                carData[currentPage]['licensePlate']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
               Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>DateTimePickerPagetwo()),
    );// Button action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 13, 54, 189),
              foregroundColor: Colors.white,
              minimumSize: const Size(360, 75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(
                  color: Colors.white,
                  width: 0.4,
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              'Add on',
              style: GoogleFonts.openSans(
                fontSize: 22,
                color: const Color.fromARGB(255, 242, 244, 245),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Remaining Time',
            style: GoogleFonts.openSans(
              fontSize: 15,
              color: const Color.fromARGB(255, 93, 200, 40),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTimer() {
    if (_remainingTimeInSeconds <= 0) {
      return Text(
        'Time has passed',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    }

    int hours = _remainingTimeInSeconds ~/ 3600;
    int minutes = (_remainingTimeInSeconds % 3600) ~/ 60;
    int seconds = _remainingTimeInSeconds % 60;

    return Text(
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildCircularCountDownTimer() {
    if (_remainingTimeInSeconds <= 0) {
      return Text(
        'Time has passed',
        style: TextStyle(
          fontSize: 33.0,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular background
        Container(
          width: 140, // Width of the circular background
          height: 140, // Height of the circular background
          decoration: BoxDecoration(
            color: Colors.white, // White background color
            shape: BoxShape.circle, // Circular shape
          ),
        ),
        // Circular countdown timer
        CircularCountDownTimer(
          duration: _remainingTimeInSeconds,
          initialDuration: 0,
          controller: _controller,
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 4,
          ringColor: Colors.grey[300]!,
          fillColor: Colors.green,
          backgroundColor: Colors.transparent,
          strokeWidth: 20.0,
          strokeCap: StrokeCap.round,
          textStyle: TextStyle(
            fontSize: 33.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          isReverse: true,
          isTimerTextShown: false,
          autoStart: true,
          onComplete: () {
            debugPrint('Circular Countdown Ended');
          },
        ),
        // Lock icon
        Icon(
          Icons.lock_outline, // Lock icon
          size: 50, // Size of the icon
          color: const Color.fromARGB(255, 93, 200, 40), // Color of the icon
        ),
      ],
    );
  }
}