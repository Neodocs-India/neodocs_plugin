import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';
import 'midstreem_dialog.dart';

class StepIntroduction extends StatefulWidget {
  final PageController controller;


  StepIntroduction(
      {Key? key, required this.controller})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepState();
}

class _StepState extends State<StepIntroduction> {
  final FocusNode _focusNodeName = FocusNode();

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

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
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Text("Take control of your health in 4 simple steps!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),),
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
                            TextSpan(text: 'Before you take the test, there’s a few steps where you need to be careful.' ,
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
                            TextSpan(text: 'We’ll guide you through each and every step, so that you don’t miss any crucial details of the test.' ,
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
                            TextSpan(text:  "Please do not open the pouch containing wellness card unless instructed.\n",style: Theme.of(context).textTheme.bodyLarge),
                          ]

                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),

                  SizedBox(height: 5,),

                  DarkButton(
                      onPressed: ()=> _showDialog(),
                      child: const DarkButtonText("Continue")),
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
        margin: EdgeInsets.symmetric(vertical: 30),
        child:  const Image(
            fit: BoxFit.fitHeight,
            image: ExactAssetImage("assets/images/img_steps.png")),
      ),
    );
  }
  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return  MidStreamDialog(
            onPressed: (){
              widget.controller.animateToPage(1,duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              //widget.controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              Navigator.of(context).pop();
            },
          );
        });
  }

}
