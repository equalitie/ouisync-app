import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class PlatformWidget<M extends Widget, D extends Widget>
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (PlatformValues.isMobileDevice) {
      return mobileWidget(context);
    }
    return desktopWidget(context);
  }

  M mobileWidget(BuildContext context);
  D desktopWidget(BuildContext context);
}

class PlatformValues {
  static bool get isMobileDevice =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktopDevice =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static ScreenSize getScreenSize(BuildContext context) =>
      _FormFactor.getScreenSize(context);

  static ScreenType getFormFactor(BuildContext context) =>
      _FormFactor.getFormFactor(context);
}

enum ScreenType { handset, tablet, desktop, watch }

enum ScreenSize { small, normal, large, extraLarge }

class _FormFactor {
  static double desktop = 900;
  static double tablet = 600;
  static double handset = 300;

  static ScreenType getFormFactor(BuildContext context) {
    // Use .shortestSide to detect device type regardless of orientation
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > _FormFactor.desktop) return ScreenType.desktop;
    if (deviceWidth > _FormFactor.tablet) return ScreenType.tablet;
    if (deviceWidth > _FormFactor.handset) return ScreenType.handset;
    return ScreenType.watch;
  }

  static ScreenSize getScreenSize(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > _FormFactor.desktop) return ScreenSize.extraLarge;
    if (deviceWidth > _FormFactor.tablet) return ScreenSize.large;
    if (deviceWidth > _FormFactor.handset) return ScreenSize.normal;
    return ScreenSize.small;
  }
}
