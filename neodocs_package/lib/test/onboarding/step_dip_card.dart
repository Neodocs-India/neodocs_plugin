import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_font_family.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';

class StepDipCard extends StatefulWidget {
  final PageController controller;

  const StepDipCard({Key? key, required this.controller}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepDipCardState();
}

class _StepDipCardState extends State<StepDipCard>
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
                            "2",
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
                            "Immerse the card into the urine sample for 2 seconds, then remove.",
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
                          text:
                              "When immersing the card into the sample, make sure ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  height: 1.2),
                        ),
                        TextSpan(
                          text: "the black area is dipped completely.",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  height: 1.2),
                        )
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
                          text: "After removing the card from the sample,",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text: " tap or shake the card gently ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text: " in order to remove excess droplets. ",
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
                    text: "Card dipped and shaken"),
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
          "packages/neodocs_package/assets/lottie/2_dip_strip_in_cup.json",
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
}
