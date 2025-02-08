import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:autospaze/widget/main_screen.dart';
import 'package:autospaze/widget/screens/Home/vehicle.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late FocusNode _emailFocusNode;
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slower animation
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    _emailFocusNode = FocusNode();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage ()),
    );
  }
  

  void _validateSignUp() {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _usernameError = _usernameController.text.isEmpty ? 'Please enter a username' : null;
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _confirmPasswordController.text != _passwordController.text
          ? 'Passwords do not match'
          : null;
    });

    if (_emailError == null &&
        _usernameError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      // All validations passed, proceed with signup
      print('Email: ${_emailController.text}');
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');
      print('Confirm Password: ${_confirmPasswordController.text}');
    }
  }

  String? _validateEmail(String email) {
    // Check if the email is in a valid format (simple check for now)
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty) {
      return 'Please enter your email';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String password) {
    // Validate password: At least one uppercase, one number, one special char, and at least 8 characters
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (password.isEmpty) {
      return 'Please enter a password';
    } else if (!passwordRegex.hasMatch(password)) {
      return 'Password must be at least 8 characters long, with at least one uppercase letter, one number, and one special character';
    }
    return null;
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
                      'Getting Started',
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
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      label: 'Username',
                      icon: Icons.person,
                      errorText: _usernameError,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      errorText: _confirmPasswordError,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Remind me next time',
                          style: TextStyle(color: Colors.white),
                        ),
                        Switch(value: true, onChanged: (value) {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _validateSignUp,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 150, vertical: 27),
                      ),
                      child: const Text('Sign up'),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _navigateToLoginPage,
                      child: const Text(
                        'You already have an account? Login',
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
                obscureText: isPassword,
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
}
