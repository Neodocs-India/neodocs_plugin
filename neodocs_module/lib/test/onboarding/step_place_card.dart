import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_font_family.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';

class StepPlaceCard extends StatefulWidget {
  final PageController controller;
  const StepPlaceCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<StepPlaceCard> createState() => _StepPlaceCardState();
}

class _StepPlaceCardState extends State<StepPlaceCard>
    with TickerProviderStateMixin {
  final FocusNode _focusNodeName = FocusNode();

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
                            "3",
                            style: TextStyle(
                                color: const Color(0XFF7179C5),
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFontFamily.manrope),
                          ),
                          SizedBox(
                            width: size.width * 0.029,
                          ),
                          Flexible(
                              child: AutoSizeText(
                            "Now, place the test card on the control pad, & start the timer.",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ))
                        ],
                      ),
                    ),
                    Expanded(child: getAssets())
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.h, right: 20.w, left: 20.w),
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
                          text: "Make sure that the test card is ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text:
                              "properly aligned in accordance to the central area ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text: "of the control pad. ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
                NewElevatedButton(
                    onPressed: () => widget.controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn),
                    text: "Card Placed"),
                SizedBox(
                  height: 8.h,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getAssets() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(
          "assets/lottie/3_place_strip_on_pad.json",
          controller: animationController,
          repeat: true,
          onLoaded: (composition) async {
            // Configure the AnimationController with the duration of the
            // Lottie file and start the animation.
            await Future.delayed(const Duration(milliseconds: 200));
            animationController
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }
}
