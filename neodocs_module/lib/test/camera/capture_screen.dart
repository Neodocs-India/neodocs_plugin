import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neodocs_module/test/camera/recheck_image.dart';
import 'package:neodocs_module/widgets/light_button.dart';
import 'package:r_scan/r_scan.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/toast_widget.dart';
import 'dialog_card_expired.dart';
import 'dialog_no_card_found.dart';

class CaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final DateTime startTime;

  const CaptureScreen(
      {Key? key, required this.cameras, required this.startTime})
      : super(key: key);

  @override
  _CameraState createState() {
    return _CameraState();
  }
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _CameraState extends State<CaptureScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  static const platform = MethodChannel('app.channel.neodocs/native');

  CameraController? controller;
  XFile? imageFile;
  bool enableAudio = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  late Map<String, String>
      extraData;// = {"userId":"userId","firstName":"firstName","lastName":"lastName","gender":"male","dateOfBirth":"1651047119","apiKey":"NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0"};

  @override
  void initState() {
    debugPrint("init State");

    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    _getDeviceInfo();

    getExtraData();
    onNewCameraSelected(widget.cameras[0]);
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );

  }

  void getExtraData() async {
    var data = await platform.invokeMethod('getExtraData');
    if (data != null) {
      debugPrint(data.toString());
      extraData = Map<String, String>.from(data);
    }
  }

  _getDeviceInfo() async {
    if (Platform.isAndroid) {
      _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: bodyWidget(context),
    );
  }

  Widget bodyWidget(context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          cameraWidget(context),
          Positioned(
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: size.height * 0.01, left: 0.01),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  customAppBar(
                    padding: 16,
                    lightButton: false,
                    title: Text(
                      'Scan Card',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.119),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                LightButton(
                    onPressed:
                        controller != null && controller!.value.isInitialized
                            ? onTakePictureButtonPressed
                            : null,
                    child: const LightButtonText("Take photo")),
                SizedBox(
                  height: size.height * 0.046,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cameraWidget(context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    var camera = controller!.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: _cameraPreviewWidget(),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: CameraPreview(
        controller!,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (TapDownDetails details) =>
                onViewFinderTap(details, constraints),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.175,
                      bottom: MediaQuery.of(context).size.height * 0.125),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: AssetImage('assets/images/img_card_frame.png'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        cameraController.setFlashMode(FlashMode.off);
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
      if (!cameraController.value.isCaptureOrientationLocked) {
        cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
        //showInSnackBar('Capture orientation unlocked');
      }
      /*unawaited(cameraController.startImageStream((CameraImage cameraImage) {
        debugPrint('image available ${cameraImage.width}x${cameraImage.height}');
        */ /*final results = decode(cameraImage);
        if(results!=null){
          debugPrint(results.text);
        }*/ /*
      }));*/
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
      Toast(context).showToastCamera("Pinch To Zoom");
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          Toast(context).showToastCamera(
            "Align the card to the Borders",
          );
        }
      });
    }
  }

  void onTakePictureButtonPressed() {
    debugPrint("-------------------------------------------------------------captureImage ");
    //_myAnalytics.trackMethod(MixPanelUtils.MP_Event_Capture);
    Map<String, String> extraInfo = {};
    extraInfo["lensDirection"] =
        controller!.description.lensDirection.toString();
    extraInfo["sensorOrientation"] =
        controller!.description.sensorOrientation.toString();
    extraInfo["aspectRatio"] = controller!.value.aspectRatio.toString();
    extraInfo["deviceOrientation"] =
        controller!.value.deviceOrientation.toString();
    extraInfo["exposureMode"] = controller!.value.exposureMode.toString();
    extraInfo["flashMode"] = controller!.value.flashMode.toString();
    extraInfo["phone_model"] = _deviceData["model"];
    extraInfo["phone_os"] = _deviceData["systemVersion"];

    takePicture().then((XFile? file) async {
      debugPrint("-------------------------------------------------------------captureImage 1");
      if (mounted) {
        setState(() {
          imageFile = file;
        });

        if (file != null) {
          debugPrint("-------------------------------------------------------------captureImage 2 ");
          RScanResult result;
          try {
            /*var image = img.decodeJpg(File(file.path).readAsBytesSync())!;
            LuminanceSource source;
            if(Platform.isAndroid) {
              source = RGBLuminanceSource(
                  image.height, image.width,
                  image
                      .getBytes(format: img.Format.abgr)
                      .buffer
                      .asInt32List());
            }else{
              source = RGBLuminanceSource(
                  image.width, image.height,
                  image
                      .getBytes(format: img.Format.abgr)
                      .buffer
                      .asInt32List());
            }
            var bitmap = BinaryBitmap(HybridBinarizer(source));

            var reader = QRCodeReader();
            result = reader.decode(bitmap);*/
            result = await RScan.scanImageMemory(await file.readAsBytes());

            if (result.message == null) {

              throw "no card found";
            }
          } catch (ex) {
            debugPrint("-------------------------------------------------------------captureImage 4");
            showDialog(
                context: context,
                builder: (context) {
                  return const NoCardDialog();
                });
            //Toast(context).showToastCamera("Error in image");
            return;
          }
          final card = validateCard(result.message!);

          if (card == null) {
            debugPrint("-------------------------------------------------------------captureImage return");
            return;
          }

          debugPrint(result.message!);

          //showInSnackBar('Picture saved to ${file.path}');
          debugPrint("captureImage path : ${file.path}");
          debugPrint("captureImage name : ${file.name}");
          Map<String, dynamic> map = {};
          map["path"] = file.path;
          map["uId"] = extraData["userId"]; //add userId to here
          map["firstName"] = extraData["firstName"];
          map["lastName"] = extraData["lastName"];
          map["gender"] = extraData["gender"];
          map["dateOfBirth"] = int.parse(extraData["dateOfBirth"] ?? "");
          map["testId"] = const Uuid().v4();
          map["processed_flag"] = false;
          map["startTime"] = widget.startTime.millisecondsSinceEpoch;
          map["captureTime"] = DateTime.now().millisecondsSinceEpoch;
          map["image_id"] = map["testId"];
          map["card"] = card;
          map["isComplete"] = false;
          map["extraInfo"] = extraInfo;

          map["apiKey"] = extraData["apiKey"]; //add apiKey to here

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => RecheckImageScreen(
                  map: map, ratio: controller!.value.aspectRatio)));
        }
      }
    });
  }

  Map<String, dynamic>? validateCard(String code) {
    if (code.isEmpty) {
      return null;
    }
    if (code.contains("qr_batch")) {
      _showDialog(CardExpiredDialog(onPressed: () {
        //navigate to shop screen
      }));
      return null;
    } else {
      try {
        String deCode = utf8.decode(base64.decode(base64.normalize(code)));
        //Toast(context).showToastCamera(deCode);
        if (deCode.contains("BATCH")) {
          Map<String, dynamic> card =
              json.decode(deCode) as Map<String, dynamic>;
          if ((int.tryParse(card["BATCH"])??0) >= 5) {
            return card;
          }
        } else {
          _showDialog(const NoCardDialog());
          return null;
        }
      } catch (ex) {
        _showDialog(const NoCardDialog());
        return null;
      }
    }
    return null;
  }

  _showDialog(Widget widget) {
    showDialog(
        context: context,
        builder: (context) {
          return widget;
        });
  }

  /*Result? decode(CameraImage image) {
    var plane = image.planes.first;
    LuminanceSource source = RGBLuminanceSource(
        image.width, image.height, plane.bytes.buffer.asInt32List());
    var bitmap = BinaryBitmap(HybridBinarizer(source));

    var reader = QRCodeReader();
    try {
      return reader.decode(bitmap);
    } catch (_) {
      return null;
    }
  }*/

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'systemVersion': build.version.sdkInt.toString(),
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;
