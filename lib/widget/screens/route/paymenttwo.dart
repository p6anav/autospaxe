import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/screens/bookings/DateTimePickerPage.dart';
import 'package:autospaze/widget/screens/bookings/booking_page_widgets.dart';
import 'package:autospaze/widget/screens/login/signup_page.dart';
import 'package:autospaze/widget/screens/maps/datatime.dart';
import 'package:autospaze/widget/screens/payments/animation.dart';
import 'package:autospaze/widget/screens/route/success.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:autospaze/widget/models/user.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:autospaze/widget/screens/invoice/invoice_page.dart';

void main() {
  runApp(const PaymentApptwo());
}

class PaymentApptwo extends StatelessWidget {
  const PaymentApptwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Method',
     
      home: const PaymentMethodsScreen(),
    );
  }
}

class VehicleOption {
  final int id; // Add an ID property
  final String brand;
  final String model;
  final String type;
  final bool isDefault;

  const VehicleOption({
    required this.id, // Include the ID in the constructor
    required this.brand,
    required this.model,
    required this.type,
    this.isDefault = false,
  });

  factory VehicleOption.fromJson(Map<String, dynamic> json) {
    return VehicleOption(
      id: json['id'] ?? 0, // Assume there's an 'id' field in the JSON
      brand: json['brand'] ?? '',
      model: json['vehicleNumber'] ?? '',
      type: json['color'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
class BookingData {
  final int userId;
  final String fromLocation;
  final String toLocation;
  final String parkingSlot;
  final String bookingTime;
  final String parkingName;
  final String parkingAddress;
  final double parkingRating;
  final String parkingImage;
  final List<VehicleOption> vehicleOptions;
  final int propertyId;
  final int propertySlotsId; // Ensure this is an int

  BookingData({
    required this.userId,
    required this.fromLocation,
    required this.toLocation,
    required this.parkingSlot,
    required this.bookingTime,
    required this.parkingName,
    required this.parkingAddress,
    required this.parkingRating,
    required this.parkingImage,
    required this.vehicleOptions,
    required this.propertyId,
    required this.propertySlotsId, // Include propertySlotsId in the constructor
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
  final user = json['user'] ?? {};
  final vehicles = json['vehicles'] ?? [];
  final parkingSlots = json['parkingSlots'] ?? [];

  // Filter parking slots that are marked as 'used'
  final usedParkingSlots = parkingSlots.where((slot) => slot['used'] == true).toList();

  if (usedParkingSlots.isEmpty) {
    throw Exception('No used parking slots found');
  }

  final firstUsedSlot = usedParkingSlots.first;

  // Extract property details from the first used parking slot
  final property = firstUsedSlot['property'] ?? {};
  final parkingName = property['name'] ?? 'Unknown';
  final parkingAddress = property['city'] ?? 'Unknown';
  final parkingRating = (property['ratePerHour'] as num?)?.toDouble() ?? 0.0;
  final parkingImage = property['imageUrl'] ?? '';
  final propertyId = property['propertyId'] ?? 0;
  final propertySlotsId = int.tryParse(firstUsedSlot['id'].toString()) ?? 0; // Parse id to int

  // Convert slotNumber to string if it is an integer
  final parkingSlot = firstUsedSlot['slotNumber'] is int
      ? firstUsedSlot['slotNumber'].toString()
      : firstUsedSlot['slotNumber'] ?? 'Unknown';

  // Filter vehicles that are marked as 'used'
  final usedVehicles = vehicles.where((vehicle) => vehicle['used'] == true).toList();

  if (usedVehicles.isEmpty) {
    throw Exception('No used vehicles found');
  }

  // Map the list of dynamic to a list of VehicleOption
  final vehicleOptions = usedVehicles.map((v) => VehicleOption.fromJson(v)).toList().cast<VehicleOption>();

  return BookingData(
    userId: user['id'] ?? 0,
    fromLocation: user['location'] ?? 'Chengannur',
    toLocation: property['name'] ?? 'Unknown',
    parkingSlot: parkingSlot,
    bookingTime: firstUsedSlot['exitTime'] ?? 'Unknown',
    parkingName: parkingName,
    parkingAddress: parkingAddress,
    parkingRating: parkingRating,
    parkingImage: parkingImage,
    vehicleOptions: vehicleOptions,
    propertyId: propertyId,
    propertySlotsId: propertySlotsId,
  );
}
}
Future<BookingData> fetchBookingData(BuildContext context) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final User? user = userProvider.user;

  if (user == null) {
    throw Exception('User data is not available');
  }

  final userId = user.id;
  final response = await http.get(Uri.parse('https://genuine-sindee-43-76539613.koyeb.app/api/users/details/$userId'));

  if (response.statusCode == 200) {
    return BookingData.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load booking data: ${response.statusCode}');
  }
}



/*Future<void> updateParkingSlotStatus(BuildContext context, {String status = 'BOOKED'}) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final User? user = userProvider.user;

  if (user == null) {
    throw Exception('User data is not available');
  }

  final userId = user.id;
  final statusUrl = Uri.parse('http://localhost:8080/api/parking-slots/status');

  try {
    // Make the PUT request with query parameters
    final response = await http.put(
      statusUrl.replace(queryParameters: {
        'userId': userId.toString(),
        'status': status,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Check the response status code
    if (response.statusCode == 204) {
      // Request was successful (no content)
      print('Parking slot status updated successfully');
    } else if (response.statusCode == 404) {
      // Resource not found
      throw Exception('User not found');
    } else {
      // Other error
      throw Exception('Failed to update parking slot status: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    throw Exception('Error updating parking slot status: $e');
  }
}*/
Map<String, dynamic> extractPaymentDetails(BookingData bookingData, UserProvider userProvider) {
  // Ensure that there are used vehicles available
  if (bookingData.vehicleOptions.isEmpty) {
    throw Exception('No used vehicles found');
  }

  // Retrieve fare from UserProvider and parse it to a double
  final fare = double.tryParse(userProvider.fare) ?? 0.0;

  var booking = {
    "userId": bookingData.userId,
    "vehicleId": bookingData.vehicleOptions.first.id, // Use the first used vehicle's ID
    "propertySlotsId": bookingData.propertySlotsId,
    "propertyId": bookingData.propertyId,
    "remainingTime": 2,
    "extraTime": 30,
    "extraTimeCharge": 0.00,
    "status": "Cancelled",
    "slotId": bookingData.parkingSlot,
  };

  var payment = {
    "userId": bookingData.userId,
    "amount": fare, // Use the fare from UserProvider
    "paymentMethod": "CREDIT_CARD",
  };

  return {
    "booking": booking,
    "payment": payment,
  };
}
/*Future<void> makePayment(Map<String, dynamic> paymentDetails) async {
  var response = await http.post(
    Uri.parse('http://localhost:8080/api/payment/process'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(paymentDetails),
  );

  if (response.statusCode == 200) {
    // Payment successful
    print('Payment successful');
  } else {
    // Payment failed
    print('Payment failed: ${response.body}');
    throw Exception('Failed to make payment');
  }
}*/
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  DateTimePickerPage()
              ),
            );
          },
        ),
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PaymentMethodItem(
                    logo: 'assets/images/Visa.png',
                    name: 'Visa',
                    onTap: () => _navigateToAddCard(context),
                  ),
                  PaymentMethodItem(
                    logo: 'assets/images/Mastercard.png',
                    name: 'MasterCard',
                    onTap: () => _navigateToAddCard(context),
                  ),
                  PaymentMethodItem(
                    logo: 'assets/images/Amex.png',
                    name: 'American Express',
                    onTap: () => _navigateToAddCard(context),
                  ),
                  PaymentMethodItem(
                    logo: 'assets/images/PayPal.png',
                    name: 'PayPal',
                    onTap: () => _navigateToAddCard(context),
                  ),
                  PaymentMethodItem(
                    logo: 'assets/images/DC.png',
                    name: 'Diners',
                    onTap: () => _navigateToAddCard(context),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AddPaymentButton(
                  onTap: () => _navigateToAddCard(context),
                ),
              ),
              const SizedBox(height: 6), // Extra space at the bottom
            ],
          ),
        ),
      ),
    );
  }


  void _navigateToAddCard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );
  }
}

class AddPaymentButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddPaymentButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF5B78F6)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF5B78F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color:Color(0xFF5B78F6),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Payment Method',
              style: TextStyle(
                color: Color(0xFF5B78F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AddCardScreen extends StatefulWidget {  // Changed to StatefulWidget
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String _cardholderName = '';  // To store the name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white,),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardPreview(),
                const SizedBox(height: 30),
                const Text('Enter your payment details'),
                const SizedBox(height: 8),
                const Text('By continuing you agree to our Terms'),
                const SizedBox(height: 16),
                CardForm(
                  onNameChanged: (value) {
                    setState(() {
                      _cardholderName = value;  // Update the name when it changes
                    });
                  },
                  onSubmit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentConfirmationScreen(
                          cardholderName: _cardholderName.isEmpty ? 'John Henry' : _cardholderName,  // Use the entered name or default
                          cardNumber: '**** **** **** 3947',
                          expiryMonth: '12',
                          expiryYear: '2024',
                          cvv: '123',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20), // Extra space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final Function(String) onNameChanged;

  const CardForm({
    Key? key,
    required this.onSubmit,
    required this.onNameChanged,
  }) : super(key: key);

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String? _selectedMonth;
  String? _selectedYear;
  bool _isDefault = true;
  
  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      widget.onNameChanged(_nameController.text);
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to avoid navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 16;
    
    return Stack(
      children: [
        // Main form content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Name ',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  hintText: 'Card Number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Month',
                      ),
                      value: _selectedMonth,
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: (index + 1).toString().padLeft(2, '0'),
                          child: Text((index + 1).toString().padLeft(2, '0')),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Year',
                      ),
                      value: _selectedYear,
                      items: List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: (DateTime.now().year + index).toString(),
                          child: Text((DateTime.now().year + index).toString()),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  hintText: 'CVV',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4, // Allow for Amex cards which have 4-digit CVV
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Switch(
                          value: _isDefault,
                          onChanged: (value) {
                            setState(() {
                              _isDefault = value;
                            });
                          },
                          activeColor: Color(0xFF5B78F6),
                        ),
                        const Text('Set as default'),
                      ],
                    ),
                  ),
                ],
              ),
              // Added an additional SizedBox to create more space after the switch
              const SizedBox(height: 80),
              // Add extra space at the bottom to avoid navigation bar overlap
              SizedBox(height: 60 + bottomPadding),
            ],
          ),
        ),

        // Button positioned at the bottom, adjusted to avoid navigation bar
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              child: const Text('Review Payment'),
            ),
          ),
        ),
      ],
    );
  }
}

class CardPreview extends StatelessWidget {
  const CardPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 19, 22, 74), Color(0xFF0A0C2B)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Icon(Icons.remove_red_eye, color: Color(0xFF2F50FD)),
            ],
          ),
          const Spacer(),
          const Text(
            '**** **** **** 3947',
            style: TextStyle(
              color: Color(0xFF2F50FD),
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder Name',
                    style: TextStyle(
                      color: Color(0xFFA3FD30),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pranav PJ',
                    style: TextStyle(
                      color: Color(0xFFA3FD30),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiry Date',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '05/23',
                    style: TextStyle(
                      color: Color(0xFFFDF9F9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFCFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.credit_card,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class PaymentMethodItem extends StatelessWidget {
  final String logo;
  final String name;
  final VoidCallback onTap;

  const PaymentMethodItem({
    Key? key,
    required this.logo,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF2A2A2A),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF171617),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(logo, width: 30, height: 30),
            ),
            const SizedBox(width: 16),
            Text(name),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF2F50FD)),
          ],
        ),
      ),
    );
  }
}

class PaymentConfirmationScreen extends StatelessWidget {
  final String cardholderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final bool isDefault;

  const PaymentConfirmationScreen({
    Key? key,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.isDefault = false,
  }) : super(key: key);

  Future<void> _makePayment(BuildContext context) async {
  try {
    // Fetch booking data
    var bookingData = await fetchBookingData(context);

    // Get the UserProvider instance
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Extract payment details with fare from UserProvider
    var paymentDetails = extractPaymentDetails(bookingData, userProvider);

    // Make payment
    //await makePayment(paymentDetails);

    // Navigate to InvoicePage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SuccessAnimationPagetwo()),
    );
  } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 215, 212, 215),
            title: const Text('Payment Failed'),
            content: Text(
              'There was an issue processing your payment. Please try again. Error: $e',
            
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(color:Color(0xFF5B78F6)) ,
                ),
              ),
            ],
          );
        },
      );
    }
  }
@override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Retrieve fare from UserProvider and format it
    final fare = double.tryParse(userProvider.fare) ?? 0.0;
    final formattedFare = fare.toStringAsFixed(2); // Format to 2 decimal places

    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Confirm Payment'),
         backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Review your payment details'),
                const Text('Please confirm all information is correct'),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1F71), Color(0xFF0A0C2B)],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Icon(Icons.credit_card, color: Color(0xFF2F50FD)),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        cardNumber,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 24, 48, 165),
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Card Holder Name',
                                style: TextStyle(
                                  color: Color(0xFFA3FD30),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cardholderName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Expiry Date',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$expiryMonth/$expiryYear',
                                style: const TextStyle(
                                  color: Color(0xFFFDF9F9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFCFC),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.credit_card,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailItem('Cardholder Name', cardholderName),
                _buildDetailItem('Card Number', cardNumber),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Exp Month', expiryMonth),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem('Exp Year', expiryYear),
                    ),
                  ],
                ),
                _buildDetailItem('CVV', cvv),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF171617),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF5B78F6)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax', ),
                          Text('\$0.0'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Color(0xFF5B78F6)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount', 
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5B78F6),
                            ),
                          ),
                          Text('\$$formattedFare', 
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5B78F6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Switch(
                      value: isDefault,
                      onChanged: (value) {},
                      activeColor: Color(0xFF5B78F6),
                    ),
                    const Text('Set as default payment method'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
  onPressed: () async {
    try {
      // First, make the payment
      await _makePayment(context);

      // After payment is successful, update the parking slot status to "BOOKED"
     // await updateParkingSlotStatus(context);

      // Optionally, you can navigate to another screen or show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment confirmed and slot status updated to BOOKED')),
      );
    } catch (e) {
      // Handle any errors that occur during the request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm payment: $e')),
      );
    }
  },
  child: const Text('Confirm Payment'),
),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Edit Payment Details',
                      style: TextStyle(color: Color(0xFF5B78F6)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:Color.fromARGB(255, 71, 69, 71),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, ),
        ),
      ],
    );
  }
}