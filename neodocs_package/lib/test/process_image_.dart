import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:timelines/timelines.dart';

import '../constants/app_colors.dart';
import '../constants/custom_decorations.dart';
import '../model/process_image_model.dart';
import '../widgets/new_elevated_button.dart';
import 'onboarding/step_dispose.dart';

const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);

class ProcessImageScreen extends StatefulWidget {
  final Map<String, dynamic> map;
  const ProcessImageScreen({Key? key, required this.map}) : super(key: key);

  @override
  _ProcessImageScreenState createState() => _ProcessImageScreenState();
}

class _ProcessImageScreenState extends State<ProcessImageScreen>
    with TickerProviderStateMixin {
  int _processIndex = 0;
  late AnimationController animationController;
  StreamSubscription? listener;
  bool isComplete = false;
  bool isError = false;
  Color completeColor = AppColors.primaryColor;
  static const platformCallback = MethodChannel('app.channel.neodocs/native');

  late ProcessImageModel process;
  late Map<String, dynamic> data;
  late Map<String, dynamic> endpoint;
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
    data = widget.map;
    debugPrint(widget.map["apiKey"]);
    process = ProcessImageModel(widget.map["apiKey"]);

    debugPrint("${widget.map['uId']} ${widget.map['testId']}");

    process.createRequest(widget.map);
    process.endpoint.listen((event) {
      endpoint = event;
      if (event.isNotEmpty) {
        process.uploadImage(File(widget.map['path']), event["url"] ?? "",
            Map<String, String>.from(event["fields"] as Map));
      }
    }, onError: (error) {
      debugPrint(error.toString());

      isError = true;
      isComplete = true;
      completeColor = Colors.red;
      if (mounted) {
        setState(() {});
      }
    });
    process.upload.listen((event) {
      if (event.isNotEmpty) {
        if (mounted) {
          setState(() {
            _processIndex = 1;
          });
        }
        process.createConnection({
          "action": "getResults",
          "image_id": widget.map['testId'],
          "uId": widget.map['uId'],
          "x-api-key": widget.map["apiKey"],
          "timeout": 75
        });
        process.updates.listen((event) {
          listenToChange(event);
        });
      }
    }, onError: (error) {
      debugPrint(error.toString());
      isError = true;
      isComplete = true;
      completeColor = Colors.red;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void listenToChange(event) {
    debugPrint(event.toString());
    if (mounted && !event.toString().contains("wss://")) {
      if (event["statusCode"] != null) {
        final map = event["body"]["results"];
        debugPrint("mounted");
        data = map;
        if (map['processed_flag'] != null && map['processed_flag']) {
          if (isComplete) {
            process.socket.close();
          }
          if (map["status_code"] != 200) {
            isError = true;
            completeColor = Colors.red;
            //_showErrorDialog();
            if (map["status_code"] == 302 || map["status_code"] == 303) {
              errorCode = 2;
            } else if (map["status_code"] == 316) {
              errorCode = 3;
            } else {
              errorCode = 2;
            }
            setState(() {
              data = map;
              isComplete = true;
              _processIndex = 2;
              isError = true;
            });
            listener?.cancel();
          } else if (map["isComplete"] == true && map["status_code"] == 200) {
            listener?.cancel();
            setState(() {
              isComplete = true;
              _processIndex = 2;
              isError = false;
            });
          } else if (map["status_code"] == 200) {
            setState(() {
              data = map;
              _processIndex = 2;
            });
            /*Future.delayed(const Duration(seconds: 10), () {
              process.getUpdates(widget.map['uId'], widget.map['testId']);
            });*/
          }
        }
      }
    }
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

  Color getColor(int index) {
    if (index == _processIndex && !isComplete) {
      return inProgressColor;
    } else if (index < _processIndex || isComplete) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (!isComplete) {
          if (_processIndex < 3) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(exitMessage[_processIndex])),
              action: SnackBarAction(
                label: "YES",
                onPressed: () {
                  platformCallback.invokeMethod(
                      "nativeCallback", {"status": "0", "data": data});
                  Navigator.pop(context);
                },
                textColor: Colors.white,
              ),
              backgroundColor: AppColors.primaryColor,
              duration: const Duration(seconds: 3),
            ));
          } else {
            Navigator.pop(context);
          }
        }
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
                height: 0.2.sh,
                decoration: AppDesign(context).headerDecoration,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 0.075.sh),
                        child: Text(
                          "Results",
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                )),
            Expanded(
              child: Container(
                decoration: AppDesign(context).bodyDecoration,
                child: Container(
                  transform: Matrix4.translationValues(0.0, -44, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: AppDesign(context).statusDecoration,
                              alignment: Alignment.centerLeft,
                              height: 88,
                              child: AutoSizeText.rich(
                                  TextSpan(text: "", children: [
                                TextSpan(
                                  text: isError
                                      ? "Error!\n"
                                      : isComplete
                                          ? "Success!\n"
                                          : "Please wait!\n",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                          height: 1.2,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                TextSpan(
                                    text: isError
                                        ? error[errorCode]
                                        : isComplete
                                            ? "Please continue to dispose."
                                            : "We’re processing your result",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary))
                              ])),
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 5, child: getAssets(_processIndex)),
                      SizedBox(
                        height: size.height * 0.1,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.2,
                        ),
                        child: Text(
                          isError
                              ? error[errorCode]
                              : isComplete
                                  ? _processes[3]
                                  : _processes[_processIndex],
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: getTimeLine(),
                          )),
                      Expanded(
                          flex: 2,
                          child: isComplete
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                      right: MediaQuery.of(context).size.width *
                                          0.05,
                                      bottom: size.height * 0.0115),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (isError)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: size.height * 0.0115),
                                            child: AutoSizeText.rich(
                                              TextSpan(
                                                text: errorDetails[errorCode],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(fontSize: 12),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.064,
                                          ),
                                          child: NewElevatedButton(
                                            margin: EdgeInsets.zero,
                                            onPressed: () {
                                              if (!isError) {
                                                platformCallback.invokeMethod(
                                                    "nativeCallback", {
                                                  "status": data["status_code"]
                                                      .toString(),
                                                  "data": data
                                                });
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        DisposeStep(test:data),
                                                  ),
                                                );
                                              } else {
                                                Navigator.of(context).pop();
                                                platformCallback.invokeMethod(
                                                    "nativeCallback", {
                                                  "status": data["status_code"]
                                                      .toString(),
                                                  "data": data
                                                });
                                              }
                                            },
                                            text: isError
                                                ? "Try Again"
                                                : "Continue",
                                          ),
                                        ),
                                      ]))
                              : Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                      right: MediaQuery.of(context).size.width *
                                          0.05,
                                      bottom: size.height * 0.0115),
                                  child: RichText(
                                    text: TextSpan(
                                        text: '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                "It might take some time to analyse your card.\nPlease do not dispose off the test card unless asked to do so.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ]),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTimeLine() {
    return Center(
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: const ConnectorThemeData(
            space: 30.0,
            thickness: 5.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) =>
              MediaQuery.of(context).size.width * 0.9 / 3,
          indicatorBuilder: (_, index) {
            var color;
            var child;
            if (index == _processIndex && !isComplete) {
              color = inProgressColor;
              child = const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            } else if (index < _processIndex || isComplete) {
              color = completeColor;
              child = Icon(
                isError ? Icons.cancel_outlined : Icons.check,
                color: Colors.white,
                size: 15.0,
              );
            } else {
              color = todoColor;
            }

            if (index <= _processIndex) {
              return Stack(
                children: [
                  CustomPaint(
                    size: const Size(30.0, 30.0),
                    painter: _BezierPainter(
                      color: color,
                      drawStart: index > 0,
                      drawEnd: index < _processIndex,
                    ),
                  ),
                  DotIndicator(
                    size: 30.0,
                    color: color,
                    child: child,
                  ),
                ],
              );
            } else {
              return Stack(
                children: [
                  CustomPaint(
                    size: const Size(15.0, 15.0),
                    painter: _BezierPainter(
                      color: color,
                      drawEnd: index < 2,
                    ),
                  ),
                  OutlinedDotIndicator(
                    borderWidth: 4.0,
                    color: color,
                  ),
                ],
              );
            }
          },
          connectorBuilder: (_, index, type) {
            if (index > 0) {
              if (index == _processIndex && !isComplete) {
                final prevColor = getColor(index - 1);
                final color = getColor(index);
                List<Color> gradientColors;
                if (type == ConnectorType.start) {
                  gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
                } else {
                  gradientColors = [
                    prevColor,
                    Color.lerp(prevColor, color, 0.5)!
                  ];
                }
                return DecoratedLineConnector(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                );
              } else {
                return SolidLineConnector(
                  color: getColor(index),
                );
              }
            } else {
              return null;
            }
          },
          itemCount: 3,
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: () async {
  //       if (!isComplete) {
  //         if (_processIndex < 3) {
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             content: Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 20),
  //                 child: Text(exitMessage[_processIndex])),
  //             action: SnackBarAction(
  //               label: "YES",
  //               onPressed: () {
  //                 platformCallback.invokeMethod(
  //                     "nativeCallback", {"status": "0", "data": data});
  //                 Navigator.pop(context);
  //               },
  //               textColor: Colors.white,
  //             ),
  //             backgroundColor: AppColors.primaryColor,
  //             duration: Duration(seconds: 3),
  //           ));
  //         } else {
  //           Navigator.pop(context);
  //         }
  //       }
  //       return false;
  //     },
  //     child: Scaffold(
  //       backgroundColor: Colors.white,
  //       body: SafeArea(
  //         child: Container(
  //           padding:
  //               EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 10.0),
  //                 child: Stack(
  //                   alignment: Alignment.centerLeft,
  //                   children: [
  //                     Align(
  //                       alignment: Alignment.center,
  //                       child: Text(
  //                         "Results",
  //                         style: Theme.of(context).textTheme.titleLarge,
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(flex: 5, child: getAssets(_processIndex)),
  //               SizedBox(
  //                 height: MediaQuery.of(context).size.width * 0.03,
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: MediaQuery.of(context).size.width * 0.1,
  //                 ),
  //                 child: Text(
  //                   isError
  //                       ? error[errorCode]
  //                       : isComplete
  //                           ? _processes[3]
  //                           : _processes[_processIndex],
  //                   textAlign: TextAlign.center,
  //                   style: Theme.of(context)
  //                       .textTheme
  //                       .titleLarge
  //                       ?.copyWith(color: AppColors.primaryColor),
  //                 ),
  //               ),
  //               Padding(
  //                   padding: EdgeInsets.symmetric(
  //                     horizontal: MediaQuery.of(context).size.width * 0.05,
  //                   ),
  //                   child: SizedBox(
  //                     height: MediaQuery.of(context).size.height * 0.1,
  //                     child: getTimeLine(),
  //                   )),
  //               Expanded(
  //                   flex: 2,
  //                   child: isComplete
  //                       ? Padding(
  //                           padding: EdgeInsets.only(
  //                               left: MediaQuery.of(context).size.width * 0.05,
  //                               right: MediaQuery.of(context).size.width * 0.05,
  //                               bottom: 10),
  //                           child: Column(
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceBetween,
  //                               crossAxisAlignment: CrossAxisAlignment.stretch,
  //                               children: [
  //                                 if (isError)
  //                                   Padding(
  //                                     padding:
  //                                         const EdgeInsets.only(bottom: 10.0),
  //                                     child: AutoSizeText.rich(
  //                                       TextSpan(
  //                                         text: errorDetails[errorCode],
  //                                         style: Theme.of(context)
  //                                             .textTheme
  //                                             .bodyMedium,
  //                                       ),
  //                                       textAlign: TextAlign.center,
  //                                     ),
  //                                   ),
  //                                 DarkButton(
  //                                   onPressed: () {
  //                                     if (!isError) {
  //                                       //Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  //                                       Navigator.of(context).pop();
  //                                       Navigator.of(context).pop();
  //                                       platformCallback.invokeMethod(
  //                                           "nativeCallback", {
  //                                         "status":
  //                                             data["status_code"].toString(),
  //                                         "data": data
  //                                       });
  //                                     } else {
  //                                       Navigator.of(context).pop();
  //                                       platformCallback.invokeMethod(
  //                                           "nativeCallback", {
  //                                         "status":
  //                                             data["status_code"].toString(),
  //                                         "data": data
  //                                       });
  //                                     }
  //                                   },
  //                                   child: DarkButtonText(
  //                                       isError ? "Try Again" : "Continue"),
  //                                 ),
  //                               ]))
  //                       : Padding(
  //                           padding: EdgeInsets.only(
  //                               left: MediaQuery.of(context).size.width * 0.05,
  //                               right: MediaQuery.of(context).size.width * 0.05,
  //                               bottom: 10.0),
  //                           child: RichText(
  //                             text: TextSpan(
  //                                 text: '',
  //                                 style: Theme.of(context).textTheme.labelLarge,
  //                                 children: <TextSpan>[
  //                                   TextSpan(
  //                                     text:
  //                                         'It might take some time to analyse your card. Please do not press the back button.\n',
  //                                     style:
  //                                         Theme.of(context).textTheme.bodyLarge,
  //                                   ),
  //                                 ]),
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         )),
  //               Container(
  //                 padding: EdgeInsets.symmetric(vertical: 10),
  //                 width: MediaQuery.of(context).size.width,
  //                 color: AppColors.white,
  //                 child: Text.rich(
  //                   TextSpan(
  //                     text: "Caution : ",
  //                     children: [
  //                       TextSpan(
  //                         text: "For Research Use Only",
  //                         style: Theme.of(context)
  //                             .textTheme
  //                             .bodySmall!
  //                             .copyWith(
  //                                 color: AppColors.primaryColor,
  //                                 fontStyle: FontStyle.italic),
  //                       ),
  //                     ],
  //                   ),
  //                   style: Theme.of(context).textTheme.bodySmall!.copyWith(
  //                       fontSize: 16,
  //                       color: AppColors.primaryColor,
  //                       fontStyle: FontStyle.italic,
  //                       fontWeight: FontWeight.w400),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget getTimeLine() {
  //   return Center(
  //     child: Timeline.tileBuilder(
  //       theme: TimelineThemeData(
  //         direction: Axis.horizontal,
  //         connectorTheme: ConnectorThemeData(
  //           space: 30.0,
  //           thickness: 5.0,
  //         ),
  //       ),
  //       builder: TimelineTileBuilder.connected(
  //         connectionDirection: ConnectionDirection.before,
  //         itemExtentBuilder: (_, __) =>
  //             MediaQuery.of(context).size.width * 0.9 / 3,
  //         indicatorBuilder: (_, index) {
  //           var color;
  //           var child;
  //           if (index == _processIndex && !isComplete) {
  //             color = inProgressColor;
  //             child = const Padding(
  //               padding: EdgeInsets.all(8.0),
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 3.0,
  //                 valueColor: AlwaysStoppedAnimation(Colors.white),
  //               ),
  //             );
  //           } else if (index < _processIndex || isComplete) {
  //             color = completeColor;
  //             child = Icon(
  //               isError ? Icons.cancel_outlined : Icons.check,
  //               color: Colors.white,
  //               size: 15.0,
  //             );
  //           } else {
  //             color = todoColor;
  //           }

  //           if (index <= _processIndex) {
  //             return Stack(
  //               children: [
  //                 CustomPaint(
  //                   size: Size(30.0, 30.0),
  //                   painter: _BezierPainter(
  //                     color: color,
  //                     drawStart: index > 0,
  //                     drawEnd: index < _processIndex,
  //                   ),
  //                 ),
  //                 DotIndicator(
  //                   size: 30.0,
  //                   color: color,
  //                   child: child,
  //                 ),
  //               ],
  //             );
  //           } else {
  //             return Stack(
  //               children: [
  //                 CustomPaint(
  //                   size: Size(15.0, 15.0),
  //                   painter: _BezierPainter(
  //                     color: color,
  //                     drawEnd: index < 2,
  //                   ),
  //                 ),
  //                 OutlinedDotIndicator(
  //                   borderWidth: 4.0,
  //                   color: color,
  //                 ),
  //               ],
  //             );
  //           }
  //         },
  //         connectorBuilder: (_, index, type) {
  //           if (index > 0) {
  //             if (index == _processIndex && !isComplete) {
  //               final prevColor = getColor(index - 1);
  //               final color = getColor(index);
  //               List<Color> gradientColors;
  //               if (type == ConnectorType.start) {
  //                 gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
  //               } else {
  //                 gradientColors = [
  //                   prevColor,
  //                   Color.lerp(prevColor, color, 0.5)!
  //                 ];
  //               }
  //               return DecoratedLineConnector(
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     colors: gradientColors,
  //                   ),
  //                 ),
  //               );
  //             } else {
  //               return SolidLineConnector(
  //                 color: getColor(index),
  //               );
  //             }
  //           } else {
  //             return null;
  //           }
  //         },
  //         itemCount: 3,
  //       ),
  //     ),
  //   );
  // }

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

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}

final _processes = [
  'Uploading image',
  'Analyzing card',
  'Preparing results',
  'Results processed successfully!',
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
