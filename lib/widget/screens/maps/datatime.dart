import 'package:flutter/material.dart';
import 'package:autospaze/widget/screens/maps/maps.dart'; // Import your map screen
import 'package:autospaze/widget/screens/Home/home_screen.dart';
import 'package:autospaze/widget/main_screen.dart';

class DateTimeRangePickerScreen extends StatefulWidget {
  @override
  _DateTimeRangePickerScreenState createState() =>
      _DateTimeRangePickerScreenState();
}

class _DateTimeRangePickerScreenState extends State<DateTimeRangePickerScreen> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  // Function to pick the start DateTime
  Future<void> _selectStartDateTime(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedStartDate != null) {
      final TimeOfDay? pickedStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedStartTime != null) {
        setState(() {
          startDateTime = DateTime(
            pickedStartDate.year,
            pickedStartDate.month,
            pickedStartDate.day,
            pickedStartTime.hour,
            pickedStartTime.minute,
          );
        });
      }
    }
  }

  // Function to pick the end DateTime
  Future<void> _selectEndDateTime(BuildContext context) async {
    final DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedEndDate != null) {
      final TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedEndTime != null) {
        setState(() {
          endDateTime = DateTime(
            pickedEndDate.year,
            pickedEndDate.month,
            pickedEndDate.day,
            pickedEndTime.hour,
            pickedEndTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Date and Time"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the home page
             Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(), // Replace with your next page
        ),
      );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Start DateTime: ${startDateTime ?? 'Not selected'}"),
              onTap: () => _selectStartDateTime(context),
            ),
            ListTile(
              title: Text("End DateTime: ${endDateTime ?? 'Not selected'}"),
              onTap: () => _selectEndDateTime(context),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDateTime != null && endDateTime != null) {
                  // Navigate to the map screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SvgUpdater(), // This will be your map screen
                    ),
                  );
                } else {
                  // Show an alert if date/time is not selected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content:
                            Text("Please select both start and end times."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
