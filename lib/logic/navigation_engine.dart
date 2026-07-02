import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../data/metro_db.dart'; // Veritabanını import etmeyi unutma
import 'sensor_manager.dart';
import 'activity_manager.dart';

class NavigationEngine extends ChangeNotifier {
  final SensorManager sensorManager;
  final ActivityManager activityManager = ActivityManager();

  Map<String, dynamic>? currentStation;
  Map<String, dynamic>? nextStation;
  int selectedVagon = 1;
  bool isForwardDirection = true; // Yön bilgisini hafızada tutuyoruz

  double _currentSpeed = 0.0;
  int _secondsElapsed = 0;
  bool _isMoving = false;
  bool _isApproaching = false;
  ActivityType _userActivity = ActivityType.STILL;

  double rawX = 0.0;
  double rawY = 0.0;
  double rawZ = 0.0;

  double get currentSpeed => _currentSpeed;
  int get secondsElapsed => _secondsElapsed;
  bool get isMoving => _isMoving;
  bool get isApproaching => _isApproaching;
  ActivityType get userActivity => _userActivity;

  Timer? _tripTimer;
  StreamSubscription? _speedSubscription;
  StreamSubscription? _activitySubscription;
  StreamSubscription? _rawSensorSubscription;

  NavigationEngine({required this.sensorManager}) {
    _initActivityRecognition();
  }

  void _initActivityRecognition() {
    _activitySubscription = activityManager.activityStream.listen((activity) {
      _userActivity = activity.type;
      notifyListeners();
    });
  }

  // startTrip artık yön bilgisini (isForward) de alıyor
  void startTrip(Map<String, dynamic> start, Map<String, dynamic> target, int vagon, bool isForward) {
    currentStation = start;
    nextStation = target;
    selectedVagon = vagon;
    isForwardDirection = isForward;
    _secondsElapsed = 0;
    _isApproaching = false;
    _isMoving = false;

    _rawSensorSubscription?.cancel();
    _rawSensorSubscription = sensorManager.rawSensorStream.listen((event) {
      rawX = event.x;
      rawY = event.y;
      rawZ = event.z;
    });

    _speedSubscription?.cancel();
    _speedSubscription = sensorManager.speedStream.listen((speed) {
      _currentSpeed = speed;
      if (speed > 5.0 && !_isMoving) {
        _isMoving = true;
        _startTimer();
      } else if (speed < 1.0 && _isMoving) {
        double expected = currentStation?['time_to_next_sec'] ?? 0.0;
        // Beklenen sürenin en az %70'i geçtiyse ve hız düştüyse istasyona varılmıştır
        if (_secondsElapsed >= expected * 0.7) {
          _isMoving = false;
          _stopTimerAndTransitionToNext(); // Yeni fonksiyona yönlendirdik
        }
      }
      notifyListeners();
    });
  }

  void _startTimer() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      double expectedDuration = currentStation?['time_to_next_sec'] ?? 0.0;
      if (expectedDuration > 0 && _secondsElapsed >= expectedDuration * 0.85) {
        _isApproaching = true;
      }
      notifyListeners();
    });
  }

  // İŞTE ZİNCİRLEME OTOMATİK GEÇİŞ BURASI
  Future<void> _stopTimerAndTransitionToNext() async {
    _tripTimer?.cancel();
    _isApproaching = false;

    // Eğer sırada gidecek bir istasyon varsa, onu mevcut istasyon yap ve yenisini bul
    if (nextStation != null) {
      currentStation = nextStation;
      nextStation = await _calculateNextStationFromDB(currentStation!);
      _secondsElapsed = 0; // Kronometreyi yeni durak için sıfırla
    }

    notifyListeners();
  }

  // HomeScreen'deki köprüleme lojiğinin aynısı arka planda otonom çalışıyor
  Future<Map<String, dynamic>?> _calculateNextStationFromDB(Map<String, dynamic> current) async {
    int order = current['station_order'];
    String line = current['line_code'];
    final db = await MetroDatabase.instance.database;

    if (isForwardDirection) {
      var nextList = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: [line, order + 1]);
      if (nextList.isNotEmpty) return nextList.first;

      if (line == "M2" && current['station_name'] == "Necatibey") {
        var m1 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M1", 1]);
        return m1.isNotEmpty ? m1.first : null;
      }
      if (line == "M1" && current['station_name'] == "Batıkent") {
        var m3 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M3", 1]);
        return m3.isNotEmpty ? m3.first : null;
      }
    } else {
      var prevList = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: [line, order - 1]);
      if (prevList.isNotEmpty) return prevList.first;

      if (line == "M3" && current['station_name'] == "Batı Merkez") {
        var m1 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M1", 12]);
        return m1.isNotEmpty ? m1.first : null;
      }
      if (line == "M1" && current['station_name'] == "Kızılay") {
        var m2 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M2", 11]);
        return m2.isNotEmpty ? m2.first : null;
      }
    }
    return null; // Gerçekten hat bittiyse (Koru, OSB Törekent vb.)
  }

  void resetCalibration() {
    sensorManager.resetSpeed();
    _currentSpeed = 0.0;
    _secondsElapsed = 0;
    _isMoving = false;
    _isApproaching = false;
    _tripTimer?.cancel();
    notifyListeners();
  }

  String getVagonGuidance() {
    return "Vagon bilgileri yakında eklenecek.";
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _speedSubscription?.cancel();
    _activitySubscription?.cancel();
    _rawSensorSubscription?.cancel();
    super.dispose();
  }
}