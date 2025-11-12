import 'dart:io';

import 'package:flutter/material.dart';

import 'platform.dart';

abstract class PlatformWebView {
  factory PlatformWebView() {
    if (Platform.isAndroid || Platform.isIOS) {
      return PlatformWebViewMobile();
    }
    return PlatformWebViewDesktop();
  }

  Future<Widget> loadUrl(String url);

  Future<bool> launchUrl(String url);
}
