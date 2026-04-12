import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/station.model.dart';
import 'sensor_manager.dart';

class NavigationEngine extends ChangeNotifier {
  final SensorManager sensorManager;
  
  // Yolculuk Durumu
  MetroStation? currentStation;
  MetroStation? nextStation;
  int selectedVagon;
  String direction;

  // Sayaçlar ve Kontroller
  Timer? _tripTimer;
  int _secondsElapsed = 0;
  double _currentSpeed = 0.0;
  bool _isMoving = false;
  bool _isApproaching = false;

  // UI'ın dinleyebileceği Getters
  int get secondsElapsed => _secondsElapsed;
  double get currentSpeed => _currentSpeed;
  bool get isMoving => _isMoving;
  bool get isApproaching => _isApproaching;

  NavigationEngine({
    required this.sensorManager,
    required this.selectedVagon,
    required this.direction,
  });

  /// Yolculuğu Başlat (Kullanıcı butona bastığında çağrılır)
  void startTrip(MetroStation startStation, MetroStation targetStation) {
    currentStation = startStation;
    nextStation = targetStation;
    _secondsElapsed = 0;
    _isApproaching = false;
    
    // Sensör akışını dinlemeye başla
    sensorManager.speedStream.listen((speed) {
      _currentSpeed = speed;
      
      // Hareket durumunu güncelle
      if (speed > 5.0 && !_isMoving) {
        _isMoving = true;
        _startTimer();
      } else if (speed < 1.0 && _isMoving) {
        _isMoving = false;
        _stopTimerAndConfirmArrival();
      }
      
      notifyListeners(); // UI'ı güncelle
    });
  }

  void _startTimer() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      
      // Beklenen süreyi kontrol et (Örn: 120 saniye)
      int? expectedDuration = currentStation?.nextStationDurations[nextStation?.name];
      
      if (expectedDuration != null) {
        // Yolun %85'i bittiyse "Yaklaşılan İstasyon" uyarısını yak
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
    // Burada varış konfirme edilir ve bir sonraki durağa geçiş hazırlığı yapılır
    print("${nextStation?.name} durağına varıldı.");
    notifyListeners();
  }

  /// Senin tasarımlarındaki o özel navigasyon mesajını döndürür
  String getVagonGuidance() {
    if (nextStation == null) return "İstasyon bilgisi yok.";
    return nextStation!.vagonAdvantage[selectedVagon] ?? "Bu vagon için özel bilgi bulunamadı.";
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    super.dispose();
  }
}
