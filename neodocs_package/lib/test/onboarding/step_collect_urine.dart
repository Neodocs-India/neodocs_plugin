import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_font_family.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';
import '../dialogs/mid_stream.dart';

class StepCollectUrine extends StatefulWidget {
  final PageController controller;

  const StepCollectUrine({Key? key, required this.controller})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepCollectUrineState();
}

class _StepCollectUrineState extends State<StepCollectUrine>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        log("Lottie Completed");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              decoration: AppDesign(context).headerDecoration,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: 65.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Text(
                            "1",
                            style: TextStyle(
                              color: const Color(0XFF7179C5),
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFontFamily.manrope,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.029,
                          ),
                          Flexible(
                            child: AutoSizeText(
                              "Collect your urine sample in the provided container.",
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
                    Expanded(child: getAssets(size))
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
            decoration: AppDesign(context).bodyDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NewBulletText(
                  style: Theme.of(context).primaryTextTheme.titleLarge,
                  child: Text.rich(
                    TextSpan(
                      text: "",
                      children: [
                        TextSpan(
                          text: "Urinate into the container",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                            text: " mid-stream*.",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _showDialog())
                      ],
                    ),
                  ),
                ),
                NewBulletText(
                  style: Theme.of(context).primaryTextTheme.titleLarge,
                  child: Text.rich(
                    TextSpan(
                      text: "",
                      children: [
                        TextSpan(
                          text: "Make sure the container is filled",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text: " till top.",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Text.rich(TextSpan(
                    text: "*What’s mid-stream urine?",
                    style: TextStyle(
                      color: const Color(0XFF6B60F1),
                      fontFamily: AppFontFamily.metropolis,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showDialog())),
                SizedBox(
                  height: 24.h,
                ),
                NewElevatedButton(
                    onPressed: _showDialog, text: "Urine Collected"),
                SizedBox(
                  height: 8.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getAssets(Size size) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(size.height * 0.0092),
        child: Lottie.asset(
          "packages/neodocs_package/assets/lottie/step_1.json",
          controller: animationController,
          repeat: true,
          onLoaded: (composition) async {
            await Future.delayed(const Duration(milliseconds: 200));
            animationController
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return NewMidStreamDialog(
            onPressed: () {
              widget.controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn);
              Navigator.of(context).pop();
            },
          );
        });
  }
}
