import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class ActivityManager {
  final _activityRecognition = FlutterActivityRecognition.instance;

  Stream<Activity> get activityStream => _activityRecognition.activityStream;

  Future<bool> checkPermission() async {
    // Android 10+ için özel izin kontrolü
    PermissionStatus status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  void startTracking(Function(Activity) onActivityChanged) async {
    bool hasPermission = await checkPermission();
    
    if (hasPermission) {
      activityStream.listen((Activity activity) {
        // activity.type: IN_VEHICLE, WALKING, STILL vb.
        // activity.confidence: HIGH, MEDIUM, LOW
        onActivityChanged(activity);
      });
    }
  }
}
