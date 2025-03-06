import 'package:flutter/material.dart';
import 'invoice_page.dart'; // This imports the InvoicePage widget from the file you shared

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkEasy'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_parking_rounded,
                size: 80,
                color: Colors.deepPurple.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'ParkEasy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find and book parking spaces with ease',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const InvoicePage(
                        // You can customize these values if needed
                        fromLocation: "Current Location",
                        toLocation: "City Center Mall",
                        parkingSlot: "A1",
                        bookingTime: "10:30 AM - 12:30 PM",
                        vehicleBrand: "Mercedes-Benz",
                        vehicleModel: "CL63 AMG",
                        vehicleType: "Long coupe",
                        parkingName: "Downtown Secure Parking",
                        parkingAddress: "123 Main Street, City Center",
                        parkingRating: 4.7,
                        invoiceNumber: "INV-20250302-7842",
                        bookingDate: "March 2, 2025",
                        amount: 45.50,
                        paymentMethod: "Credit Card",
                        transactionId: "TXN-78943213",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Invoice',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}