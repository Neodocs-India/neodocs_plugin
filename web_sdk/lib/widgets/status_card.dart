import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web_sdk/widgets/report_pdf_view.dart';

import '../../constants/custom_decorations.dart';

class StatusCard extends StatelessWidget {
  final Map<String, dynamic> results;
  final AnimationController animationController;
  final bool isBiomarker;
  late DateTime time;
  StatusCard({
    Key? key,
    required this.results,
    required this.animationController,
    required this.isBiomarker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cardType = mapCardType(results['kit_type']);
    if (isBiomarker) {
      time = DateTime.parse(results["date_of_test"]);
    } else {
      time = DateTime.parse(results['panels'][cardType]['details']
          ['biomarker_details'][0]["date_of_test"]);
    }
    animationController.forward();
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget? child) {
          return Container(
            margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.0230, vertical: 4),
            child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.1, end: 1)
                        .animate(animationController),
                    child: Container(
                        width: 0.9.sw,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.height * 0.018,
                            vertical: size.height * 0.018),
                        decoration: AppDesign(context).statusDecoration,
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        'TEST TAKEN',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: const Color(0xff8991E1),
                                            ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      AutoSizeText(
                                        time.format("EEEE"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiaryContainer),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      AutoSizeText(
                                        time.format("dd MMMM yyyy"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiaryContainer),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        "RESULTS STATUS",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: const Color(0xff8991E1),
                                            ),
                                        maxLines: 1,
                                      ),
                                      results["is_reviewed_"] ??
                                              true //default verified
                                          ? Text.rich(
                                              TextSpan(
                                                  text: "Verified",
                                                  children: [
                                                    const TextSpan(text: " "),
                                                    WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: SizedBox(
                                                            height: 14.sp,
                                                            width: 14.sp,
                                                            child: SvgPicture.asset(
                                                                "assets/icon/ic_verified.svg", //changed to .svg
                                                                height: 14.sp,
                                                                color: const Color(
                                                                    0XFF2CBEA6))))
                                                  ]),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryContainer),
                                              textAlign: TextAlign.right,
                                            )
                                          : Text.rich(
                                              TextSpan(
                                                  text: "In Review",
                                                  children: [
                                                    WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: SizedBox(
                                                          height: size.height *
                                                              0.0346,
                                                          width: size.height *
                                                              0.0346,
                                                          child: Image.asset(
                                                              "assets/icon/ic_preview.png"),
                                                        ))
                                                  ]),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: const Color(
                                                          0xffB6B6B6)),
                                              textAlign: TextAlign.right,
                                            ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
                  ),
                )),
          );
        });
  }

  mapCardType(type) {
    switch (type) {
      case "WEL":
        return "wellness";
      case "UTI":
        return "uti";
      case "CKD":
        return "ckd";
      case "PRG":
        return "pregnancy";
      case "ELD":
        return "elderly";
      default:
        return "wellness";
    }
  }
}
