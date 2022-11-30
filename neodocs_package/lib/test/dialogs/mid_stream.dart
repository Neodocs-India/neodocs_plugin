import 'package:flutter/material.dart';

import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';
import '../../widgets/new_elevated_button.dart';

class NewMidStreamDialog extends StatefulWidget {
  final VoidCallback? onPressed;
  const NewMidStreamDialog({Key? key, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MidStreamState();
  }
}

class _MidStreamState extends State<NewMidStreamDialog> {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close),
                ),
              ),
              Text(
                "🤔 What’s mid-stream urine?",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "A mid-stream urine sample means you don't collect the first or last part of urine that comes out",
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "This reduces the risk of the sample being contaminated with bacteria from: ",
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(
                height: 8,
              ),
              NewBulletText(
                style: Theme.of(context).primaryTextTheme.titleLarge,
                child: Text(
                  "your hands",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              NewBulletText(
                style: Theme.of(context).primaryTextTheme.titleLarge,
                child: Text(
                  "the skin around the urethra— the tube that carries urine out of the body.",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              NewElevatedButton(
                text: "Got it",
                onPressed: widget.onPressed ?? () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
