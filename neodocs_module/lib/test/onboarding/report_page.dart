import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neodocs_module/test/onboarding/status_card.dart';
import 'package:neodocs_module/widgets/biomarker_tile.dart';
import 'package:wakelock/wakelock.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_custom_appbar.dart';
import '../../widgets/share_view.dart';

class ReportPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const ReportPage({Key? key, required this.data}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<ReportPage> with TickerProviderStateMixin {
  late AnimationController animationController;
  late String cardType;

  @override
  void initState() {
    cardType = mapCardType(widget.data['kit_type']);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      Wakelock.disable();
    });
    log("didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    animationController.forward();
    return WillPopScope(
      onWillPop: () {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: AppDesign(context).headerDecoration,
                padding: EdgeInsets.only(
                    left: 0.0389.sw,
                    right: 0.0389.sw,
                    bottom: 0.025.sh,
                    top: 0.0184.sh),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyAppBar(
                        title: Row(
                          children: [
                            Text("Test Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.white)),
                            Spacer()
                          ],
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (_) => false);
                          SystemNavigator.pop();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: SvgPicture.asset(
                              "assets/icon/ic_wellness.svg",
                              color: Colors.white,
                              height: 90.h,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "PATIENT DETAILS\n",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelMedium!
                                      .copyWith(
                                          height: 4, color: Colors.white)),
                              TextSpan(
                                  text:
                                      "${widget.data["firstName"]} ${widget.data["lastName"]}",
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineLarge!
                                      .copyWith(
                                          height: 1, color: Colors.white)),
                              TextSpan(
                                text:
                                    "\n${widget.data["gender"].toString().toUpperCase()}, ${getDOB(DateTime.parse(widget.data["dateOfBirth"]))} years",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium!
                                    .copyWith(
                                        height: 1.2,
                                        wordSpacing: 1,
                                        letterSpacing: 1,
                                        color: Colors.white),
                              )
                            ])),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 24.h,
                      ),
                      ShareView(
                        data: widget.data,
                        cardType: cardType,
                      ),
                      SizedBox(
                        height: 48.h,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: AppDesign(context).bodyDecoration,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Container(
                  transform: Matrix4.translationValues(0.0, -0.06.sh, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusCard(
                        cardType: cardType,
                        results: widget.data,
                        animationController: animationController,
                        isBiomarker: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 24),
                        child: Text(
                          "Panels",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      getBiomarkers(widget.data),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBiomarkers(data) {
    cardType = mapCardType(widget.data['kit_type']);
    debugPrint(cardType);
    List panelList = data["panels"][cardType]["details"]["biomarker_details"];
    debugPrint(panelList.toString());
    return MasonryGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      clipBehavior: Clip.none,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      itemCount: panelList.length,
      itemBuilder: (BuildContext context, int index) => BioMarkerTile(
        bioMarker: panelList[index],
        margin: index == 0 ? true : false,
      ),
    );
  }

  static int getDOB(DateTime initialDate) {
    DateTime endDate = DateTime.now();
    return ((endDate.year - initialDate.year) * 12 +
            (endDate.month - initialDate.month) +
            1) ~/
        12;
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
        return "Wellness";
    }
  }
}
