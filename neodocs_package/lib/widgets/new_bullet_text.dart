import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewBulletText extends StatelessWidget {
  final Widget child;
  final TextStyle? style;
  const NewBulletText({Key? key, required this.child, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 8.w, left: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\u2022",
              style: style!
                  .copyWith(color: Theme.of(context).colorScheme.secondary)),
          SizedBox(
            width: 8.w,
          ),
          Flexible(
            child: child,
          )
        ],
      ),
    );
  }
//⚈

}
