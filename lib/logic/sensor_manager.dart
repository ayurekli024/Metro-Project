import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorManager {
  double _currentSpeed = 0.0;
  DateTime? _lastCheck;

  Stream<UserAccelerometerEvent> get rawSensorStream => userAccelerometerEvents;

  // GELİŞTİRİCİ İÇİN: Sensör kaymasını (drift) sıfırlama metodu
  void resetSpeed() {
    _currentSpeed = 0.0;
    _lastCheck = DateTime.now();
  }

  Stream<double> get speedStream {
    return userAccelerometerEvents.map((event) {
      DateTime now = DateTime.now();
      if (_lastCheck != null) {
        double dt = now.difference(_lastCheck!).inMilliseconds / 1000.0;

        // İleri yönlü ivmeyi (Y ekseni varsayıyoruz) alıyoruz
        double acceleration = event.y;

        if (acceleration.abs() > 0.2) { // Gürültü filtresi
          _currentSpeed += acceleration * dt * 3.6;
        }

        if (_currentSpeed < 0) _currentSpeed = 0;
      }
      _lastCheck = now;
      return _currentSpeed;
    });
  }
}