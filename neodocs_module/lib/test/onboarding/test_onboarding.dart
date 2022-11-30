import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neodocs_module/test/onboarding/step_collect_urine.dart';
import 'package:neodocs_module/test/onboarding/step_dip_card.dart';
import 'package:neodocs_module/test/onboarding/step_introduction.dart';
import 'package:neodocs_module/test/onboarding/step_place_card.dart';
import 'package:neodocs_module/test/onboarding/step_pouch.dart';
import 'package:neodocs_module/test/onboarding/step_start_timer.dart';
import 'package:neodocs_module/widgets/new_custom_appbar.dart';

import '../../constants/app_colors.dart';

class TestOnBoarding extends StatefulWidget {
  final String? userId;

  const TestOnBoarding({Key? key, required this.userId}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<TestOnBoarding> {
  int _page = 0;
  bool skipped = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_)=> Future.delayed(const Duration(seconds: 2),()=> setState(() {})));
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
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              children: _buildPages(),
              controller: _pageController,
              onPageChanged: _onPageViewChange,
            ),
            if (_page == 0)
              StepIntroduction(
                controller: _pageController,
                onSkipped: (skip) {
                  setState(() {
                    skipped = skip;
                  });
                },
              ),
            Positioned(
              left: 20,
              top: 10,
              child: MyAppBar(
                onPressed: () {
                  if (_page == 0) {
                    SystemNavigator.pop();
                  } else if (skipped) {
                    _pageController.jumpToPage(0);
                  } else {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  }
                },
              ),
            ),
          ],
        ),
      )),
    );
  }

  List<Widget> _buildPages() {
    return [
      Container(),
      StepCollectUrine(
        controller: _pageController,
      ),
      StepPouch(
        controller: _pageController,
      ),
      StepDipCard(
        controller: _pageController,
      ),
      StepPlaceCard(
        controller: _pageController,
      ),
      StepStartTimer(
        controller: _pageController,
        skipped: skipped,
      ),
    ];
  }

  Future<bool> onWillPop(BuildContext context) async {
    return true;
  }

  _onPageViewChange(int value) {
    setState(() {
      _page = value;
    });
  }
}
