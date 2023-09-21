@JS()
library opencv_interop;

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:js/js.dart';

@JS('window.user')
external String? get user;

@JS('console.dir')
external void inspectJS(dynamic obj);

@JS('dartObj')
external set sendObjectToJS(dynamic obj);

@JS('window.srcWidth')
external num getSrcWidth;

@JS('window.srcHeight')
external num getSrcHeight;

@JS('startStream')
external Future<html.VideoElement> startStream();

@JS('stopCamera')
external void stopCamera();

@JS('getContext')
external html.CanvasRenderingContext2D getContext();

//? 1st Step (Get promise that results in populating loaded cv)
@JS('cv')
external dynamic cvPromise;

//? Set global variable "opencv" to access the object
@JS('cv2')
external set openCV(OpenCV val);

@JS('Uint8Array')
@staticInterop
class Uint8Array {}

extension ArrayUtils on Uint8Array {
  Uint8List get value => this as Uint8List;
  // external set(Uint8Array newValue);
  external set(Uint8List newValue);
}

@JS()
@staticInterop
class OpenCV {}

extension CVUtils on OpenCV {
  external int CV_8UC1;
  external int CV_8UC4;
  external int DICT_4X4_250;
  external int COLOR_BGR2GRAY;
  external int COLOR_RGBA2RGB;
  external Mat imread(String input);
  external void imshow(String id, Mat image);
  external flip(Mat src, Mat res, int axis);
  external Mat matFromImageData(html.ImageData data);
  external void cvtColor(Mat image, Mat result, int color);
  external ArucoDictionary getPredefinedDictionary(int dict);
  external void drawDetectedMarkers(Mat image, MatVector corners, Mat ids);
  void toGray(Mat image, Mat result) =>
      this.cvtColor(image, result, this.COLOR_BGR2GRAY);
  ArucoDictionary getDefaultDict() =>
      getPredefinedDictionary(this.DICT_4X4_250);
}

//? TEST (static interop is better)
// @JS('cv2.Mat')
// class Mat {
//   external factory();
//   external factory Mat();
//   external String toString();
//   external int cols;
//   external int rows;
//   external Size size();
//   external int type();
//   external int channels();
//   external dynamic depth();
// }

@JS('cv2.Mat')
@staticInterop
class Mat {
  external factory Mat();
  external factory Mat.fromSize(int height, int width, int channels);
}

extension MatUtils on Mat {
  set tag(String tag) => this.tag = tag;
  // external Uint8Array data;
  external Uint8List data;
  external Int8List data8S;
  external Uint16List data16U;
  external Int16List data16S;
  external Int32List data32S;
  external Float32List data32F;
  external Float64List data64F;
  // external MatData data;
  external void delete();
  external int cols;
  external int rows;
  external bool empty();
  external Size size();
  external int type();
  external int channels();
  external dynamic depth();
  String get repr {
    return 'Dimensions: ${this.cols}x${this.rows} \nSize: ${this.size().repr} \nType: ${this.type()} \nChannels: ${this.channels()} \nDepth: ${this.depth()}';
  }
}

// @JS()
// @staticInterop
// class MatData {

// }

// extension DataUtils on MatData {
//   external void set(Uint8ClampedList);
// }

@JS('cv2.MatVector')
@staticInterop
class MatVector {
  external factory MatVector();
}

extension VectorUtils on MatVector {
  external void delete();
}

@JS('cv2.aruco_ArucoDetector')
@staticInterop
class ArucoDetector {
  external factory ArucoDetector(
    ArucoDictionary dict,
    ArucoDetectorParameters detectorParams,
    ArucoRefineParameters refineParams,
  );
}

extension AD on ArucoDetector {
  external dynamic detectMarkers(
    Mat image,
    MatVector vec1,
    Mat ids,
    MatVector vec2,
  );
}

@JS('cv2.aruco_Dictionary')
@staticInterop
class ArucoDictionary {}

extension DictUtils on ArucoDictionary {}

@JS('cv2.aruco_DetectorParameters')
@staticInterop
class ArucoDetectorParameters {
  external factory ArucoDetectorParameters();
}

extension DetectorUtils on ArucoDetectorParameters {
  external set markerBorderBits(int x);
}

@JS('cv2.aruco_RefineParameters')
@staticInterop
class ArucoRefineParameters {
  external factory ArucoRefineParameters(
    double minRepDistance,
    double errorCorrectionRate,
    bool checkAllOrders,
  );
}

extension RefineUtils on ArucoRefineParameters {}

@JS('cv2.QRCodeDetector')
@staticInterop
class QRCodeDetector {
  external factory QRCodeDetector();
}

extension QR on QRCodeDetector {
  external String? detectAndDecode(Mat image, Mat points, Mat straightCode);
}

@JS('cv2.Size')
@staticInterop
class Size {
  external factory Size(double width, double height);
}

extension SizeUtils on Size {
  external double width;
  external double height;
  String get repr {
    return '(${this.width}, ${this.height})';
  }
}
