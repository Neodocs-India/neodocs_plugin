import 'package:flutter/material.dart';

import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';

class NewStartTimerDialog extends StatefulWidget {
  final VoidCallback? onPressed;
  const NewStartTimerDialog({Key? key, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MidStreamState();
  }
}

class _MidStreamState extends State<NewStartTimerDialog> {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 0,
      child: Container(
        decoration: AppDesign(context)
            .bodyDecoration
            .copyWith(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.only(top: 16, right: 24, left: 24),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close),
                ),
              ),
              Text(
                "Note",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(
                height: 8,
              ),
              NewBulletText(
                style: Theme.of(context).primaryTextTheme.titleLarge,
                child: Text(
                  "Tap the “Start” button to begin the timer. ",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              NewBulletText(
                style: Theme.of(context).primaryTextTheme.titleLarge,
                child: Text(
                  "Make sure you begin the timer only after the test card has been dipped, slightly shaken, & placed on the control pad.",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              NewElevatedButton(
                text: "Got it",
                onPressed: () {
                  widget.onPressed!();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
