import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autospaze/widget/providers/ParkingProvider.dart';

class BookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the ParkingProvider
    final parkingProvider = Provider.of<ParkingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align content from the top
        children: [

           Text(
              'Booking Screen', // Your heading text
              style: GoogleFonts.openSans(
                fontSize: 24, // Larger font size for the heading
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center, // Center the text horizontally within its container
            ),
          // Display the image and parking name at the top center with padding and rounded corners
          if (parkingProvider.parkingImageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0), 
              // Add padding around the image
              child: Column(
                children: [
                   SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0), // Apply rounded corners
                    child: Image.network(
                      parkingProvider.parkingImageUrl,
                      height: 250, // Adjust the height as needed
                      width: double.infinity, // Make the image take full width
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 12), // Add some space below the image
                  Container(
                    alignment: Alignment.centerLeft, // Center the text widget
                    child: Text(
                      parkingProvider.parkingName,
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 125, 123, 123),
                      ),
                      textAlign: TextAlign.left, // Align text to the left
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20), // Add some space below the image and text

          // Display the parking details
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Parking ID: ${parkingProvider.parkingId}'),
                  Text('Parking Description: ${parkingProvider.parkingDescription}'),
                  Text('Parking Latitude: ${parkingProvider.parkingLatitude}'),
                  Text('Parking Longitude: ${parkingProvider.parkingLongitude}'),
                  Text('Parking Rate per Hour: ${parkingProvider.ratePerHour}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}