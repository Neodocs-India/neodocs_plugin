import 'package:flutter/material.dart';

import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';

class StartTimerDialog extends StatefulWidget {
  const StartTimerDialog({Key? key, required this.onStarted}) : super(key: key);
  final VoidCallback onStarted;
  @override
  State<StatefulWidget> createState() {
    return _MidStreamState();
  }
}

class _MidStreamState extends State<StartTimerDialog> {
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
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Note",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                "Tapping the “Start Timer” button will start the timer.\n",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.justify,
              ),
              Container(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: BulletText(
                  child: Text(
                    "You should only tap this once you’ve dipped the card in the sample, shaken it, and placed it on the control pad.",
                    //⚈
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              Container(
                height: 30,
              ),
              DarkButton(
                child: const DarkButtonText("Okay"),
                onPressed: () {
                  widget.onStarted();
                  Navigator.pop(context);
                },
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
}
