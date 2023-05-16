import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // New colors
  static const Color white = Colors.white; // OLD
  static const Color whiteLight = Color(0xffEDEDF8);
  static const Color lightPrimaryBg = Color(0xfff7f5fa);
  static const Color lightShinyPrimary = Color(0xfff0e9fa);
  static Color greyText = Colors.grey.shade800;
  static Color greyLight = Colors.grey.shade300;
  static const Color greyUnavailable = Color(0xff5C5C5C);
  static Color greyUnavailable80 = const Color(0xff5C5C5C).withOpacity(0.80);
  static const Color primaryShiny = Color(0xff6c0cdf);
  static const Color secondaryBlue = Color(0xff035afd);

  // static const Color darkOutline = Color(0xff211c2d);
  // static const Color primaryDark = Color(0xff1A1626);
  // static const Color primaryOriginal = Color(0xff6133E4);
  // static const Color primaryLight = Color(0xff624b99);
  // static Color primaryDisable = AppColors.primaryOriginal.withOpacity(0.50);

  static const Color errRed = Color(0xffc22f2f);
  static const Color blueOld = Color(0xff4177be);
  static const Color greenOld = Color(0xff41BE7B);
  static const Color green = Color(0xffB2F4B0);
  static Color testGreen = AppColors.green.withOpacity(0.40);
  static const Color transparent = Colors.transparent;
}
