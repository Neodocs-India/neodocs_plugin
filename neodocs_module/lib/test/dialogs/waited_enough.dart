import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_font_family.dart';
import '../../constants/custom_decorations.dart';
import '../../widgets/new_bullet_text.dart';

class NewWaitedEnoughDialog extends StatefulWidget {
  final VoidCallback? onPressed;
  const NewWaitedEnoughDialog({Key? key, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MidStreamState();
  }
}

class _MidStreamState extends State<NewWaitedEnoughDialog> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ),
              Text(
                "Are you sure?",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(
                height: 8,
              ),
              NewBulletText(
                style: Theme.of(context).primaryTextTheme.titleLarge,
                child: Text(
                  "Proceed with this option only if you’re sure 60 seconds have passed since you withdrew the card from the sample.",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              NewBulletText(
                style: Theme.of(context).primaryTextTheme.titleLarge,
                child: Text(
                  "Scanning the card before a duration of 60 seconds may lead to inaccurate results.",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onPressed!();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Yes , I have waited enough",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFontFamily.manrope,
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.05),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    minimumSize: const Size(double.infinity, 40),
                    side: const BorderSide(color: Color(0XFF6B60F1), width: 1),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
