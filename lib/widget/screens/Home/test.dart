import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParkingBookingScreen(),
    );
  }
}

class ParkingBookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Car image wrapped in a container
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/carss.png',
                  fit: BoxFit.cover,
                ), // Add your car image path
              ),
            ),

            const SizedBox(height: 20),

            // Text box
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'One-step \n solution to book \n a parking Space',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Easily view nearby parking spots\n and booking at your preferred\n parking spot',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Swipe button animation
            SwipeButton(),
          ],
        ),
      ),
    );
  }
}

class SwipeButton extends StatefulWidget {
  @override
  _SwipeButtonState createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _position = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.directions_car, color: Colors.white),
              ),
              Row(
                children: const [
                  Icon(Icons.arrow_forward_ios, color: Colors.white),
                  Icon(Icons.arrow_forward_ios, color: Colors.white),
                  Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: _position,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _position = (_position + details.delta.dx).clamp(0.0, 250.0);
              });
            },
            onHorizontalDragEnd: (details) {
              if (_position > 200) {
                setState(() {
                  _position = 250.0;
                });
                Future.delayed(const Duration(milliseconds: 300), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Action Completed!')),
                  );
                });
              } else {
                setState(() {
                  _position = 0.0;
                });
              }
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.directions_car, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}