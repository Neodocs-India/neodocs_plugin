import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constants/custom_decorations.dart';
import '../../widgets/new_elevated_button.dart';

class StepIntroduction extends StatefulWidget {
  final PageController controller;
  final Function(bool) onSkipped;

  const StepIntroduction({
    Key? key,
    required this.controller,
    required this.onSkipped,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepIntroductionState();
}

class _StepIntroductionState extends State<StepIntroduction> {
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'ZPhzIoAGw0A',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
        loop: true,
      ),
    );
    super.initState();
  }

  final bool _isPlayerReady = false;

  @override
  void dispose() {
    //_controller.stopVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: AppDesign(context).headerDecoration,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 65.h,
                ),
                SizedBox(
                  height: 85.h,
                  child: Center(
                    child: AutoSizeText(
                      "Unlock all-round wellness in 4 simple steps",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                          ),
                      maxLines: 3,
                    ),
                  ),
                ),
                SizedBox(
                  height: 85.h,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: AppDesign(context).bodyDecoration,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.bottomRight,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 52.h,
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          'Before we get to the test, there are a few minor steps that need your attention.',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .labelMedium!
                              .copyWith(
                                  fontSize: 20.sp,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                          textAlign: TextAlign.left,
                          maxLines: 3,
                          minFontSize: 1,
                        ),
                      ),
                      const Spacer(),
                      ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          NewElevatedButton(
                              margin: EdgeInsets.symmetric(horizontal: 24.w),
                              onPressed: () {
                                widget.onSkipped(false);
                                widget.controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                              },
                              text: "Step-by-Step Guide"),
                          SizedBox(
                            height: 8.h,
                          ),
                          Center(
                            child: Text(
                              "OR",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: Colors.black,
                              child: /*YoutubeValueBuilder(
                                controller: _controller, // This can be omitted, if using `YoutubePlayerControllerProvider`
                                builder: (context, value) {
                                  return IconButton(
                                    icon: Icon(
                                      value.playerState == PlayerState.playing
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: (value.playerState == PlayerState.paused || value.playerState == PlayerState.playing)
                                        ? () {
                                      value.playerState == PlayerState.playing
                                          ? _controller.pauseVideo()
                                          : _controller.playVideo();
                                    }
                                        : null,
                                  );
                                },
                              ),*/
                                  YoutubePlayer(
                                controller: _controller,

                                /*progressColors: const ProgressBarColors(
                                  playedColor: Colors.amber,
                                  handleColor: Colors.amberAccent,
                                ),*/
                                //onReady: () {},
                                /*bottomActions: [
                                  SizedBox(width: 14.0.w),
                                  CurrentPosition(),
                                  SizedBox(width: 8.0.w),
                                  ProgressBar(
                                      isExpanded: true,
                                      colors: ProgressBarColors(
                                          backgroundColor: Theme.of(context)
                                              .bottomAppBarColor,
                                          bufferedColor:
                                              Colors.white.withOpacity(0.2),
                                          handleColor: const Color(0XFFFCAE69),
                                          playedColor: Color(0XFFFCAE69))),
                                  SizedBox(width: 8.0.w),
                                  RemainingDuration(),
                                  SizedBox(width: 14.0.w),
                                ],*/
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          MaterialButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              widget.onSkipped(true);
                              widget.controller.animateToPage(5,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.fastLinearToSlowEaseIn);
                            },
                            child: const Text(
                              'I know how to take the test',
                              style: TextStyle(
                                  color: Color(0XFF606060),
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        transform: Matrix4.translationValues(0.0, -52, 0.0),
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: EdgeInsets.all(20.sp),
                              decoration: AppDesign(context).statusDecoration,
                              child: SizedBox(
                                height: 70.h,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: AutoSizeText.rich(
                                          TextSpan(text: "", children: [
                                        TextSpan(
                                          text: "Do not open ",
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
                                            text:
                                                "the pouch containing test card unless instructed.",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .titleLarge!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary))
                                      ])),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Container(
                                      height: 60.h,
                                      width: 60.w,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(4),
                                      child: const Text(
                                        '!',
                                        style: TextStyle(
                                            color: Color(0XFFFCAE69),
                                            fontSize: 30),
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0XFFFCAE69),
                                            width: 2),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
