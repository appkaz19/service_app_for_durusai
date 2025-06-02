import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static bool isWeb() => kIsWeb;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static int getCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 2;
  }

  static int getOutputCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 4;
    return 4;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 32;
    return 40;
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize * 0.9;
    if (isTablet(context)) return baseFontSize;
    return baseFontSize * 1.1;
  }
}
