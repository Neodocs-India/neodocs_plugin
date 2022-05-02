import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';
import 'midstreem_dialog.dart';

class StepDipCard extends StatefulWidget {
  final PageController controller;


  const StepDipCard(
      {Key? key, required this.controller})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepState();
}

class _StepState extends State<StepDipCard>  with TickerProviderStateMixin {
  final FocusNode _focusNodeName = FocusNode();

  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    animationController.addStatusListener((status) {
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.topCenter,
        color: Colors.transparent,
        margin:  EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                           CircleAvatar(
                            backgroundColor: Colors.white,//Theme.of(context).textTheme.black87,
                            radius: 20,
                            child: Text("2",style: Theme.of(context).textTheme.titleLarge,)
                            ),
                          const SizedBox(width: 20,),
                          Flexible(child: Text("Dip the wellness card for 2 seconds and take it out",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),))
                        ],
                      ),
                      Expanded(child: getAssets())
                    ],
                  )

                )),
            Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white,),
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      BulletText(
                        child: RichText(
                          text:  TextSpan(text:'',
                              style: Theme.of(context).textTheme.labelLarge,
                              children: <TextSpan>[
                                TextSpan(text: 'Completely dip the black area of the card in the sample. After taking out, gently tap or shake the card to remove any droplets.\n' ,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ]

                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      BulletText(
                        child: RichText(
                          text:  TextSpan(text:'',
                              style: Theme.of(context).textTheme.labelLarge,
                              children: <TextSpan>[
                                TextSpan(text:  "Your card starts activating as soon as you dip it. You need to scan the card between 60-90 seconds of activation.",style: Theme.of(context).textTheme.bodyLarge),

                              ]

                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: 20,),

                      DarkButton(
                          onPressed: ()=>widget.controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn),
                          child: const DarkButtonText("Next")),

                    ],
                  ),

                )
          ],
        )
    );
  }

  Widget getAssets() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(
          "assets/lottie/2_dip_strip_in_cup.json",
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
  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return const MidStreamDialog();
        });
  }

}
