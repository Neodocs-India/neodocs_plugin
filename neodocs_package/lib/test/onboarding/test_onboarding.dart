import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import '../../constants/app_colors.dart';
import '../../widgets/light_back_button.dart';
import 'step_collect_urine.dart';
import 'step_dip_card.dart';
import 'step_introduction.dart';
import 'step_place_card.dart';
import 'step_pouch.dart';
import 'step_start_timer.dart';

class TestOnBoarding extends StatefulWidget {
  final Map user;

  const TestOnBoarding({Key? key, required this.user}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<TestOnBoarding> {
  int _page = 0;
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
        user : widget.user,
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
