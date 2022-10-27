import 'package:flutter/material.dart';

enum Flavor {
  VANILLA,
  ANALYTICS,
}

class F {
  static Flavor? appFlavor;
  static Color? backgroundColor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.VANILLA:
        return 'OuiSync';
      case Flavor.ANALYTICS:
        return 'OuiSync';
      default:
        return 'title';
    }
  }

  static Color? get color {
    switch (appFlavor) {
      case Flavor.VANILLA:
        return null;
      case Flavor.ANALYTICS:
        return Colors.grey.shade800;
      default:
        return null;
    }
  }
}
