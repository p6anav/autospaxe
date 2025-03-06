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
      'svgUrl': 'https://res.cloudinary.com/dwdatqojd/image/upload/v1740562916/minitest_cp35zs.svg',
      'licensePlate': 'KL67K 5648',
      'carName': 'Toyota Supra',
    },
    {
      'svgUrl': 'https://res.cloudinary.com/dwdatqojd/image/upload/v1740632293/supra_vwlkrf.svg',
      'licensePlate': 'KL67K 5649',
      'carName': 'Nissan GT-R',
    },
    // Add more car data as needed
  ];

  final CountDownController _controller = CountDownController();
  final StreamController<int> _timerStreamController = StreamController<int>();

  String? svgData;
  double horizontalOffset = 0.0;
  int currentPage = 0;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadSvgData();
  }

  Future<void> _loadSvgData() async {
    try {
      final response = await Dio().get(carData[currentPage]['svgUrl']!);
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
  }

  Future<String> _loadSvgDataForIndex(int index) async {
    try {
      final response = await Dio().get(carData[index]['svgUrl']!);
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
    alignment: Alignment.centerLeft, // Align the text to the left
    child: Padding(
      padding: const EdgeInsets.only(top: 26,left:32), // Add some padding to the left
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
      initialData: 0,
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
            duration: 10, // Countdown duration in seconds
            initialDuration: 0,
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
            textFormat: CountdownTextFormat.S,
            isReverse: true, // Countdown in reverse
            isTimerTextShown: true,
            autoStart: true,
            onComplete: () {
              debugPrint('Countdown Ended');
              _timerStreamController.add(0); // Add 0 to indicate completion
            },
            onChange: (remainingTime) {
              // Convert remainingTime to an integer and add it to the stream
              int remainingSeconds = int.tryParse(remainingTime) ?? 0;
              _timerStreamController.add(remainingSeconds);
            },
          ),
          SizedBox(height: 20), // Space between timer and text timer
          Container(
            width: 140, // Width of the circular background
            height: 140, // Height of the circular background
            decoration: BoxDecoration(
              color: Colors.white, // White background color
              shape: BoxShape.circle, // Circular shape
            ),
            child: Icon(
              Icons.lock_outline, // Lock icon
              size: 50, // Size of the icon
              color: const Color.fromARGB(255, 93, 200, 40), // Color of the icon
            ),
          ),
        ],
      ),
    );
  }
}