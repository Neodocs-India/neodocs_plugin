import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primaryColor = Color(0XFF000749);
  static const Color primaryVariantColor = Colors.black;
  static const Color secondaryColor = Colors.green;
  static const Color onPrimaryColor = Colors.black;
  static const Color buttonPrimaryColor = Color(0XFF000749);
  static const Color appBarColor = Color(0XFF000749);
  static const Color iconColor = Color(0XFF000749);
  static const Color snackBarBackgroundErrorColor = Colors.redAccent;
  static const Color backgroundColor = Color(0xffF3F3F3);
  static const Color accentColor = Color(0xFF3080f0);
  static const Color white = Color(0XFFFFFFFF);

  //New themes light color
  static Color greenHighlight = const Color(0xFF61F2DA);
  static Color newPrimaryColor = const Color(0XFF000749);
  static Color newBackgroundColor = const Color(0XFF0A0E28);
  static Color lightBlue = const Color(0XFF6C61F2).withOpacity(0.6);
  static Color mediumBlue = const Color(0XFF131847);
  static Color darkBlue = const Color(0XFF000749);
  static Color deepDarkBlue = const Color(0XFF0A0E28);
  static Color navy = const Color(0XFF111446);
  static Color lightGreyColor = const Color(0XFF737171).withOpacity(0.28);
  static Color greyColor = const Color(0XFF464646).withOpacity(0.2);

  //Appcolor new bright color
  //For the top part of the screen
  static BoxDecoration primaryDecoration = BoxDecoration(
    boxShadow: [BoxShadow(color: AppColors.newPrimaryColor)],
    gradient: LinearGradient(
      colors: [
        lightBlue,
        darkBlue,
        mediumBlue,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0, 0.7, 0.9],
    ),
  );

  //Second Part of Screen
  static BoxDecoration secondaryDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        navy,
        deepDarkBlue,
      ],
    ),
    boxShadow: const [
      BoxShadow(color: Color(0XFF2B3489), blurRadius: 18),
    ],
  );

  static BoxDecoration cardsDecorations = BoxDecoration(
    color: const Color(0XFF151740),
    boxShadow: [
      BoxShadow(
        color: lightGreyColor,
        offset: const Offset(3, 1),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      BoxShadow(color: AppColors.newPrimaryColor)
    ],
    borderRadius: BorderRadius.circular(15),
  );

  //Overlapping card
  static BoxDecoration overlappingCardDecoration = BoxDecoration(
    boxShadow: [BoxShadow(color: AppColors.newPrimaryColor)],
    color: AppColors.lightGreyColor,
    borderRadius: BorderRadius.circular(15),
  );

  //BrightColor decoration
  static BoxDecoration brightSecondaryDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color(0XFFF2F8FF),
        const Color(0XFFD0D9E5).withOpacity(0.87)
      ],
    ),
  );

  //The bright car overlapping both primary and seconday decoration
  static BoxDecoration brightOverlappingCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color(0XFFEFEEFD).withOpacity(0.8),
        const Color(0XFFFFFFFF).withOpacity(0.8)
      ],
    ),
    borderRadius: BorderRadius.circular(15),
  );

  static BoxDecoration brightCardsDecoration = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: const Color(0XFF737171).withOpacity(0.28),
        offset: const Offset(13, 1),
        blurRadius: 87,
        spreadRadius: 0,
      ),
      const BoxShadow(color: Colors.white)
    ],
    borderRadius: BorderRadius.circular(15),
  );
}
