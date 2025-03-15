import 'package:autospaze/widget/screens/Admin/animation_page.dart';
import 'package:autospaze/widget/screens/Admin/invalid_animation_page.dart';
import 'package:autospaze/widget/screens/Admin/invalido.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _result;
  final MobileScannerController controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    // Navigate to the QrCodeScanner immediately
    Future.microtask(() => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrCodeScanner(
          setResult: (result) {
            setState(() => _result = result);
            _makeApiCall(result);
          },
        ),
      ),
    ));
  }

  void _makeApiCall(String qrData) async {
  final url = Uri.parse('https://genuine-sindee-43-76539613.koyeb.app/api/qr-codes/verify?qrCodeData=$qrData');

  try {
    final response = await http.post(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final responseData = json.decode(response.body);
      final status = responseData['status'];

      if (status == 'USED') {
        // Handle successful entry
        print('QR Code verified successfully for entry: $qrData');
        setState(() => _result = 'QR Code verified successfully for entry');
        // Navigate to the success animation page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SuccessAnimationPage(),
          ),
        );
      } else if (status == 'CANCELLED') {
        // Handle successful exit
        print('QR Code verified successfully for exit: $qrData');
        setState(() => _result = 'QR Code verified successfully for exit');
        // Navigate to the invalid animation page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InvalidAnimationPage(),
          ),
        );
      } else if (status == 'unknow') {
        // Handle unknown status
        print('Unknown status from QR Code verification: $response.body');
        setState(() => _result = 'Unknown status from QR Code verification');
        // Navigate to the invalid animation page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InvalidAnimationPageorg(),
          ),
        );
      } else {
        // Handle unexpected response
        print('Unexpected response from QR Code verification: $response.body');
        setState(() => _result = 'Unexpected response from QR Code verification');
        // Navigate to the invalid animation page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InvalidAnimationPageorg(),
          ),
        );
      }
    } else {
      // Handle error response
      print('Failed to verify QR Code: ${response.body}');
      setState(() => _result = 'Invalid QR code');
      // Navigate to the invalid animation page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const InvalidAnimationPageorg(),
        ),
      );
    }
  } catch (e) {
    // Handle any errors during the request
    print('Error during QR Code verification: $e');
    setState(() => _result = 'Error during QR Code verification: $e');
    // Navigate to the invalid animation page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvalidAnimationPageorg(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result ?? 'Scanning QR Code...'),
          ],
        ),
      ),
    );
  }
}

class QrCodeScanner extends StatelessWidget {
  QrCodeScanner({
    required this.setResult,
    super.key,
  });

  final Function(String) setResult;
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              final barcode = barcodes.first;

              if (barcode.rawValue != null) {
                setResult(barcode.rawValue!);

                await controller
                    .stop()
                    .then((value) => controller.dispose())
                    .then((value) => Navigator.of(context).pop());
              }
            },
          ),
          // Custom overlay for the scanner
          Positioned(
            top: 100,
            left: 50,
            right: 50,
            bottom: 100,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

