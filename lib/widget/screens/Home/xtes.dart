import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

class SvgDisplayPage extends StatefulWidget {
  @override
  _SvgDisplayPageState createState() => _SvgDisplayPageState();
}

class _SvgDisplayPageState extends State<SvgDisplayPage> {
  List<Map<String, String>> carData = [
    {
      'id': '1',
      'svgUrl':
          'https://res.cloudinary.com/dwdatqojd/image/upload/v1740562916/minitest_cp35zs.svg',
      'licensePlate': 'KL67K 5648',
      'carName': 'Toyota Supra',
      'status': 'ENTRY',
      'startTime': '2025-03-12T23:45:00Z', // 11:45 PM on March 12, 2025
      'exitTime': '2025-03-13T00:02:00Z', // 2 minutes after start time
    },
    {
      'id': '2',
      'svgUrl':
          'https://res.cloudinary.com/dwdatqojd/image/upload/v1740632293/supra_vwlkrf.svg',
      'licensePlate': 'KL67K 5649',
      'carName': 'Nissan GT-R',
      'status': 'ENTRY',
      'startTime': '2025-03-12T23:45:00Z', // 11:45 PM on March 12, 2025
      'exitTime': '2025-03-13T00:02:00Z',
    },
  ];

  final CountDownController _controller = CountDownController();
  final StreamController<int> _timerStreamController = StreamController<int>();
  Timer? _timer;
  int _remainingTimeInSeconds = 120;
  String? svgData;
  double horizontalOffset = 0.0;
  int currentPage = 0;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadSvgData();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        _timer?.cancel();
        _controller.pause(); // Ensure the circular timer stops
        debugPrint('Countdown Ended');
        _resetCountdown(); // Reset the countdown
      }
    });
  }

  void _resetCountdown() {
    setState(() {
      _remainingTimeInSeconds = 120; // Reset to initial value
    });
    _controller.reset(); // Reset the circular timer
    _controller.start(); // Start the circular timer again
    _startCountdown(); // Restart the countdown logic
  }
  Future<void> _loadSvgData() async {
    try {
      String svgUrl = carData[currentPage]['svgUrl']!;
      final response = await Dio().get(svgUrl);
      setState(() {
        svgData = response.data;
      });
    } catch (e) {
      print('Error loading SVG data: $e');
    }
  }

  void _changePage(int index) {
    setState(() {
      currentPage = index;
      horizontalOffset = 0;
    });
    _loadSvgData();
    _startCountdown();
  }

  Future<String> _loadSvgDataForIndex(int index) async {
    try {
      String svgUrl = carData[index]['svgUrl']!;
      final response = await Dio().get(svgUrl);
      return response.data;
    } catch (e) {
      print('Error loading SVG data for index $index: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      ),
      body: Container(
        color: const Color.fromARGB(255, 39, 38, 38),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCarName(),
                _buildSvgPageView(),
                _buildButtonSection(),
                _buildTimerSection(),
                _buildCircularCountDownTimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarName() {
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
    return Expanded(
      child: PageView.builder(
        itemCount: carData.length,
        onPageChanged: _changePage,
        itemBuilder: (context, index) {
          return FutureBuilder<String>(
            future: _loadSvgDataForIndex(index),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading SVG data'));
              } else {
                return GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      horizontalOffset += details.delta.dx;
                    });
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
                            child: SvgPicture.string(
                              snapshot.data!,
                              width: 400,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 120, left: 25),
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
                                      color: isAvailable
                                          ? Colors.green
                                          : Colors.red,
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
              }
            },
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
              // Button action
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

  Widget _buildTimerSection() {
    return StreamBuilder<int>(
      stream: _timerStreamController.stream,
      initialData: _remainingTimeInSeconds,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int totalSeconds = snapshot.data!;
          int hours = totalSeconds ~/ 3600;
          int minutes = (totalSeconds % 3600) ~/ 60;
          int seconds = totalSeconds % 60;

          return Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        } else {
          return Text(
            'Time Remaining: 00:00:00',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  Widget _buildCircularCountDownTimer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularCountDownTimer(
            duration:
                _remainingTimeInSeconds, // Use the same countdown duration
            initialDuration:
                _remainingTimeInSeconds, // Set initialDuration to the same value
            controller: _controller,
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 4,
            ringColor: Colors.grey[300]!,
            fillColor: Colors.green, // Progress bar color
            backgroundColor: Colors.transparent,
            strokeWidth: 20.0,
            strokeCap: StrokeCap.round,
            textStyle: TextStyle(
              fontSize: 33.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            isReverse: true, // Countdown in reverse
            isTimerTextShown: false, // Hide the timer text if not needed
            autoStart: true, // Automatically start the countdown
            onComplete: () {
              debugPrint('Countdown Ended');
            },
          ),
        ],
      ),
    );
  }
}
