import 'package:flutter/material.dart';
import 'dart:math';

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Generate dummy QR code data
    List<List<bool>> qrCodeData = _generateDummyQRCodeData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Welcome to the next page!',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          _buildQRCode(qrCodeData), // Render the QR code
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate back to the previous page
              Navigator.pop(context);
            },
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // Function to generate dummy QR code data
  static List<List<bool>> _generateDummyQRCodeData() {
    final random = Random();
    final size = 21; // Size of the QR code grid (21x21 for example)
    return List.generate(size, (_) {
      return List.generate(size, (_) => random.nextBool());
    });
  }

  // Widget to render the QR code grid
  Widget _buildQRCode(List<List<bool>> qrCodeData) {
    final double cellSize = 10.0; // Size of each square in the grid
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: qrCodeData.map((row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((cell) {
              return Container(
                width: cellSize,
                height: cellSize,
                color: cell ? Colors.black : Colors.white,
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
