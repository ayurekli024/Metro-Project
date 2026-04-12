import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorManager {
  double _currentSpeed = 0.0;
  DateTime? _lastCheck;

  Stream<double> get speedStream {
    return userAccelerometerEvents.map((event) {
      DateTime now = DateTime.now();
      if (_lastCheck != null) {
        double dt = now.difference(_lastCheck!).inMilliseconds / 1000.0;
        
        // Tasarımındaki gibi ileri yönlü ivmeyi (Y ekseni varsayalım) alıyoruz
        // m/s'den km/h'ye çevirmek için 3.6 ile çarpıyoruz
        double acceleration = event.y; 
        
        if (acceleration.abs() > 0.2) { // Gürültü filtresi
          _currentSpeed += acceleration * dt * 3.6;
        }

        // Hızın negatif olmamasını ve durağan halde sıfırlanmasını sağla
        if (_currentSpeed < 0) _currentSpeed = 0;
      }
      _lastCheck = now;
      return _currentSpeed;
    });
  }
}
