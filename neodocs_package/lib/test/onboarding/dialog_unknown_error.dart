import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/dark_button.dart';

class UnknownErrorDialog extends StatefulWidget {
  const UnknownErrorDialog({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<UnknownErrorDialog> {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 10,
              ),
               Center(
                 child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    child:  const Image(
                        fit: BoxFit.fitWidth,
                        image: ExactAssetImage("packages/neodocs_package/assets/images/img_unknown_error.png")),
                  ),
               ),
              Container(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("Oops!",style:  Theme.of(context).textTheme.titleLarge,),
              ),
              Container(
                height: 20,
              ),
               Text(
                  "Something went wrong. Please try again in some time.\n",
                  style:  Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              Container(
                height: 20,
              ),
              DarkButton(
                child: const DarkButtonText("Okay"),
                onPressed: ()=> Navigator.pop(context),
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAssets() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(
          "packages/neodocs_package/assets/lottie/unknown_error.json",
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
}
