import 'package:flutter/material.dart';

class ProgressProvider with ChangeNotifier {
  Map<String, double> _slotProgress = {};
  Map<String, Duration> _slotTimers = {};
  Map<String, Duration> _slotInitialTimes = {};
  Map<String, DateTime> _slotStartTimes = {};
  Map<String, DateTime> _slotEndTimes = {};

  Map<String, double> get slotProgress => _slotProgress;
  Map<String, Duration> get slotTimers => _slotTimers;
  Map<String, Duration> get slotInitialTimes => _slotInitialTimes;
  Map<String, DateTime> get slotStartTimes => _slotStartTimes;
  Map<String, DateTime> get slotEndTimes => _slotEndTimes;

  void updateProgress(String slotId, double progress) {
    _slotProgress[slotId] = progress;
    notifyListeners();
  }

  void updateTimer(String slotId, Duration remainingTime) {
    _slotTimers[slotId] = remainingTime;
    notifyListeners();
  }

  void updateInitialTime(String slotId, Duration initialTime) {
    _slotInitialTimes[slotId] = initialTime;
    notifyListeners();
  }

  void updateStartTime(String slotId, DateTime startTime) {
    _slotStartTimes[slotId] = startTime;
    notifyListeners();
  }

  void updateEndTime(String slotId, DateTime endTime) {
    _slotEndTimes[slotId] = endTime;
    notifyListeners();
  }
}