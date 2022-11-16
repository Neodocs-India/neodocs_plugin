import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class Toast {
  final BuildContext context;
  final Color backgroundColor;
  final TextStyle? textStyle;

  Toast(this.context, {this.textStyle, this.backgroundColor = Colors.black54});

  void showToast(text) {
    BotToast.showText(text: text, contentColor: backgroundColor);
  }

  void showToastDialog(text) {
    BotToast.showText(
        duration: const Duration(seconds: 3),
        align: const Alignment(0, 0),
        contentPadding: const EdgeInsets.all(20),
        textStyle: textStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.white),
        text: text,
        contentColor: AppColors.primaryColor);
  }

  void showToastCamera(text) {
    BotToast.showText(
        text: text,
        align: const Alignment(0, -0.75),
        duration: const Duration(seconds: 3),
        contentPadding: const EdgeInsets.all(10),
        textStyle: textStyle ?? Theme.of(context).textTheme.bodyMedium!,
        contentColor: Colors.white);
  }
}
