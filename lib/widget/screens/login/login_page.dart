import 'package:autospaze/widget/screens/Home/vehicle.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;

  final Map<String, String> _dummyDatabase = {
    'test@example.com': 'password123',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slower animation
    );
    _animation = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _navigateToSignUpPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  void _validateLogin() {
  setState(() {
    _emailError = _emailController.text.isEmpty ? 'Please enter your email' : null;
    _passwordError = _passwordController.text.isEmpty ? 'Please enter your password' : null;
  });

  if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
    // Print the entered data to the debug console
    print('Entered Email: ${_emailController.text}');
    print('Entered Password: ${_passwordController.text}');
    
    // Check if the entered email and password match the dummy database
    String? storedPassword = _dummyDatabase[_emailController.text];

    if (storedPassword != null && storedPassword == _passwordController.text) {
      // Login successful
      print('Login successful');

      // Navigate to HomeScreen (Replace with your actual screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>AddVehicleApp()), // Change to your screen
      );
    } else {
      _showErrorDialog('Incorrect username or password');
    }
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SlideTransition(
            position: _animation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Image.network(
            'https://res.cloudinary.com/dwdatqojd/image/upload/v1738778483/knnx_ioyjrq.png', // Replace with your network image URL
            width: 80, // Adjust size of logo
            height: 80,
            fit: BoxFit.contain, // Adjust the fit property as needed
          ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Email',
                      icon: Icons.email,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      errorText: _passwordError,
                      isPasswordVisible: _isPasswordVisible,
                      togglePasswordVisibility: _togglePasswordVisibility,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Remind me later',
                          style: TextStyle(color: Colors.white),
                        ),
                        Switch(value: true, onChanged: (value) {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                   ElevatedButton(
  onPressed: () {
    _validateLogin();
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 27),
  ),
  child: const Text('Login'),
),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _navigateToSignUpPage,
                      child: const Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? errorText,
    bool isPasswordVisible = false,
    VoidCallback? togglePasswordVisibility,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Focus(
          onFocusChange: (hasFocus) {
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                obscureText: isPassword && !isPasswordVisible,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.black.withOpacity(0.8)),
                  prefixIcon: AnimatedScale(
                    scale: focusNode.hasFocus || controller.text.isNotEmpty ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icon,
                      color: focusNode.hasFocus || controller.text.isNotEmpty
                          ? Colors.blue
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          onPressed: togglePasswordVisibility,
                        )
                      : null,
                ),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
}
