import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodocs_package/constants/my_color_scheme.dart';

class AppThemes {
  AppThemes._();
  static final ThemeData newTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    colorScheme: const LightScheme(),
    extensions: [MyColorScheme().copyWith(colors: const LightScheme())],
    scaffoldBackgroundColor: const LightScheme().primary,
    splashColor: const LightScheme().secondary.withOpacity(0.5),
    highlightColor: const LightScheme().secondary.withOpacity(0.5),
    shadowColor: const LightScheme().shadow,
    cardColor: const LightScheme().primaryContainer,
    primaryColor: const LightScheme().primary,
    primaryColorLight: const LightScheme().primaryLight,
    primaryColorDark: const LightScheme().primaryDark,
    backgroundColor: const LightScheme().primary,
    bottomAppBarColor: const Color(0XFFE5E5E5),

    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: const LightScheme().primary),
        color: const LightScheme().primary,
        foregroundColor: const LightScheme().primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0XFFC2CADA),
          systemNavigationBarDividerColor: Color(0XFFD0D9E5),
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        )),
    //-->Metropolis
    primaryTextTheme: ThemeData(
            fontFamily: 'metropolis', brightness: Brightness.light)
        .primaryTextTheme
        .copyWith(
          displayLarge:
              ThemeData.light().primaryTextTheme.displayLarge!.copyWith(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w600,
                  ),
          displayMedium:
              ThemeData.light().primaryTextTheme.displayMedium!.copyWith(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w700,
                  ),
          displaySmall:
              ThemeData.light().primaryTextTheme.displaySmall!.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                  ),
          headlineLarge:
              ThemeData.light().primaryTextTheme.headlineLarge!.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
          headlineMedium:
              ThemeData.light().primaryTextTheme.headlineMedium!.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
          headlineSmall:
              ThemeData.light().primaryTextTheme.headlineSmall!.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
          titleLarge: ThemeData.light().primaryTextTheme.titleLarge!.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
          titleMedium: ThemeData.light().primaryTextTheme.titleMedium!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
          titleSmall: ThemeData.light().primaryTextTheme.titleSmall!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
          bodyLarge: ThemeData.light().primaryTextTheme.bodyLarge!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
          bodyMedium: ThemeData.light().primaryTextTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
          bodySmall: ThemeData.light().primaryTextTheme.bodySmall!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
          labelLarge: ThemeData.light().primaryTextTheme.labelLarge!.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
          labelMedium: ThemeData.light().primaryTextTheme.labelMedium!.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
          labelSmall: ThemeData.light().primaryTextTheme.labelSmall!.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w300,
              ),
        )
        .apply(
          fontFamily: 'metropolis',
          bodyColor: const LightScheme().secondary,
          displayColor: const LightScheme().secondary,
        ),
    //Manrope
    textTheme: ThemeData.light()
        .textTheme
        .copyWith(
          displayLarge: ThemeData.light().textTheme.displayLarge!.copyWith(
                fontSize: 35.sp,
                fontWeight: FontWeight.w700,
              ),
          displayMedium: ThemeData.light().textTheme.displayMedium!.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.w500,
              ),
          displaySmall: ThemeData.light().textTheme.displaySmall!.copyWith(
                fontSize: 30.sp,
                fontWeight: FontWeight.w600,
              ),
          headlineLarge: ThemeData.light().textTheme.headlineLarge!.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
          headlineMedium: ThemeData.light().textTheme.headlineMedium!.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w300,
              ),
          headlineSmall: ThemeData.light().textTheme.headlineSmall!.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
              ),
          titleLarge: ThemeData.light().textTheme.titleLarge!.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
          titleMedium: ThemeData.light().textTheme.titleMedium!.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
          titleSmall: ThemeData.light().textTheme.titleSmall!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
          bodyLarge: ThemeData.light().textTheme.bodyLarge!.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
          bodyMedium: ThemeData.light().textTheme.bodyMedium!.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
          bodySmall: ThemeData.light().textTheme.bodySmall!.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
        )
        .apply(
          fontFamily: 'manrope',
          bodyColor: const LightScheme().secondary,
          displayColor: const LightScheme().secondary,
        ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0XFF000749),
    ),
  );
}
