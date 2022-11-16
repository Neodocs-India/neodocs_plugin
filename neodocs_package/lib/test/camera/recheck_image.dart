import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodocs_package/test/process_image_.dart';

import '../../constants/app_font_family.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/new_elevated_button.dart';
import '../onboarding/dialog_no_internet.dart';
import 'capture_screen.dart';

class RecheckImageScreen extends StatefulWidget {
  final Map<String, dynamic> map;

  final double ratio;

  const RecheckImageScreen({Key? key, required this.map, required this.ratio})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImageCapturedState();
  }
}

class _ImageCapturedState extends State<RecheckImageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: size.height,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    customAppBar(
                        padding: 16,
                        title: Text(
                          "Verify Photo",
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        lightButton: false)
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.05),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: transformImage(
                            context, Image.file(File(widget.map["path"]!))))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /*Text(
                        widget.map["card"].toString(),
                        style:  Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,

                      ),*/
                    Text(
                      "Make sure the wellness card is clearly visible in the photo and tap then the  “Upload” button.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    NewElevatedButton(
                        onPressed: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.none) {
                            // todo: add a record to the client database
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (_) => ProcessImageScreen(
                                          map: widget.map,
                                        )));
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const NoInternetDialog();
                                });
                          }
                        },
                        text: "Upload"),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextButton(
                        onPressed: () async {
                          List<CameraDescription> cameras =
                              await availableCameras();
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (_) => CaptureScreen(
                                        cameras: cameras,
                                        startTime:
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                widget.map["startTime"] * 1000),
                                        user: widget.map,
                                      )));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.05),
                          backgroundColor: Colors.white.withOpacity(0.05),
                          minimumSize: const Size(double.infinity, 40),
                          side: const BorderSide(
                              color: Color(0XFF6B60F1), width: 1),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Retake photo",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.5),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFontFamily.manrope,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget transformImage(context, child) {
    // fetch screen size
    final size = MediaQuery.of(context).size;

    final image = Size(size.width, size.height);
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = image.aspectRatio * widget.ratio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: child,
      ),
    );
  }
}
// class _ImageCapturedState extends State<RecheckImageScreen> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           color: Colors.white,
//           height: MediaQuery.of(context).size.height,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10.0),
//                 child: Stack(
//                   alignment: Alignment.centerLeft,
//                   children: [
//                     const DarkBackButton(),
//                     Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Verify photo",
//                         style: Theme.of(context).textTheme.titleLarge,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     margin: EdgeInsets.only(
//                         bottom: MediaQuery.of(context).size.width * 0.05),
//                     child: ClipRRect(
//                         borderRadius: BorderRadius.circular(15),
//                         child: transformImage(
//                             context, Image.file(File(widget.map["path"]!))))),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     /*Text(
//                         widget.map["card"].toString(),
//                         style:  Theme.of(context).textTheme.bodyMedium,
//                         textAlign: TextAlign.center,

//                       ),*/
//                     Text(
//                       "Make sure the wellness card is clearly visible in the photo and tap then the  “Upload” button.",
//                       style: Theme.of(context).textTheme.bodyMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     DarkButton(
//                         onPressed: () async {
//                           var connectivityResult =
//                               await (Connectivity().checkConnectivity());
//                           if (connectivityResult != ConnectivityResult.none) {
//                             // todo: add a record to the client database
//                             Navigator.of(context)
//                                 .pushReplacement(MaterialPageRoute(
//                                     builder: (_) => ProcessImageScreen(
//                                           map: widget.map,
//                                         )));
//                           } else {
//                             showDialog(
//                                 context: context,
//                                 builder: (context) {
//                                   return const NoInternetDialog();
//                                 });
//                           }
//                         },
//                         child: const DarkButtonText("Upload")),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () async {
//                         List<CameraDescription> cameras =
//                             await availableCameras();
//                         Navigator.of(context).pushReplacement(MaterialPageRoute(
//                             builder: (_) => CaptureScreen(
//                                   cameras: cameras,
//                                   startTime:
//                                       DateTime.fromMicrosecondsSinceEpoch(
//                                           widget.map["startTime"] * 1000),
//                                   user: widget.map,
//                                 )));
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "Retake photo",
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ),
//                       style: TextButton.styleFrom(
//                         side: const BorderSide(
//                             color: AppColors.primaryColor, width: 2),
//                         shape: const RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(15))),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget transformImage(context, child) {
//     // fetch screen size
//     final size = MediaQuery.of(context).size;

//     final image = Size(size.width, size.height);
//     // calculate scale depending on screen and camera ratios
//     // this is actually size.aspectRatio / (1 / camera.aspectRatio)
//     // because camera preview size is received as landscape
//     // but we're calculating for portrait orientation
//     var scale = image.aspectRatio * widget.ratio;

//     // to prevent scaling down, invert the value
//     if (scale < 1) scale = 1 / scale;

//     return Transform.scale(
//       scale: scale,
//       child: Center(
//         child: child,
//       ),
//     );
//   }
// }
