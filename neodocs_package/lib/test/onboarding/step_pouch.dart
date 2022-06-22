import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';
class StepPouch extends StatefulWidget {
  final PageController controller;


  const StepPouch(
      {Key? key, required this.controller})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepState();
}

class _StepState extends State<StepPouch>  with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
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
                           /*CircleAvatar(
                            backgroundColor: Colors.white,//Theme.of(context).textTheme.black87,
                            radius: 20,
                            child: Text("2",style: Theme.of(context).textTheme.titleLarge,)
                            ),*/
                          const SizedBox(width: 20,),
                          Flexible(
                              child: Text("Open the sealed pouch that contains your wellness card",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),))
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
                                TextSpan(text: 'Your wellness card is moisture sensitive, opening it in advance might lead to contamination.\n' ,
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
                                TextSpan(text:  "It’s important you open it only after collecting sample in the cup.\n",style: Theme.of(context).textTheme.bodyLarge),
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
        margin: EdgeInsets.symmetric(vertical: 30),
        child:  const Image(
            fit: BoxFit.fitHeight,
            image: ExactAssetImage("packages/neodocs_package/assets/images/ic_pouch.png")),
      ),
    );
  }


}
