import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakelock/wakelock.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_custom_appbar.dart';
import '../widgets/biomarker_tile.dart';
import '../widgets/share_view.dart';
import '../widgets/status_card.dart';

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

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
    if (widget.data["kit_type"] == "CKD") {
      //widget.data["panels"]["details"]["biomarker_details"].remove("urine_ds_uricacid");
      widget.data["panels"].values.first["details"]["biomarker_details"] = "ACR";
      widget.data["panels"].values.first["details"]["biomarker_details"] = widget.data["panels"]["details"]["biomarker_details"]
          .toString()
          .replaceAll("<br>", "\n");
    }
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
        Navigator.of(context).pop();
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
                            const Spacer()
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
                      ShareView(data: widget.data),
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
    String cardType = mapCardType(widget.data['kit_type']);
    debugPrint(widget.data.toString());
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
    return "wellness";
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

//{uId=userId, processed_flag=true, firstName=firstName, lastName=lastName, status_code=200, gender=gender, captureTime=1682596196597, panels={uti={panel_id=uti, active_icon=ic_uti.png, hexcode=#FFC999, insights={hexcode=#FFC999, description=<p style="color:black">Your results suggest you might be at risk of UTI; however, blood in urine might appear due to other reasons too.</p>, title=<h2 style="color:black">You are likely to have a UTI</h2>}, description=lorem ipsum, index=4, biomarker_name=[urine_ds_leukocytes, urine_ds_nitrite, urine_ds_ph, urine_ds_blood], display_name=Urinary Tract Health, inactive_icon=https://saht.neodocs.in/assets/img/uti_inactive.png, score=60, science=[], risk=risk, details={biomarker_details=[{display_value=Negative, unit=Leu/μL, method=dipstick, user_value_flag_text=good, legend={high=> 15, low=NA, good=0-15}, user_value_flag=0, index=0, reference_range=Negative, ref_ranges={min_value=0, lb=0, lb_ideal=0, ub_ideal=15, ub=15, max_value=500}, display_name=Leukocytes, estimated_value=0, date_of_test=2023-04-27}, {display_value=Negative, unit=, method=dipstick, legend={high=> 0, low=NA, good=: 0}, user_value_flag_text=good, user_value_flag=0, index=9, reference_range=Negative, ref_ranges={min_value=0, lb=0, lb_ideal=0, ub_ideal=0, ub=0, max_value=1}, display_name=Nitrite, estimated_value=0, date_of_test=2023-04-27}, {display_value=6, unit=, method=dipstick, legend={high=> 8, low=< 5, good=5-8}, user_value_flag_text=good, user_value_flag=0, index=11, reference_range=5-8, ref_ranges={min_value=5, lb=5, lb_ideal=5, ub_ideal=8, ub=8, max_value=9}, display_name=pH, estimated_value=6, date_of_test=2023-04-27}, {display_value=200 (+++), unit=Ery/μL, method=dipstick, legend={high=> 0, low=NA, good=: 0}, user_value_flag_text=high, user_value_flag=1, index=12, reference_range=Negative, display_name=Blood, ref_ranges={min_value=0, lb=0, lb_ideal=0, ub_ideal=0, ub=0, max_value=200}, estimated_value=200, date_of_test=2023-04-27}]}, status=poor}}, testId=36271384-dcd7-4e2b-8890-ce32c164cc1f, dateOfBirth=2023-04-27T11:49:47.396000+00:00, isComplete=true}