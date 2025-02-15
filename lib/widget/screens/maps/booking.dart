import 'package:flutter/material.dart';
import 'dart:math';
import 'package:autospaze/widget/screens/maps/payment.dart';

class NextPage extends StatelessWidget {

  final String searchQuery;
  final String parkingId;

  const NextPage({
    Key? key,
    required this.searchQuery,
    required this.parkingId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Generate dummy QR code data
    List<List<bool>> qrCodeData = _generateDummyQRCodeData();

    return Scaffold(
      appBar: AppBar(
       
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0), // Padding at the top
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Space at the top
            // QR Code with Border
            Container(
              padding: EdgeInsets.all(8), // Padding between border and QR code
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(210, 0, 0, 0), // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(8), // Rounded corners
                color: Colors.white, // Background color
              ),
              child: _buildQRCode(qrCodeData), // Render the QR code
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                '', // Text is empty, but you can add a message here if you like
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20), // Adds space before the button
            Expanded( // This makes the button stick to the bottom
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0), // Padding to prevent the button from touching the bottom
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to the previous page
                      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentSuccessScreen()),
    );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 78, 255, 33), // Button background color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 120), // Button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                      ),
                      elevation: 5, // Shadow under the button
                    ),
                    child: Text('Continue', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to generate dummy QR code data
  static List<List<bool>> _generateDummyQRCodeData() {
    final random = Random();
    final size = 25; // Size of the QR code grid (25x25 for example)
    return List.generate(size, (_) {
      return List.generate(size, (_) => random.nextBool());
    });
  }

  // Widget to render the QR code grid
  Widget _buildQRCode(List<List<bool>> qrCodeData) {
    final double cellSize = 10.0; // Size of each square in the grid
    return Container(
      color: Colors.white,
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
