import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import '../models/station.model.dart';
import 'sensor_manager.dart';
import 'activity_manager.dart';

class NavigationEngine extends ChangeNotifier {
  final SensorManager sensorManager;
  final ActivityManager activityManager = ActivityManager();

  // Yolculuk Durumu
  MetroStation? currentStation;
  MetroStation? nextStation;
  int selectedVagon;
  String direction;

  // Canlı Takip Verileri
  double _currentSpeed = 0.0;
  int _secondsElapsed = 0;
  bool _isMoving = false;
  bool _isApproaching = false;
  ActivityType _userActivity = ActivityType.STILL;

  // UI Getters
  double get currentSpeed => _currentSpeed;
  int get secondsElapsed => _secondsElapsed;
  bool get isMoving => _isMoving;
  bool get isApproaching => _isApproaching;
  ActivityType get userActivity => _userActivity;

  Timer? _tripTimer;
  StreamSubscription? _speedSubscription;
  StreamSubscription? _activitySubscription;

  NavigationEngine({
    required this.sensorManager,
    required this.selectedVagon,
    required this.direction,
  }) {
    _initActivityRecognition();
  }

  void _initActivityRecognition() {
    _activitySubscription = activityManager.activityStream.listen((activity) {
      _userActivity = activity.type;
      notifyListeners();
    });
  }

  /// Yolculuğu Başlat (Örn: AKM -> Akköprü)
  void startTrip(MetroStation start, MetroStation target) {
    currentStation = start;
    nextStation = target;
    _secondsElapsed = 0;
    _isApproaching = false;

    // Sensör dinleyicisini başlat
    _speedSubscription?.cancel();
    _speedSubscription = sensorManager.speedStream.listen((speed) {
      _currentSpeed = speed;

      // Hareket Algılama (5 km/h üstü hareket kabul edilir)
      if (speed > 5.0 && !_isMoving) {
        _isMoving = true;
        _startTimer();
      } 
      // Durma Algılama (1 km/h altı duruş kabul edilir)
      else if (speed < 1.0 && _isMoving) {
        // Hata Önleme: Eğer beklenen sürenin %70'inden önce durduysa istasyon sayma
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

      // Senin verin: AKM-Akköprü 130 saniye
      int? expectedDuration = currentStation?.nextStationDurations[nextStation?.name];
      
      if (expectedDuration != null) {
        // Tasarımdaki kırmızı uyarının yanacağı an (110. saniye civarı)
        if (_secondsElapsed >= expectedDuration * 0.85) {
          _isApproaching = true;
        }
      }
      notifyListeners();
    });
  }

  void _stopTimerAndConfirmArrival() {
    _tripTimer?.cancel();
    _isApproaching = false;
    
    // İstasyon Navigasyonu Aktifleşir (Vagon yönlendirmesi)
    debugPrint("${nextStation?.name} durağına giriş yapıldı.");
    notifyListeners();
  }

  String getVagonGuidance() {
    if (nextStation == null) return "İstasyon bilgisi yok.";
    return nextStation!.vagonAdvantage[selectedVagon] ?? "Vagon bilgisi bulunamadı.";
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _speedSubscription?.cancel();
    _activitySubscription?.cancel();
    super.dispose();
  }
}
