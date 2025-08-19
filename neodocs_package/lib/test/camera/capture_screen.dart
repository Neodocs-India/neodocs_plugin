import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:neodocs_package/test/camera/qr_decoder.dart';
import 'package:neodocs_package/test/camera/recheck_image.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/light_button.dart';
import '../../widgets/toast_widget.dart';
import 'dialog_card_expired.dart';
import 'dialog_no_card_found.dart';

class CaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final DateTime startTime;
  final Map user;

  const CaptureScreen(
      {super.key,
      required this.cameras,
      required this.startTime,
      required this.user});

  @override
  State createState() {
    return _CameraState();
  }
}

void logError(String code, String? message) {
  if (message != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}

class _CameraState extends State<CaptureScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  CameraController? controller;
  XFile? imageFile;
  bool enableAudio = false;

  late Map<String, dynamic> extraData;
  // extraData = {"userId":"userId","firstName":"firstName","lastName":"lastName","gender":"male","dateOfBirth":"1651047119","apiKey":"NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0"};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getDeviceInfo();
    getExtraData();
    onNewCameraSelected(widget.cameras[0]);
  }

  void getExtraData() async {
    extraData = Map<String, dynamic>.from(widget.user);
    log(extraData.toString());
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
    super.dispose();
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
    return CameraPreview(
      controller!,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.175,
                  bottom: MediaQuery.of(context).size.height * 0.125),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(
                      'packages/neodocs_package/assets/images/img_card_frame.png'),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
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
      enableAudio: false,
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
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
      Toast(context).showToastCamera("Pinch To Zoom");
      Future.delayed(const Duration(seconds: 4), () {
        Toast(context).showToastCamera(
          "Align the card to the Borders",
        );
      });
    }
  }

  void onTakePictureButtonPressed() {
    debugPrint("captureImage ");
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
      if (mounted) {
        setState(() {
          imageFile = file;
        });

        if (file != null) {
          String? result;
          try {
            result = await readQR(file.path);

            if (result == null) {
              throw "no card found";
            }
          } catch (ex) {
            debugPrint(ex.toString());
            showDialog(
                context: context,
                builder: (context) {
                  return const NoCardDialog();
                });
            //Toast(context).showToastCamera("Error in image");
            showInSnackBar('NoCardDialog');
            return;
          }
          final card = validateCard(result);

          if (card == null) {
            return;
          }

          //debugPrint(result);

          //showInSnackBar('Picture saved to ${file.path}');
          //debugPrint("captureImage path : ${file.path}");
          //debugPrint("captureImage name : ${file.name}");
          Map<String, dynamic> map = {};
          map["path"] = file.path;
          map["uId"] = extraData["userId"]; //add userId here
          map["firstName"] = extraData["firstName"];
          map["lastName"] = extraData["lastName"];
          map["gender"] = extraData["gender"];
          map["dateOfBirth"] = int.parse(extraData["dateOfBirth"].toString());
          map["testId"] = const Uuid().v4();
          map["processed_flag"] = false;
          map["startTime"] = widget.startTime.millisecondsSinceEpoch;
          map["captureTime"] = DateTime.now().millisecondsSinceEpoch;
          map["image_id"] = map["testId"];
          map["card"] = card;
          map["isComplete"] = false;
          map["extraInfo"] = extraInfo;

          map["apiKey"] = extraData["apiKey"]; //add apiKey to here
          //debugPrint("cam ${map['uId']} ${map['testId']}");

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => RecheckImageScreen(
                  map: map, ratio: controller!.value.aspectRatio)));
        }
      }
    });
  }
  Future<String?> readQR(path)async {
    File imageFile = File(path);
    final inputImage = InputImage.fromFile(imageFile);
    final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
    for (Barcode barcode in barcodes) {
      debugPrint(barcode.displayValue);
      if(barcode.displayValue !=null) {
        return barcode.displayValue;
      }
    }
    return null;

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
        if (code.startsWith('e')) {
          String deCode =
              utf8.decode(base64.decode(base64.normalize(code.trim())));
          if (deCode.contains("BATCH")) {
            Map<String, dynamic> card =
                json.decode(deCode) as Map<String, dynamic>;
            if ((int.tryParse(card["BATCH"]) ?? 0) >= 5) {
              return card;
            }
          }
        } else {
          return decodeDataAdvanced(code);
        }
        _showDialog(const NoCardDialog());
        return null;
      } catch (ex, stackTrace) {
        debugPrint('validateCard error: $ex\n$stackTrace');
        _showDialog(const NoCardDialog());
        return null;
      }
    }
  }

  _showDialog(Widget widget) {
    showDialog(
        context: context,
        builder: (context) {
          return widget;
        });
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
      'androidId': build.id,
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
