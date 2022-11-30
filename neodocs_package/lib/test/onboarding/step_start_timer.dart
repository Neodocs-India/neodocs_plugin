import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_timer/simple_timer.dart';
import '../../constants/app_font_family.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';
import '../camera/capture_screen.dart';
import '../dialogs/start_timer.dart';
import '../dialogs/waited_enough.dart';

class StepStartTimer extends StatefulWidget {
  final PageController controller;
  final Map user;
  final bool skipped;

  const StepStartTimer({
    Key? key,
    required this.controller,
    required this.user,
    required this.skipped,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepStartTimerState();
}

class _StepStartTimerState extends State<StepStartTimer>
    with TickerProviderStateMixin {
  late TimerController _timerController;

  bool _isStarted = false;

  String timeLeft = "60";

  bool isComplete = false;

  late DateTime _startTime;
  @override
  void initState() {
    super.initState();
    _timerController = TimerController(this);
    if (!widget.skipped) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
            const Duration(milliseconds: 100),
            () => _startTimer(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            width: double.infinity,
            decoration: AppDesign(context).headerDecoration,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 65.h,
                  ),
                  SizedBox(
                    height: 65.h,
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: isComplete
                          ? AutoSizeText(
                              "Your card has activated!",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                              textAlign: TextAlign.center,
                            )
                          : Row(
                              children: [
                                Text(
                                  "4",
                                  style: TextStyle(
                                      color: const Color(0XFF7179C5),
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppFontFamily.manrope),
                                ),
                                SizedBox(
                                  width: size.width * 0.029,
                                ),
                                Flexible(
                                  child: AutoSizeText(
                                    _isStarted
                                        ? "Scan the card immediately after the timer ends."
                                        : "Activation begins as soon as you immerse the card in the sample.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                              child: Center(
                                child: SizedBox(
                                  width: 212.w,
                                  child: SimpleTimer(
                                    duration: const Duration(seconds: 60),
                                    controller: _timerController,
                                    onStart: () {},
                                    onEnd: () {
                                      setState(() {
                                        isComplete = true;
                                      });
                                    },
                                    valueListener: (duration) {
                                      setState(() {
                                        timeLeft = "${59 - duration.inSeconds}";
                                      });
                                    },
                                    backgroundColor:
                                        Colors.white.withOpacity(0.1),
                                    progressIndicatorColor: Colors.white,
                                    displayProgressText: false,
                                    strokeWidth: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Center(
                                child: isComplete
                                    ? Container(
                                        width: 0.2.sw,
                                        height: 0.2.sw,
                                        padding:
                                            EdgeInsets.only(bottom: 0.01.sh),
                                        child: const Image(
                                          fit: BoxFit.scaleDown,
                                          image: ExactAssetImage(
                                              "packages/neodocs_package/assets/icon/ic_white_tick.png"),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 0.01.sh),
                                        child: Text.rich(
                                          TextSpan(
                                              text: timeLeft,
                                              style: TextStyle(
                                                  fontSize: 40.sp,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily:
                                                      AppFontFamily.manrope,
                                                  color: Colors.white),
                                              children: [
                                                TextSpan(
                                                  text: "\nseconds",
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily:
                                                          AppFontFamily.manrope,
                                                      color: Colors.white),
                                                )
                                              ]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 24.h,
                        ),
                        Text(
                          getProcessMessage(),
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFontFamily.manrope,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 20.h),
          decoration: AppDesign(context).bodyDecoration,
          child: isComplete
              ? Column(
                  children: [
                    NewBulletText(
                      style: Theme.of(context).primaryTextTheme.titleLarge,
                      child: Text.rich(
                        TextSpan(
                          text:
                              "Please scan the card immediately in order to receive results with maximum accuracy.",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ),
                    NewElevatedButton(
                      onPressed: () => _startCapture(),
                      text: "Scan my card",
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                  ],
                )
              : _isStarted
                  ? Column(
                      children: [
                        NewBulletText(
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(height: 1.2),
                          child: Text.rich(
                            TextSpan(
                              text:
                                  "If you were unable to start the timer within a few seconds of withdrawing the card, click on the “I have waited enough” button below to ensure that the card is scanned during the window period of 60-90 seconds post-dipping.",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      height: 1.2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10.h), // NewElevatedButton has margin
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: TextButton(
                            onPressed: _showWaitedEnoughDialog,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white.withOpacity(0.05),
                              backgroundColor: Colors.white.withOpacity(0.05),
                              minimumSize: Size(double.infinity, 40.h),
                              side: const BorderSide(
                                  color: Color(0XFF6B60F1), width: 1),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                "I have waited enough",
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
                        SizedBox(
                          height: 16.h,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NewBulletText(
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(height: 1.2),
                          child: Text.rich(
                            TextSpan(
                              text: "",
                              children: [
                                TextSpan(
                                  text:
                                      "The 60 second timer will aid in scanning the card in the right time range (i.e ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                TextSpan(
                                  text: "between 60-90 seconds after dipping ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                TextSpan(
                                  text: ") for the highest accuracy. ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        NewBulletText(
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(height: 1.2),
                          child: Text.rich(
                            TextSpan(
                              text: "",
                              children: [
                                TextSpan(
                                  text: "This takes into account a ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                TextSpan(
                                  text: "seconds long gap ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                TextSpan(
                                  text: "between ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                TextSpan(
                                  text:
                                      "dipping the card & starting the timer. ",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                          height: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        NewElevatedButton(
                            margin: EdgeInsets.all(24.w),
                            onPressed: () => _showTimerDialog(),
                            text: "Start Timer"),
                        SizedBox(
                          height: 8.h,
                        ),
                      ],
                    ),
        ),
      ]),
    );
  }

  String getProcessMessage() {
    final time = int.parse(timeLeft);
    if (time == 60) {
      return "";
    } else if (time > 50) {
      return "Please wait for timer";
    } else if (time > 30) {
      return "Absorbing sample";
    } else if (time > 10) {
      return "Chemical reaction in process";
    } else {
      return "Color assay activated";
    }
  }

  void _showTimerDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return NewStartTimerDialog(onPressed: _startTimer);
        });
  }

  void _showWaitedEnoughDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return NewWaitedEnoughDialog(onPressed: _startCapture);
        });
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _timerController.start();
    setState(() {
      _isStarted = true;
    });
  }

  _startCapture() async {
    List<CameraDescription> cameras = await availableCameras();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CaptureScreen(
              cameras: cameras,
              startTime: _startTime,
              user: widget.user,
            ),
        settings: const RouteSettings(name: "CaptureScreen")));
  }
}
