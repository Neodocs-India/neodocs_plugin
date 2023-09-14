import 'package:flutter/material.dart';

class BulletText extends StatelessWidget{
  final Widget child;
  final TextStyle? style;
  const BulletText({Key? key,  required this.child, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("\u2022",style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 30)),
        Flexible(
          child: Padding(padding: const EdgeInsets.only(left: 10,top: 5),
          child: child,),
        )
      ],
    );
  }
//⚈


}