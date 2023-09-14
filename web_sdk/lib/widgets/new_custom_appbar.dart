import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class MyAppBar extends StatelessWidget {
  final Function()? onPressed;
  final bool light;
  final double padding;
  final Widget? title;
  final Color? color;
  const MyAppBar(
      {Key? key,
      this.light = false,
      this.onPressed,
      this.padding = 0,
      this.title,
      this.color = Colors.transparent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: padding),
      alignment: Alignment.bottomCenter,
      child: AppBar(
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
        leading: light == false
            ? Padding(
                padding: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
                child: NewLightBackButton(
                  onPressed: onPressed,
                ),
              )
            : Padding(
                padding: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
                child: NewDarkBackButton(
                  onPressed: onPressed,
                ),
              ),
        title: title,
        centerTitle: true,
        elevation: 0,
        backgroundColor: color,
      ),
    );
  }
}

class NewDarkBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final EdgeInsets? margin;
  const NewDarkBackButton(
      {Key? key,
      this.onPressed,
      this.margin,
      this.color = const Color(0XFFF4F4F4)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      width: 20.w,
      margin: margin ?? EdgeInsets.zero,
      padding: EdgeInsets.only(left: 5.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: IconButton(
          padding: const EdgeInsets.all(8),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryColor,
          ),
          color: color,
          highlightColor: AppColors.primaryColor.withOpacity(0.5),
          splashColor: AppColors.primaryColor.withOpacity(0.5),
          visualDensity: VisualDensity.compact,
          onPressed: onPressed ??
              () {
                Navigator.of(context).pop();
              }),
    );
  }
}

class NewLightBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final EdgeInsets? margin;

  const NewLightBackButton({
    Key? key,
    this.onPressed,
    this.color = const Color(0xff000000),
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      width: 20.w,
      margin: margin ?? EdgeInsets.zero,
      padding: EdgeInsets.only(left: 5.w),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: IconButton(
          padding: const EdgeInsets.all(8),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          color: color,
          highlightColor: AppColors.primaryColor.withOpacity(0.5),
          splashColor: AppColors.primaryColor.withOpacity(0.5),
          visualDensity: VisualDensity.compact,
          onPressed: onPressed ??
              () {
                Navigator.of(context).pop();
              }),
    );
  }
}
