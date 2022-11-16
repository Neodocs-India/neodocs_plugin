import 'package:flutter/material.dart';

import 'dark_back_button.dart';
import 'light_back_button.dart';

customAppBar(
    {bool lightButton = true,
    Function()? onPressed,
    double padding = 0,
    Widget? title,
    Color color = Colors.transparent}) {
  return Container(
    width: double.maxFinite,
    padding: EdgeInsets.only(left: padding),
    alignment: Alignment.bottomCenter,
    child: AppBar(
      leading: lightButton
          ? Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: LightBackButton(
                onPressed: onPressed,
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: DarkBackButton(
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
