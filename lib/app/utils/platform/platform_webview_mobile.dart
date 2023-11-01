import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'platform.dart';

class PlatformWebViewMobile implements PlatformWebView {
  PlatformWebViewMobile();

  @override
  Future<WebViewWidget> loadUrl(BuildContext context, String url) async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    final initalizations = <Future>[];

    initalizations
        .add(controller.setJavaScriptMode(JavaScriptMode.unrestricted));
    initalizations.add(controller.setBackgroundColor(Colors.white));
    initalizations.add(controller.loadRequest(Uri.parse(url)));

    if (controller.platform is AndroidWebViewController) {
      initalizations.add(AndroidWebViewController.enableDebugging(true));
      initalizations.add((controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false));
    }

    await Future.wait(initalizations);

    return WebViewWidget(controller: controller);
  }

  @override
  Future<bool> launchUrl(String url) => launcher.launchUrl(Uri.parse(url));
}
