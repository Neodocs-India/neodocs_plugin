
import 'package:flutter/material.dart';
import 'package:neodocs_module/constants/app_colors.dart';


class DarkButton extends StatelessWidget{
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  const DarkButton({Key? key, required this.onPressed, required this.child, this.color = AppColors.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: child,
      color: color,
      highlightColor: Colors.white.withOpacity(0.5),
      splashColor: Colors.white.withOpacity(0.5),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onPressed: onPressed
    );
  }



}

class DarkButtonText extends StatelessWidget{
  final String text;
  final Color color;
  const DarkButtonText(this.text, {Key? key , this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 56,
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child:Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(color: Colors.white),
    ));
  }

}

class DarkButtonProgress extends StatelessWidget{
  final Color color;
  const DarkButtonProgress({Key? key , this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 56,
        width: 56,
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child:const Center(
            child: CircularProgressIndicator(
              value:
              null, // drawing of the circle does not depend on any value
              strokeWidth: 4.0,
              color: Colors.white, // line width
            )));
  }

}