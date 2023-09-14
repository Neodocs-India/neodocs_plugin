import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_font_family.dart';

class NewElevatedButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final EdgeInsets? margin;
  final bool isSaving;

  const NewElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.margin,
    this.isSaving = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      margin: margin ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              const Color(0XFF6B60F1),
              const Color(0XFF6B60F1).withOpacity(0.52),
            ],
          )),
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        child: isSaving
            ? const CircularProgressIndicator()
            : Text(
                text,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFontFamily.manrope,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 8.h),
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
