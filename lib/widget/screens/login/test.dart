import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiTestPage extends StatefulWidget {
  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  List<dynamic> _parkingSlots = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> fetchParkingSlots() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final url = Uri.parse('http://localhost:8080/api/parking-slots/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _parkingSlots = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch parking slots. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching parking slots: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await fetchParkingSlots();
              },
              child: Text('Fetch Parking Slots'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _parkingSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _parkingSlots[index];
                    return ListTile(
                      title: Text('Slot ID: ${slot['id']}'),
                      subtitle: Text(
                        'Parking Spot ID: ${slot['parkingSpotId']}\n'
                        'X: ${slot['x']}, Y: ${slot['y']}, Width: ${slot['width']}, Height: ${slot['height']}\n'
                        'Availability: ${slot['availability']}, Reserved: ${slot['reserved']}\n'
                        'Range: ${slot['range']}, Slot Range: ${slot['slotRange']}\n'
                        'Remaining Time: ${slot['remainingTime']}, User ID: ${slot['userId']}\n'
                        'Type: ${slot['type']}, Hold: ${slot['hold']}\n'
                        'Property: ${slot['property']}\n'
                        '-----------------------------',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}