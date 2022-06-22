library neodocs_package;

import 'package:camera/camera.dart';
export 'test/onboarding/test_onboarding.dart';

class NeoDocs {
  //static const MethodChannel _channel = MethodChannel('face_camera');

  static late List<CameraDescription> _cameras = [];

  /// Initialize device cameras
  static Future<void> intialize() async {
    /// Fetch the available cameras before initializing the app.
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      print('${e.code} ${e.description}');
    }
  }

  /// Returns available cameras
  static List<CameraDescription> get cameras {
    return _cameras;
  }
}