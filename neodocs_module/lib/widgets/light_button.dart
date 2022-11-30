import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class LightButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const LightButton({Key? key, required this.onPressed, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialButton(
        child: child,
        color: Colors.white,
        highlightColor: AppColors.primaryColor.withOpacity(0.5),
        splashColor: AppColors.primaryColor.withOpacity(0.5),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onPressed: onPressed);
  }
}

class LightButtonText extends StatelessWidget {
  final String text;
  final Color? color;
  const LightButtonText(this.text, {Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 64,
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: AutoSizeText(
          text,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: color ?? AppColors.primaryColor),
        ));
  }
}

class LightButtonProgress extends StatelessWidget {
  final Color color;
  const LightButtonProgress({Key? key, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 64,
        width: 64,
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Center(
            child: CircularProgressIndicator(
          value: null, // drawing of the circle does not depend on any value
          strokeWidth: 4.0,
          color: AppColors.primaryColor, // line width
        )));
  }
}
