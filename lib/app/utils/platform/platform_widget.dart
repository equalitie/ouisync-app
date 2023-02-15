import 'package:flutter/widgets.dart';

import 'platform_values.dart';

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
