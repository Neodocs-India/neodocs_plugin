import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:neodocs_module/test/process_image_.dart';

import '../../../constants/app_colors.dart';
import '../../widgets/dark_back_button.dart';
import '../../widgets/dark_button.dart';
import '../onboarding/dialog_no_internet.dart';
import '../process_image.dart';
import 'capture_screen.dart';

class RecheckImageScreen extends StatefulWidget {
  final Map<String,dynamic> map;

  final double ratio;

  const RecheckImageScreen({Key? key, required this.map, required this.ratio}) : super(key: key);

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
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
            height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    const DarkBackButton(
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Verify photo",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.05 ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                        child: transformImage(context,Image.file(File(widget.map["path"]!))))),
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
                        style:  Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,

                      ),
                      const SizedBox(height: 20,),
                      DarkButton(onPressed: () async {
                        var connectivityResult = await (Connectivity().checkConnectivity());
                        if (connectivityResult != ConnectivityResult.none) {
                          // todo: add a record to the client database
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> ProcessImageScreen(map:widget.map,)));
                        } else{
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const NoInternetDialog();
                              });
                        }

                      }, child:const DarkButtonText("Upload")),
                      const SizedBox(height: 10,),
                      TextButton(
                        onPressed: () async {
                          List<CameraDescription> cameras = await availableCameras();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> CaptureScreen(cameras: cameras,startTime: DateTime.fromMicrosecondsSinceEpoch(widget.map["startTime"] * 1000))));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Retake photo",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          side:  const BorderSide(color: AppColors.primaryColor, width: 2),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15))),
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(height: 10,),

                    ],
                  ),
                ),


            ],
          ),
        ),
      ),
    );
  }

  Widget transformImage(context,child) {
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
