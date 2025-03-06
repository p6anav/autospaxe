
  import 'dart:convert';
import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/models/user.dart';
import 'package:autospaze/widget/providers/user_provider.dart';
import 'package:autospaze/widget/screens/Home/vehicle.dart';
import 'package:autospaze/widget/screens/login/test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_page.dart';
import 'package:http/http.dart' as http;
import 'package:autospaze/widget/services/api_service.dart'; // Import the ApiService

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

  final ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
 Future<void> _loginUser(BuildContext context) async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter both email and password.")),
          );
        }
        return;
      }

      final response = await apiService.login(email, password);

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final userId = jsonDecode(response.body);

        // Set user in UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUser(User(id: userId.toString(), email: email));

        print("Login Successful. User ID: $userId");

        // Navigate to VehicleForm after login
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VehicleForm()),
          );
        }
      } else {
        print("Login Failed: ${response.body}");
        String errorMessage = "Login Failed";
        if (response.statusCode == 401) {
          errorMessage = "Invalid email or password.";
        } else if (response.statusCode == 400) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['error'] ?? "Bad request. Please check your input.";
          } catch (e) {
            errorMessage = "Bad request. Please check your input.";
          }
        } else {
          errorMessage = "An error occurred. Please try again.";
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    }
  }


// Function to retrieve the stored user ID
Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id');
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
            '', // Replace with your network image URL
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
    _loginUser(context);
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