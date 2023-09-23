import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:js_util';
import 'dart:math';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:r_scan/r_scan.dart';
import 'package:uuid/uuid.dart';
import 'package:web_sdk/comm.dart';
import 'package:web_sdk/test/camera/recheck_image.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/light_button.dart';
import '../../widgets/toast_widget.dart';
import 'dialog_card_expired.dart';
import 'dialog_no_card_found.dart';
import 'opencv_interop.dart' hide Size;
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:image/image.dart' as imgLib;

class CaptureScreen extends StatefulWidget {
  final DateTime startTime;
  final Map<String, dynamic> user;
  const CaptureScreen({Key? key, required this.startTime, required this.user})
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

  //final Stream<html.ImageData> imageStream = Stream();
  final StreamController<ByteBuffer> streamController =
      StreamController<ByteBuffer>();

  late StreamSubscription _imageStreamSubscription;

  bool enableAudio = false;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  late final Map<String, String> extraData;

  final List<Future> futures = [];
  late final OpenCV cv;
  int count = 0;
  late int height, width;
  int srcWidth = 1, srcHeight = 1;
  late int canvasWidth, canvasHeight;
  static const viewId = 'canvas-view';
  static const canvasId = 'dstFl';
  late final html.VideoElement video;
  late final html.CanvasRenderingContext2D ctx;
  bool click = false;
  //bool capture = false;
  bool processing = false;
  bool captured = false;
  bool validated = false;
  Mat? image;
  final displayImage = ValueNotifier<Uint8List?>(null);
  MemoryImage? finalImage;

  String _qr = "";
  @override
  void initState() {
    debugPrint("init State");

    super.initState();
    //_getDeviceInfo();

    futures.add(
        getExtraData().then((val) => extraData = val.cast<String, String>()));
    print('Loading CV');
    futures.add(promiseToFuture(cvPromise).then((val) {
      if (val is! OpenCV) {
        return promiseToFuture(val).then((value) => cv = value);
      }
      cv = val;
      openCV = val;
      return val;
    }));
    futures.add(promiseToFuture(startStream()).then((value) {
      video = value as html.VideoElement;
      srcHeight = video.height;
      srcWidth = video.width;
      ctx = getContext();
    }));

    //ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (_) => html.CanvasElement()
        ..setAttribute('id', canvasId)
        ..setAttribute('style', 'width: 100%; height: 100%'),
    );
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 4),startCapture);
    });*/
  }

  Future<Map<String, dynamic>> getExtraData() async {
    //Comm.sendMessage('userdata');
    if (kDebugMode) {
      return {
        "userId": "userId",
        "firstName": "firstName",
        "lastName": "lastName",
        "gender": "male",
        "dateOfBirth": "1651047119",
        "apiKey": "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0"
      };
    }
    /*var gotData = false;
    while (!gotData) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        if (user != null) {
          gotData = true;
        }
      });
    }
    Comm.sendMessage('Got Data');*/

    final cookie = document.cookie!;
    debugPrint("--------------$cookie");
    String value = Uri.decodeComponent(cookie);
    debugPrint("--------------$value");

    final userVal = value.split("=");
    final cookieMap = Map<String,dynamic>.from(json.decode(userVal[1]));
    debugPrint("--------------$cookieMap");
    return cookieMap;
      //jsonDecode(user!);
  }

  _getDeviceInfo() async {
    if (kIsWeb) {
      _deviceData =
          (await deviceInfoPlugin.webBrowserInfo) as Map<String, dynamic>;
    }
  }

  @override
  void dispose() {
    displayImage.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    height = (1.sh).toInt();
    width = 1.sw.toInt();
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
          /*ValueListenableBuilder(
            valueListenable: displayImage,
            builder: (context, upload, _) {
              if (upload == null) {
                return  Container(color: Colors.red,height: 20,width: 20,);
              }
              return Image.memory(upload);
            },
          ),*/
          /*StreamBuilder<ByteBuffer>(
      stream: streamController.stream,
          builder: (_, buffer) {
            if (!buffer.hasData) {
              debugPrint("streamController null");
              return const SizedBox.shrink();
            }
            if(image== null){
              debugPrint("streamController image null");
              return const SizedBox.shrink();
            }
            debugPrint("streamController has data");

            final uploadImage = imgLib.Image.fromBytes(
              width: 515,
              height: 480,
              bytes: buffer.data!,
              numChannels: 4,
            );
            final imgBuffer = imgLib.encodePng(uploadImage);
            return Image.memory(imgBuffer);
          }),*/
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
                    onPressed: (click || processing)
                        ? null
                        : onTakePictureButtonPressed,
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
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size
        .aspectRatio; //(Size(srcWidth.toDouble(),srcWidth.toDouble()).aspectRatio);
    debugPrint(
        "${size.width}, ${size.height},----${image?.cols}, ${image?.rows},----${srcWidth}, ${srcWidth},");
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
    return Center(
      child: FutureBuilder(
        future: Future.wait(futures),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data == null || snap.hasError) {
            return Text('Problem while loading CV ${snap.error}');
          }

          final srcAspectRatio = srcWidth / srcHeight;
          if (height > srcHeight) {
            canvasWidth = min(width, srcWidth);
            canvasHeight = (canvasWidth * srcAspectRatio).round();
          } else if (width > srcWidth) {
            canvasHeight = min(height, srcHeight);
            canvasWidth = (canvasHeight * srcAspectRatio).round();
          } else {
            canvasWidth = srcWidth;
            canvasHeight = srcHeight;
          }
          canvasHeight = canvasWidth;
          //Future.delayed(const Duration(seconds: 2),startCapture);
          return AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              child: Stack(
                children: [
                  HtmlElementView(
                    viewType: viewId,
                    onPlatformViewCreated: (_) {
                      processFrame();
                      if (kDebugMode) {
                        print('Created platform view');
                      }
                    },
                  ),
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
            ),
          );
        },
      ),
    );

    /*Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child:
        CameraPreview(
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
      );*/
  }

  void onTakePictureButtonPressed() {
    setState(() {
      click = true;
    });
  }

  /*void startCapture() {
    image?.delete();
    Timer.periodic(
      const Duration(milliseconds: 1000 ~/ 60),
          (timer) async {
        final mat = getFrame();
        image = mat;
        if (click  && !processing) {
          processing = true;
          click = false;
          if (await detectMarkers()) {
            timer.cancel();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => RecheckImageScreen(
                    map: getMap(), ratio: 1,image:finalImage!)));
          }
          processing = false;
          setState(() {});
        }
        cv.imshow(canvasId, image!);
        Future.delayed(const Duration(milliseconds: 140),()=>mat.delete());

      },
    );
  }*/

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = {};
    map["uId"] = extraData["userId"]; //add userId to here
    map["firstName"] = extraData["firstName"];
    map["lastName"] = extraData["lastName"];
    map["gender"] = extraData["gender"];
    map["dateOfBirth"] = int.parse(extraData["dateOfBirth"].toString());
    map["testId"] = const Uuid().v4();
    map["processed_flag"] = false;
    map["startTime"] = widget.startTime.millisecondsSinceEpoch;
    map["captureTime"] = DateTime.now().millisecondsSinceEpoch;
    map["image_id"] = map["testId"];
    //map["card"] = card;
    map["isComplete"] = false;

    map["apiKey"] = extraData["apiKey"]; //add apiKey to here
    return map;
  }

  processFrame() async {
    final mat = getFrame();
    image = mat;
    if (click && !processing) {
      processing = true;
      click = false;
      if (await detectMarkers()) {
        captured = true;
        stopCamera();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => RecheckImageScreen(
                map: getMap(), ratio: 1, image: finalImage!)));
      }
      processing = false;

      setState(() {});
    }
    if (!captured) {
      Future.delayed(const Duration(milliseconds: 60), processFrame);
    }
    cv.imshow(canvasId, image!);
    Future.delayed(const Duration(milliseconds: 140), () => mat.delete());
  }

  Future<bool> detectMarkers() async {
    if (image == null) throw 'Image is null';
    final img = image!;

    print('Captured image has dimensions: ${img.cols}x${img.rows}');

    final imgData = ctx
        .getImageData(
          max(0, ((srcWidth - width) / 2).round()),
          max(0, ((srcHeight - height) / 2).round()),
          min(srcWidth, ((srcWidth + width) / 2).round()),
          min(srcHeight, ((srcHeight + height) / 2).round()),
        )
        .data
        .buffer;

    final uploadImage = imgLib.Image.fromBytes(
      width: img.cols,
      height: img.rows,
      bytes: imgData,
      numChannels: 4,
    );
    final bytes = imgLib.encodeJpg(uploadImage);
    finalImage = MemoryImage(bytes);

    final dict = cv.getDefaultDict();
    final detectorParams = ArucoDetectorParameters();
    final refineParams = ArucoRefineParameters(10, 3, true);
    final ad = ArucoDetector(dict, detectorParams, refineParams);
    final res = MatVector();
    final ids = Mat();
    final rejected = MatVector();
    ad.detectMarkers(img, res, ids, rejected);
    final x = ids.data.toList();
    x.removeWhere((e) => e == 0);

    /*await RScan.scanImageMemory(bytes).then((value) async {
      _qr = value?.message??"";
      debugPrint("RScan ----------- ${value.message ?? "not found"}");
      validateCard(_qr ?? "");
    });*/

    if (x.length >= 2) {
      //todo:
      return true;
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const NoCardDialog();
          });
      return false;
    }
  }

  Mat getFrame() {
    ctx.drawImage(video, 0, 0);
    final imgData = ctx.getImageData(
      max(0, ((srcWidth - canvasWidth) / 2).round()),
      max(0, ((srcHeight - canvasHeight) / 2).round()),
      min(srcWidth, ((srcWidth + canvasWidth) / 2).round()),
      min(srcHeight, ((srcHeight + canvasHeight) / 2).round()),
    );

    final src = cv.matFromImageData(imgData);

    cv.cvtColor(src, src, cv.COLOR_RGBA2RGB);

    return src;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          if ((int.tryParse(card["BATCH"]) ?? 0) >= 5) {
            return card;
          }
        }
      } catch (ex) {
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
}
