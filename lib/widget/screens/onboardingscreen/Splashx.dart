import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserDetailPage(),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userIdString = prefs.getString('user_id');

    if (userIdString == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user ID found in SharedPreferences.')),
      );
      return;
    }

    int userId = int.tryParse(userIdString) ?? 0;
    if (userId == 0) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid user ID found in SharedPreferences.')),
      );
      return;
    }

    try {
      final userDetails = await getUserDetails(userId);
      setState(() {
        _userDetails = userDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/users/details/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userDetails == null
              ? Center(child: Text('No user details available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(json.encode(_userDetails!['user'])),
                      SizedBox(height: 16),
                      Text('Vehicles:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(json.encode(_userDetails!['vehicles'])),
                      SizedBox(height: 16),
                      Text('Parking Slots:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(json.encode(_userDetails!['parkingSlots'])),
                    ],
                  ),
                ),
    );
  }
}