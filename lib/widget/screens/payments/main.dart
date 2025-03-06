// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';


void main() {
  runApp(const PaymentApp());
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Method',
      theme: AppTheme.darkTheme,
      home: const PaymentMethodsScreen(),
    );
  }
}

// 1. Theme Class - Handles all styling for the app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Colors
  static const Color backgroundColor = Color(0xFF171617);
  static const Color cardColor = Color(0xFF171617);
  static const Color primaryColor = Color(0xFF5B78F6);
  static const Color textColor = Color(0xFFA3FD30);
  static const Color secondaryTextColor = Color(0xFFA3FD30);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textColor,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: secondaryTextColor,
  );

  // Theme Data
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: headingStyle,
      iconTheme: IconThemeData(color: textColor),
    ),
    textTheme: const TextTheme(
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      titleMedium: headingStyle,
      titleSmall: captionStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        textStyle: bodyStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: captionStyle,
      contentPadding: const EdgeInsets.all(16),
    ),
  );
}

// 2. PaymentMethodsScreen - Shows list of payment methods
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: const BackButton(),
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
              const SizedBox(height: 20), // Extra space at the bottom
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

// 3. PaymentMethodItem - Individual payment method list item
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
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(logo, width: 30, height: 30),
            ),
            const SizedBox(width: 16),
            Text(name, style: AppTheme.bodyStyle),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF2F50FD)),
          ],
        ),
      ),
    );
  }
}

// 4. AddPaymentButton - Button to add a new payment method
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
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Payment Method',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. AddCardScreen - Screen to add a new card
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
      appBar: AppBar(
        title: const Text('Add Payment Methods'),
        leading: const BackButton(),
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
                const Text('Enter your payment details', style: AppTheme.bodyStyle),
                const SizedBox(height: 8),
                const Text('By continuing you agree to our Terms', style: AppTheme.captionStyle),
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

// 6. CardForm - Form to enter card details
class CardForm extends StatefulWidget {  // Changed to StatefulWidget
  final VoidCallback onSubmit;
  final Function(String) onNameChanged;  // Added callback for name

  const CardForm({
    Key? key,
    required this.onSubmit,
    required this.onNameChanged,  // New required parameter
  }) : super(key: key);

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  // Add controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Add listener to the name controller
    _nameController.addListener(() {
      widget.onNameChanged(_nameController.text);
    });
  }
  
  @override
  void dispose() {
    // Clean up controller when widget is disposed
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,  // Use the controller
          decoration: const InputDecoration(
            hintText: 'Name ',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
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
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: (index + 1).toString().padLeft(2, '0'),
                    child: Text((index + 1).toString().padLeft(2, '0')),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Year',
                ),
                items: List.generate(
                  10,
                  (index) => DropdownMenuItem(
                    value: (DateTime.now().year + index).toString(),
                    child: Text((DateTime.now().year + index).toString()),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'CVV',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryColor,
            ),
            const Text('Set as default', style: AppTheme.bodyStyle),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onSubmit,
            child: const Text('Review Payment'),
          ),
        ),
      ],
    );
  }
}

// Extra class for card preview (shown in the AddCardScreen)
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

// NEW SCREEN: PaymentConfirmationScreen - Shows entered card details and confirms payment
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Review your payment details', style: AppTheme.bodyStyle),
                const Text('Please confirm all information is correct', style: AppTheme.captionStyle),
                const SizedBox(height: 24),
                
                // Card preview in confirmation screen
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
                          color: Color(0xFF2F50FD),
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
                
                // Payment amount section
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sub total', style: AppTheme.bodyStyle),
                          Text('\$120.00', style: AppTheme.bodyStyle),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax', style: AppTheme.bodyStyle),
                          Text('\$10.80', style: AppTheme.bodyStyle),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: AppTheme.primaryColor.withOpacity(0.2)),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount', 
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Text('\$130.80', 
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
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
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Text('Set as default payment method', style: AppTheme.bodyStyle),
                  ],
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppTheme.backgroundColor,
                            title: const Text('Confirm Payment', style: AppTheme.headingStyle),
                            content: const Text(
                              'Are you sure you want to process payment of \$120.80?',
                              style: AppTheme.bodyStyle,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7)),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog
                                  // Navigate to success screen with the correct name
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CardAddedScreen(
                                        cardholderName: cardholderName,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
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
                      style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.8)),
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

  // Helper method to build detail items
  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: AppTheme.captionStyle),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: AppTheme.captionStyle),
        ),
      ],
    );
  }
}


// 7. CardAddedScreen - Screen shown after a card is added
class CardAddedScreen extends StatelessWidget {
  final String cardholderName;  // Add this parameter
  
  const CardAddedScreen({
    Key? key, 
    this.cardholderName = 'John Henry',  // Default value in case it's not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter your payment details', style: AppTheme.bodyStyle),
                const Text('By continuing you agree to our Terms', style: AppTheme.captionStyle),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/PayPal.png',
                          width: 30,
                          height: 30,
                        ),
                        Image.asset(
                          'assets/images/Visa.png',
                          width: 30,
                          height: 30,
                        ),
                        Image.asset(
                          'assets/images/Mastercard.png',
                          width: 30,
                          height: 30,
                        ),
                        Image.asset(
                          'assets/images/DC.png',
                          width: 30,
                          height: 30,
                        ),
                        Image.asset(
                          'assets/images/Amex.png',
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Text('Cardholder name', style: AppTheme.captionStyle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(cardholderName, style: AppTheme.bodyStyle),  // Use the name passed to this screen
                ),
                
                const SizedBox(height: 16),
                const Text('Card Number', style: AppTheme.captionStyle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('**** **** **** 3947', style: AppTheme.bodyStyle),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exp Month', style: AppTheme.captionStyle),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('12', style: AppTheme.bodyStyle),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exp Year', style: AppTheme.captionStyle),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('2024', style: AppTheme.bodyStyle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Text('CVV', style: AppTheme.captionStyle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('123', style: AppTheme.bodyStyle),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: false,
                      onChanged: (value) {},
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Text('Set as default', style: AppTheme.bodyStyle),
                  ],
                ),
                
                const SizedBox(height: 30), // Add spacing
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Add now'),
                  ),
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