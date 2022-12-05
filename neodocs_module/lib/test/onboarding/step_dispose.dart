import 'dart:developer';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/custom_decorations.dart';
import '../../widgets/new_elevated_button.dart';
import 'report_page.dart';

class DisposeStep extends StatefulWidget {
  final Map<String, dynamic> test;
  const DisposeStep({
    Key? key,
    required this.test,
  }) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<DisposeStep> with TickerProviderStateMixin {
  late List<String> _steps;

  late AnimationController animationController;

  @override
  void initState() {
    debugPrint("Data:");
    widget.test.forEach(
      (key, value) => debugPrint("$key:$value"),
    );
    animationController = AnimationController(vsync: this);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        log("Lottie Completed");
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _steps = [
      "Empty urine from cup into the toilet.",
      "Put used test card back inside the silver pouch.",
      "Throw the urine cup and the pouch in the garbage bin."
    ];
    return Scaffold(
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
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.075.sh),
                      child: Text(
                        "How to dispose?",
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              )),
          Expanded(
            child: Container(
              decoration: AppDesign(context).bodyDecoration,
              child: Container(
                transform: Matrix4.translationValues(0.0, -60, 0.0),
                padding: EdgeInsets.only(top: 16),
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
                                  text:
                                      "3 simple steps to dispose off the kit items",
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
                              ]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: getAssets(size),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.058),
                      child: Column(
                        children: [
                          getStep(0),
                          getStep(1),
                          getStep(2),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.05,
                                right: MediaQuery.of(context).size.width * 0.05,
                                bottom: 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.048),
                                    child: NewElevatedButton(
                                      onPressed: () {
                                        // Navigator.pushNamedAndRemoveUntil(
                                        //     context, '/', (_) => false);
                                        // SystemNavigator.pop();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) => ReportPage(
                                                    data: widget.test)));
                                      },
                                      text: "Done",
                                      margin: EdgeInsets.zero,
                                    ),
                                  ),
                                ]))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStep(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .secondary, //Theme.of(context).textTheme.black87,
              radius: 15,
              child: Text(
                (step + 1).toString(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              )),
        ),
        Flexible(
          child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 12, right: 5),
              child: RichText(
                text: TextSpan(
                    text: '',
                    style: Theme.of(context).textTheme.titleSmall,
                    children: <TextSpan>[
                      TextSpan(
                        text: _steps[step],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ]),
                textAlign: TextAlign.justify,
              )),
        )
      ],
    );
  }

  Widget getAssets(size) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(
          "assets/lottie/dispose.json",
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
