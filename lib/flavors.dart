import 'package:flutter/material.dart';

enum Flavor {
  vanilla,
  analytics,
}

class F {
  static Flavor? appFlavor;
  static Color? backgroundColor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.vanilla:
        return 'OuiSync';
      case Flavor.analytics:
        return 'OuiSync';
      default:
        return 'title';
    }
  }

  static Color? get color {
    switch (appFlavor) {
      case Flavor.vanilla:
        return null;
      case Flavor.analytics:
        return Colors.grey.shade800;
      default:
        return null;
    }
  }
}
