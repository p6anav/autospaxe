import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

class SvgDisplayPage extends StatefulWidget {
  @override
  _SvgDisplayPageState createState() => _SvgDisplayPageState();
}

class _SvgDisplayPageState extends State<SvgDisplayPage> {
  List<String> svgUrls = [
    'https://res.cloudinary.com/dwdatqojd/image/upload/v1740562916/minitest_cp35zs.svg',
    'https://res.cloudinary.com/dwdatqojd/image/upload/v1740562916/minitest_cp35zs.svg',
    // Add more SVG URLs as needed
  ];
  String? svgData;
  double rotationAngle = 0.0; // State variable to track rotation angle
  double horizontalOffset = 0.0; // State variable to track horizontal position
  int currentPage = 0; // Track the current page index

  // Mock database to store color information
  Map<String, String> colorDatabase = {
    'Red': 'FF0000',
    'Green': '00FF00',
    'Blue': '0000FF',
  };

  @override
  void initState() {
    super.initState();
    _loadSvgData();
  }

  Future<void> _loadSvgData() async {
    try {
      final response = await Dio().get(svgUrls[currentPage]);
      setState(() {
        svgData = response.data;
      });
    } catch (e) {
      print('Error loading SVG data: $e');
    }
  }

  void _changeColor(String colorName) {
    if (svgData != null) {
      final hexColor = colorDatabase[colorName];
      if (hexColor != null) {
        final modifiedSvgData = svgData!.replaceAll(
          RegExp(r'fill="#2F50FD"'),
          'fill="#$hexColor"',
        );
        setState(() {
          svgData = modifiedSvgData;
        });
      }
    }
  }

  void _moveLeft() {
    setState(() {
      horizontalOffset -= 4; // Move left by 4 units
    });
  }

  void _moveRight() {
    setState(() {
      horizontalOffset += 4; // Move right by 4 units
    });
  }

  void _changePage(int index) {
    setState(() {
      currentPage = index;
      horizontalOffset = 0; // Reset horizontal offset when changing page
    });
    _loadSvgData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 226, 224, 224), // Set the AppBar background color
      ),
      body: Container(
        color: const Color.fromARGB(255, 226, 224, 224), // Set the background color
        child: SafeArea(
          child: Column(
            mainAxisAlignment:MainAxisAlignment.start,
            children: [
              // Use PageView.buiader to swipe between SVG images
              Expanded(
                child: PageView.builder(
                  itemCount: svgUrls.length,
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
                              // Update horizontal offset based on drag distance
                              setState(() {
                                horizontalOffset += details.delta.dx;
                              });
                            },
                            child: Transform.translate(
                              offset: Offset(horizontalOffset, 0),
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 226, 224, 224), // Background color of the container
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16), // Bottom-left corner radius
                                    bottomRight: Radius.circular(16), // Bottom-right corner radius
                                  ),
                                ),
                                child: SvgPicture.string(
                                  snapshot.data!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
              // Add movement buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.rotate_left),
                    onPressed: _moveLeft,
                  ),
                  IconButton(
                    icon: Icon(Icons.rotate_right),
                    onPressed: _moveRight,
                  ),
                ],
              ),
              SizedBox(height: 40),
              // Add a Container at the bottom with only bottom edges curved
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color:  const Color.fromARGB(255, 226, 224, 224), // Set the background color of the bottom container
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16), // Bottom-left corner radius
                    bottomRight: Radius.circular(16), // Bottom-right corner radius
                  ),
                ),
                
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _loadSvgDataForIndex(int index) async {
    try {
      final response = await Dio().get(svgUrls[index]);
      return response.data;
    } catch (e) {
      print('Error loading SVG data for index $index: $e');
      throw e;
    }
  }
}