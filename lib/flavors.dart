import 'package:flutter/material.dart';

enum Flavor { vanilla, analytics, development }

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
      case Flavor.development:
        return 'OuiSync-Dev';
      default:
        return 'OuiSync';
    }
  }

  static Color? get color {
    switch (appFlavor) {
      case Flavor.vanilla:
        return null;
      case Flavor.analytics:
        return Colors.orange.shade800;
      case Flavor.development:
        return Colors.grey.shade800;
      default:
        return null;
    }
  }
}
