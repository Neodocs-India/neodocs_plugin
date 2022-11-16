import 'package:flutter/material.dart';
import '../constants/my_color_scheme.dart';

class AppDesign {
  final BuildContext context;
  AppDesign(this.context);

  BoxDecoration get headerDecoration => const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0XFF141948),
            Color(0XFF000749),
            Color(0XFF504CB9),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0, 0.31, 1],
        ),
      );
  BoxDecoration get bodyDecoration => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColorDark,
            Theme.of(context).primaryColorLight,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0, 1],
        ),
      );

  BoxDecoration get panelCardDecoration => BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: const Offset(3, 1),
            blurRadius: 5,
            spreadRadius: 0,
          ),
          BoxShadow(color: Theme.of(context).colorScheme.primaryContainer)
        ],
        borderRadius: BorderRadius.circular(15),
      );

  BoxDecoration get statusDecoration => BoxDecoration(
        /*gradient: LinearGradient(
          colors: [
            */ /*Theme.of(context).primaryColorDark.withOpacity(0.8),
            Theme.of(context).primaryColorLight.withOpacity(0.8),*/ /*
            Theme.of(context).colorScheme.tertiaryContainer,
            Theme.of(context).colorScheme.tertiaryContainer
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0, 1],
        ),*/
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(15),
        /*boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        offset: const Offset(0, 0),
        blurRadius: 2,
        spreadRadius: 2,
      ),
    ],*/
      );

  Color getStatusColor(final value) {
    Color color = Theme.of(context).extension<MyColorScheme>()!.good!;
    ;
    switch (value.toString().toLowerCase()) {
      case "poor":
      case "low":
        color = Theme.of(context).extension<MyColorScheme>()!.low!;
        break;
      case "sub-optimal":
      case "good":
        color = Theme.of(context).extension<MyColorScheme>()!.good!;
        break;
      case "amazing":
      case "high":
        color = Theme.of(context).extension<MyColorScheme>()!.high!;
        break;
    }
    return color;
  }

  Color getPanelColor(final value) {
    Color color = Theme.of(context).extension<MyColorScheme>()!.good!;
    String status = value > 70 ? "good" : "poor";
    switch (status) {
      case "poor":
        color = Theme.of(context).extension<MyColorScheme>()!.low!;
        break;
      case "good":
        color = Theme.of(context).extension<MyColorScheme>()!.good!;
        break;
      case "high":
        color = Theme.of(context).extension<MyColorScheme>()!.high!;
        break;
    }
    return color;
  }

  Color getBiomarkerColor(final value) {
    Color color = Theme.of(context).extension<MyColorScheme>()!.good!;
    switch (value?.toString().toLowerCase()) {
      case "low":
        color = Color.fromARGB(255, 219, 181, 43);
        break;
      case "good":
        color = Color(0XFF81CBB7);
        break;
      case "high":
        color = Color.fromARGB(255, 248, 153, 10);
        break;
      default:
        color = Color(0XFF81CBB7);
    }
    return color;
  }
}
