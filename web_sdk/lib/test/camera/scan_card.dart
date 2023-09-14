import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:js/js_util.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:image/image.dart' as imgLib;

import 'opencv_interop.dart';

class ScanCard extends StatefulWidget {
  const ScanCard({super.key});

  @override
  State<ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<ScanCard> {
  final List<Future> futures = [];
  late final OpenCV cv;
  int count = 0;
  late int height, width;
  late final int srcWidth, srcHeight;
  late int canvasWidth, canvasHeight;
  static const viewId = 'canvas-view';
  static const canvasId = 'dstFl';
  late final html.VideoElement video;
  late final html.CanvasRenderingContext2D ctx;
  bool click = false;
  bool capture = false;
  bool validated = false;
  Mat? image;
  final displayImage = ValueNotifier<Uint8List?>(null);

  @override
  void dispose() {
    displayImage.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
  }

  Mat getFrame() {
    // final st = Stopwatch()..start();
    ctx.drawImage(video, 0, 0);
    // final imgData = ctx!.getImageData(0, 0, width, height);
    //? NEW METHOD - USES AVAILABLE WIDTH & HEIGHT TO GET CENTER IMAGE

    // print([
    //   max(0, ((srcWidth - canvasWidth) / 2).round()),
    //   max(0, ((srcHeight - canvasHeight) / 2).round()),
    //   min(srcWidth, ((srcWidth + canvasWidth) / 2).round()),
    //   min(srcHeight, ((srcHeight + canvasHeight) / 2).round()),
    // ]);

    final imgData = ctx.getImageData(
      max(0, ((srcWidth - canvasWidth) / 2).round()),
      max(0, ((srcHeight - canvasHeight) / 2).round()),
      min(srcWidth, ((srcWidth + canvasWidth) / 2).round()),
      min(srcHeight, ((srcHeight + canvasHeight) / 2).round()),
    );

    final src = cv.matFromImageData(imgData);
    cv.cvtColor(src, src, cv.COLOR_RGBA2RGB);

    // print('(${++count}) ${st.elapsedMilliseconds}ms');

    return src;
  }

  void detectMarkers() {
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
    displayImage.value = imgLib.encodePng(uploadImage, singleFrame: true);

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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${x.length} ARUCOS FOUND'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(milliseconds: 1500),
          action: SnackBarAction(
            label: 'Close',
            onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
          ),
        ),
      );

    final qr = QRCodeDetector();
    final points = Mat();
    final straightCode = Mat();
    final code = qr.detectAndDecode(img, points, straightCode);
    print('QR Code contents: $code');

    //TODO: UI changes Based on detection
    if (x.isEmpty) {
      print('NO ARUCO DETECTED');
    } else if (x.length < 2) {
      // saveImage();
    } else if (x.length == 2) {
      print('QR POINTS: ${points.data}');
      print('QR Straight Code: ${straightCode.data}');
      setState(() => validated = true);
    } else {}

    cv.drawDetectedMarkers(img, res, ids);

    // print('IDs: ${ids.data}');
    // final x = ids.data.toList()..removeWhere((e) => e == 0);
    // print('IDs: ${x.join(' ')}');

    res.delete();
    ids.delete();
    rejected.delete();
    points.delete();
    straightCode.delete();
  }

  void startCapture() {
    image?.delete();
    setState(() {
      validated = false;
      click = false;
      capture = true;
      image = null;
    });
    displayImage.value = null;
    Timer.periodic(
      Duration(milliseconds: 1000 ~/ 30),
      (timer) {
        if (click || !capture) timer.cancel();
        final mat = getFrame();
        if (click) {
          image = mat;
          detectMarkers();
          return;
        }
        cv.imshow(canvasId, mat);
        mat.delete();
      },
    );
  }
  //final img = imgLib.Image.fromBytes(width: src.cols, height: src.rows, bytes: src.data.buffer);
  //finalImage = MemoryImage(img.buffer.asUint8List());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width.toInt();
    height = size.height.toInt();

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: Future.wait(futures),
          // Future.wait([
          //   loadCV,
          //   promiseToFuture(startStream()),
          // availableCameras().then(
          //   (val) async {
          //     if (val.isEmpty) throw 'NO CAMERAS FOUND';
          //     final cam = val.firstWhere(
          //       (c) => [
          //         CameraLensDirection.back,
          //         CameraLensDirection.external
          //       ].contains(c.lensDirection),
          //       orElse: () => val.first,
          //     );
          //     final controller = CameraController(
          //       cam,
          //       ResolutionPreset.max,
          //       enableAudio: false,
          //     );
          //     await controller.initialize();
          //     return controller.value;
          //   },
          // ),
          // ]),

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

            return SizedBox(
              height: min(height, srcHeight).toDouble(),
              width: min(width, srcWidth).toDouble(),
              child: Stack(
                children: [
                  !capture && !click
                      ? Center(
                          child: ElevatedButton(
                            onPressed: startCapture,
                            child: Text('Start'),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(border: Border.all()),
                          child: SizedBox(
                            width: canvasWidth.toDouble(),
                            height: canvasHeight.toDouble(),
                            child: click
                                ? ValueListenableBuilder(
                                    valueListenable: displayImage,
                                    builder: (context, upload, _) {
                                      if (upload == null) return SizedBox();
                                      return Image.memory(upload);
                                    },
                                  )
                                : HtmlElementView(
                                    viewType: viewId,
                                    onPlatformViewCreated: (_) {
                                      print('Created platform view');
                                    },
                                  ),
                          ),
                        ),
                  Positioned(
                    bottom: 20,
                    child: SizedBox(
                      width: min(width, srcWidth).toDouble(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: capture || !click ? null : startCapture,
                            child: Text('Retake Image'),
                          ),
                          ElevatedButton(
                            onPressed: !capture
                                ? !click || !validated
                                    ? null
                                    : () async {
                                        /*final storage =
                                            FirebaseStorage.instanceFor(
                                                    bucket:
                                                        'gs://web-sdk-captures')
                                                .ref();

                                        storage
                                            .child(
                                                'image-${DateTime.now().toIso8601String()}.png')
                                            .putData(displayImage.value!)
                                            .then((snap) => print(snap.state));*/
                                      }
                                : () {
                                    setState(() {
                                      click = true;
                                      capture = false;
                                    });
                                  },
                            child: Text(!click ? 'Click' : 'Next'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
