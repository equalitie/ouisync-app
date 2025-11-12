import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'platform.dart';

class PlatformWebViewDesktop implements PlatformWebView {
  @override
  Future<bool> launchUrl(String url) async =>
      launcher.launchUrl(Uri.parse(url));

  @override
  Future<Widget> loadUrl(String url) {
    throw UnimplementedError();
  }
}
