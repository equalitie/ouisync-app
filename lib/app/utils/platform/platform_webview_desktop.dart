import 'package:flutter/material.dart';

import '../loggers/ouisync_app_logger.dart';
import 'platform.dart';

class PlatformWebViewDesktop with OuiSyncAppLogger implements PlatformWebView {
  Future<dynamic> loadwebView(String url) async {}

  @override
  Future<Widget> loadUrl(BuildContext context, String url) async {
    return SizedBox.shrink();
  }
}
