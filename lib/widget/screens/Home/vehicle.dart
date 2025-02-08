import 'package:flutter/material.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/screens/Home/home_screen.dart'; // Import the MainScreen widget

class AddVehicleApp extends StatelessWidget {
  const AddVehicleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddVehiclePage(),
    );
  }
}

class AddVehiclePage extends StatefulWidget {
  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  String? selectedVehicleType;
  String? selectedVehicleBrand;

  final Map<String, List<String>> vehicleBrands = {
    'Car': [
      'BMW',
      'Mercedes-Benz',
      'Audi',
      'Toyota',
      'Honda',
      'Ford',
      'Chevrolet',
      'Nissan',
      'Hyundai',
      'Volkswagen',
    ],
    'Bike': [
      'Harley-Davidson',
      'Kawasaki',
      'Yamaha',
      'Ducati',
      'Royal Enfield',
      'Suzuki',
      'KTM',
      'BMW Motorrad',
      'Honda',
      'Triumph',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
             
            ),
            const Text(
              'Add a vehicle',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
               child: Image.network(
            'https://res.cloudinary.com/dwdatqojd/image/upload/v1738773303/Acar_cznfm1.png', // Replace with your network image URL
            width: 80, // Adjust size of logo
            height: 80,
            fit: BoxFit.contain, // Adjust the fit property as needed
          ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'vehicle details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'add your vehicle details below',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 102, 101, 101),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildDropdownField(
              hint: 'your vehicle Type',
              value: selectedVehicleType,
              items: ['Car', 'Bike'],
              onChanged: (value) {
                setState(() {
                  selectedVehicleType = value;
                  selectedVehicleBrand = null; // Reset brand selection
                });
              },
            ),
            const SizedBox(height: 15), // Increased gap
            _buildInputField(Icons.tag, 'vehicle no.plate'),
            const SizedBox(height: 15), // Increased gap
            _buildDropdownField(
              hint: 'vehicle brand',
              value: selectedVehicleBrand,
              items:
                  selectedVehicleType != null
                      ? vehicleBrands[selectedVehicleType!] ?? []
                      : [],
              onChanged: (value) {
                setState(() {
                  selectedVehicleBrand = value;
                });
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      ); // Navigate to the next page (MainScreen or any other screen)
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[700]),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            isExpanded: true,
            items:
                items.map((item) {
                  return DropdownMenuItem<String>(value: item, child: Text(item));
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
