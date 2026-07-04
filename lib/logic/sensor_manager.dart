import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorManager {
  double _currentSpeed = 0.0;
  DateTime? _lastCheck;

  // Low-Pass Filter değişkenleri
  double _filteredY = 0.0;
  final double _alpha = 0.15; // Değer küçüldükçe veri yumuşar. 0.15 dengeli bir süzme sağlar.

  Stream<UserAccelerometerEvent> get rawSensorStream => userAccelerometerEvents;

  void resetSpeed() {
    _currentSpeed = 0.0;
    _lastCheck = DateTime.now();
    _filteredY = 0.0; // Filtreyi de sıfırlıyoruz
  }

  Stream<double> get speedStream {
    return userAccelerometerEvents.map((event) {
      DateTime now = DateTime.now();
      if (_lastCheck != null) {
        double dt = now.difference(_lastCheck!).inMilliseconds / 1000.0;

        // 1. ADIM: Low-Pass Filter ile anlık titreşimleri yumuşat
        _filteredY = _alpha * event.y + (1.0 - _alpha) * _filteredY;

        // 2. ADIM: Filtrelenmiş ivme üzerinden çok daha düşük bir eşikle hesaplama yap
        // 0.2 olan sert duvarı, 0.03 gibi çok hassas bir seviyeye çektik.
        if (_filteredY.abs() > 0.03) {
          _currentSpeed += _filteredY * dt * 3.6;
        }

        // Hızın sıfırın altına düşmesini engelle
        if (_currentSpeed < 0) _currentSpeed = 0;
      }
      _lastCheck = now;
      return _currentSpeed;
    });
  }
}