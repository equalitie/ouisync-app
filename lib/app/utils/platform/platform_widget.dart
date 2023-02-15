import 'package:flutter/widgets.dart';

import 'platform_values.dart';

abstract class PlatformWidget<M extends Widget, D extends Widget>
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (PlatformValues.isMobileDevice) {
      return buildMobileWidget(context);
    }
    return buildDesktopWidget(context);
  }

  M buildMobileWidget(BuildContext context);
  D buildDesktopWidget(BuildContext context);
}
