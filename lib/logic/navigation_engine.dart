import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import '../models/station.model.dart';
import 'sensor_manager.dart';
import 'activity_manager.dart';

class NavigationEngine extends ChangeNotifier {
  final SensorManager sensorManager;
  final ActivityManager activityManager = ActivityManager();

  MetroStation? currentStation;
  MetroStation? nextStation;
  int selectedVagon = 1;
  String direction = "";

  double _currentSpeed = 0.0;
  int _secondsElapsed = 0;
  bool _isMoving = false;
  bool _isApproaching = false;
  ActivityType _userActivity = ActivityType.STILL;

  double get currentSpeed => _currentSpeed;
  int get secondsElapsed => _secondsElapsed;
  bool get isMoving => _isMoving;
  bool get isApproaching => _isApproaching;
  ActivityType get userActivity => _userActivity;

  Timer? _tripTimer;
  StreamSubscription? _speedSubscription;
  StreamSubscription? _activitySubscription;

  NavigationEngine({required this.sensorManager}) {
    _initActivityRecognition();
  }

  void _initActivityRecognition() {
    _activitySubscription = activityManager.activityStream.listen((activity) {
      _userActivity = activity.type;
      notifyListeners();
    });
  }

  void startTrip(MetroStation start, MetroStation target, int vagon) {
    currentStation = start;
    nextStation = target;
    selectedVagon = vagon;
    _secondsElapsed = 0;
    _isApproaching = false;
    _isMoving = false;

    _speedSubscription?.cancel();
    _speedSubscription = sensorManager.speedStream.listen((speed) {
      _currentSpeed = speed;
      if (speed > 5.0 && !_isMoving) {
        _isMoving = true;
        _startTimer();
      } else if (speed < 1.0 && _isMoving) {
        int expected = currentStation?.nextStationDurations[nextStation?.name] ?? 0;
        if (_secondsElapsed >= expected * 0.7) {
          _isMoving = false;
          _stopTimerAndConfirmArrival();
        }
      }
      notifyListeners();
    });
  }

  void _startTimer() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      int? expectedDuration = currentStation?.nextStationDurations[nextStation?.name];
      if (expectedDuration != null && _secondsElapsed >= expectedDuration * 0.85) {
        _isApproaching = true;
      }
      notifyListeners();
    });
  }

  void _stopTimerAndConfirmArrival() {
    _tripTimer?.cancel();
    _isApproaching = false;
    notifyListeners();
  }

  String getVagonGuidance() {
    if (nextStation == null) return "İstasyon bilgisi yok.";
    return nextStation!.vagonAdvantage[selectedVagon] ?? "Bu vagon için özel bilgi bulunmamaktadır.";
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _speedSubscription?.cancel();
    _activitySubscription?.cancel();
    super.dispose();
  }
}
