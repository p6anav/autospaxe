import 'package:flutter/material.dart';
import 'dart:async';

class TestingPage extends StatefulWidget {
  @override
  _TestingPageState createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  Map<String, Duration> slotTimers = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mock data for slots with future end times
   List<Map<String, dynamic>> mockSlots = [
  {
    'id': 'slot1',
    'startTime': '2025-02-25 16:43:00', // Current time
    'endTime': '2025-02-25 18:30:45',  // Future end time (6:30:45 PM IST)
  },
  {
    'id': 'slot2',
    'startTime': '2025-02-25 17:00:00', // Future start time (5:00:00 PM IST)
    'endTime': '2025-02-25 19:15:20',  // Future end time (7:15:20 PM IST)
  },
];

    // Initialize slot timers
    for (var slot in mockSlots) {
      String slotId = slot['id'] ?? 'unknown';
      DateTime startTime = DateTime.parse(slot['startTime']);
      DateTime endTime = DateTime.parse(slot['endTime']);
      DateTime now = DateTime.now();

      // Calculate remaining time
      Duration remainingTime = endTime.difference(now);
      if (remainingTime < Duration.zero) {
        remainingTime = Duration.zero;
      }

      slotTimers[slotId] = remainingTime;
      print('Initialized slot $slotId with remaining time: $remainingTime');
    }

    // Start the timer to update remaining time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateRemainingTime();
    });

    if (_timer == null) {
      print('Timer is null, something went wrong during initialization.');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateRemainingTime() {
    DateTime now = DateTime.now();
    slotTimers.forEach((slotId, remainingTime) {
      if (remainingTime > Duration.zero) {
        Duration newRemainingTime = remainingTime - Duration(seconds: 1);
        setState(() {
          slotTimers[slotId] = newRemainingTime;
        });
        print('Updated slot $slotId with remaining time: $newRemainingTime');
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Page'),
      ),
      body: ListView.builder(
        itemCount: slotTimers.length,
        itemBuilder: (context, index) {
          String slotId = slotTimers.keys.elementAt(index);
          Duration remainingTime = slotTimers[slotId]!;
          return ListTile(
            title: Text('Slot $slotId'),
            subtitle: remainingTime == Duration.zero
                ? Text('Timer has expired')
                : Text('Remaining Time: ${formatDuration(remainingTime)}'),
          );
        },
      ),
    );
  }
}