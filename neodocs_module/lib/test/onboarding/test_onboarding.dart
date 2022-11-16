import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neodocs_module/test/onboarding/step_collect_urine.dart';
import 'package:neodocs_module/test/onboarding/step_dip_card.dart';
import 'package:neodocs_module/test/onboarding/step_introduction.dart';
import 'package:neodocs_module/test/onboarding/step_place_card.dart';
import 'package:neodocs_module/test/onboarding/step_pouch.dart';
import 'package:neodocs_module/test/onboarding/step_start_timer.dart';
import 'package:wakelock/wakelock.dart';

import '../../constants/app_colors.dart';
import '../../widgets/light_back_button.dart';

class TestOnBoarding extends StatefulWidget {
  final String? userId;

  const TestOnBoarding({Key? key, required this.userId}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<TestOnBoarding> {
  int _page = 0;
  final PageController _pageController = PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) =>
        Future.delayed(const Duration(seconds: 1), () => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
          child: WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            PageView.builder(
              itemBuilder: (context, position) {
                return _buildPages(position);
              },
              allowImplicitScrolling: true,
              controller: _pageController,
              onPageChanged: _onPageViewChange,
              itemCount: 6,
            ),
            Positioned(
                left: 20,
                top: 10,
                child: LightBackButton(
                  onPressed: () {
                    if (_page == 0) {
                      SystemNavigator.pop();
                    } else {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                )),
          ],
        ),
      )),
    );
  }

  Widget _buildPages(int position) {
    switch (position) {
      case 0:
        return StepIntroduction(
          controller: _pageController,
        );
      case 1:
        return StepCollectUrine(
          controller: _pageController,
        );
      case 2:
        return StepPouch(
          controller: _pageController,
        );
      case 3:
        return StepDipCard(
          controller: _pageController,
        );
      case 4:
        return StepPlaceCard(
          controller: _pageController,
        );
      case 5:
        return StepStartTimer(
          controller: _pageController,
        );
      default:
        return StepIntroduction(
          controller: _pageController,
        );
    }
  }

  Future<bool> onWillPop(BuildContext context) async {
    if (_page == 0) {
      SystemNavigator.pop();
    } else {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    return false;
  }

  _onPageViewChange(int value) {
    setState(() {
      _page = value;
    });
  }
}
