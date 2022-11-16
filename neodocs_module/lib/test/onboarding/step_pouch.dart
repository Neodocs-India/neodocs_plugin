import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';

class StepPouch extends StatefulWidget {
  final PageController controller;
  const StepPouch({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<StepPouch> createState() => _StepPouchState();
}

class _StepPouchState extends State<StepPouch> with TickerProviderStateMixin {
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: AutoSizeText(
                        "Open pouch seal, & retrieve your test card.",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                    ),
                    Expanded(child: getAssets())
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
            ),
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
                                "It is important you open the test card pouch only ",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    height: 1.2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                        TextSpan(
                          text: "after collecting your urine sample. ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text: "Since the card is moisture sensitive ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                        TextSpan(
                          text: "& at-risk of contamination. ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                NewElevatedButton(
                    onPressed: () => widget.controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn),
                    text: "Opened sealed pouch"),
                const SizedBox(
                  height: 8,
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
          "assets/lottie/open_the_pouch.json",
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
