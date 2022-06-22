import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timelines/timelines.dart';

import '../constants/app_colors.dart';
import '../model/process_image_model.dart';
import '../widgets/dark_button.dart';
import 'onboarding/dialog_unknown_error.dart';


const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);

class UploadImageScreen extends StatefulWidget {
  final Map<String, dynamic> map;
  final String apiKey;
  final bool resume;
  const UploadImageScreen({Key? key, required this.map, this.resume = false, required this.apiKey})
      : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  bool isComplete = false;
  bool isError = false;
  Color completeColor = AppColors.primaryColor;

  late ProcessImageModel process;
  late Map<String, dynamic> data;

  late Map<String,dynamic> endpoint;

  var errorCode = 0;
  @override
  void initState() {
    checkInternet();
    animationController = AnimationController(vsync: this);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint("Lottie Completed");
      }
    });
    debugPrint("${widget.map['uId']} ${widget.map['testId']}");

    process = ProcessImageModel(widget.apiKey);
    process.createRequest(widget.map);
    process.request.stream.listen((event) {
      endpoint = event;
      if(event.isNotEmpty){
        process.uploadImage(File(widget.map['path']),event["url"]??"", Map<String,String>.from(event["fields"] as Map) );
      }
    },onError: (error){
      debugPrint(error.toString());

      isError = true;
      isComplete = true;
      completeColor = Colors.red;
      if(mounted) {
        setState(() {});
      }
    });
    process.image.stream.listen((event) {
      if(event.isNotEmpty){
        if (mounted) {
          setState(() {
            isComplete = true;
          });
        }
      }
    },onError: (error){
      debugPrint(error.toString());

      isError = true;
      isComplete = true;
      completeColor = Colors.red;
      if(mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  void checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      isError = true;
      errorCode = 1;
      if (mounted) {
        setState(() {});
      }
    }
    Connectivity().onConnectivityChanged.listen((ConnectivityResult event) {
      if (ConnectivityResult.none == event && mounted && !isComplete) {
        isError = true;
        errorCode = 1;
      } else {
        isError = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isComplete && !isError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(exitMessage[0])),
              action: SnackBarAction(
                label: "YES",
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: Colors.white,
              ),
              backgroundColor: AppColors.primaryColor,
              duration: const Duration(seconds: 3),
            ));
            return false;
        } else{
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Results",
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 6, child: getAssets(0)),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.05,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                  ),
                  child: Text(
                    isError
                        ? error[errorCode]
                        : isComplete
                            ? _processes[3]
                            : _processes[0],
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.primaryColor),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.05,
                ),
                Expanded(
                    flex: 2,
                    child: isComplete
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.05,
                                right: MediaQuery.of(context).size.width * 0.05,
                                bottom: 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if(isError)
                                    Padding(
                                      padding:  const EdgeInsets.only(
                                          bottom: 10.0),
                                      child: AutoSizeText.rich( TextSpan(
                                        text:errorDetails[errorCode],
                                        style:
                                        Theme.of(context).textTheme.bodyLarge,
                                      ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                  DarkButton(
                                    onPressed: () {
                                      if (!isError) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: DarkButtonText(
                                        isError ? "Try Again" : "Continue"),
                                  ),
                                ]))
                        : Padding(
                            padding:  EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.05,
                                right: MediaQuery.of(context).size.width * 0.05,
                                bottom: 10.0),
                            child: RichText(
                              text: TextSpan(
                                  text: '',
                                  style: Theme.of(context).textTheme.labelLarge,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          'It might take some time to analyse your card. Please do not press the back button.\n',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ]),
                              textAlign: TextAlign.center,
                            ),
                          )),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.white,
                  child: Text.rich(TextSpan(text: "Caution : ",children: [
                    TextSpan(text: "For Research Use Only",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.primaryColor,fontStyle: FontStyle.italic),
                    ),
                  ],
                  ),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16,color: AppColors.primaryColor,fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getAssets(int index) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
        height: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(
          "packages/neodocs_package/assets/lottie/${isError ? _errorAssets[errorCode] : isComplete ? _assets[3] : _assets[index]}",
          controller: animationController,
          repeat: true,
          onLoaded: (composition) async {
            // Configure the AnimationController with the duration of the
            // Lottie file and start the animation.
            await Future.delayed(const Duration(milliseconds: 200));
            animationController
              ..duration = composition.duration
              ..repeat();
          },
        ),
      ),
    );
  }

}

final _processes = [
  'Uploading image',
  'Analyzing card',
  'Preparing results',
  'Image uploaded successfully!',
];
const error = [
  'Something went wrong',
  "Waiting for internet",
  "Image is unclear",
  "Invalid Image"
];

const errorDetails = [
  'We are not sure what happened. We recommend you to try again.',
  "As soon as Internet is up we will resume the process.",
  "Please make sure that there’s no glare/shadow on the wellness card while scanning and try Again.",
  "Please make sure that the wellness card is clearly visible and is aligned to the box provided and try again."
];

const exitMessage = [
  'The image is uploading.\nDo you still want to quit',
  "The image is being analysed.\nDo you still want to quit",
  "The Results have not yet processed.\nDo you still want to quit",
  "The Results have not yet processed.\nDo you still want to quit"
];

final _errorAssets = [
  'unknown_error.json',
  'no_internet.json',
  'glare.json',
  'invalid_image.json',
];

final _assets = [
  '1_upload.json',
  '2_upload.json',
  '3_upload.json',
  '4_upload.json',
];
