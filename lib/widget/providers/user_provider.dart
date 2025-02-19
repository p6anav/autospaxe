import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();

    // Save user data to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();

    // Clear user data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? userEmail = prefs.getString('user_email');

    if (userId != null && userEmail != null) {
      _user = User(id: userId, email: userEmail);
      notifyListeners();
    }
  }
}