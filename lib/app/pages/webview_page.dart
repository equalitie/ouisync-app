import 'package:flutter/material.dart';

import '../widgets/bars/directional_app_bar.dart';

class WebViewPage extends StatelessWidget {
  const WebViewPage({required this.title, required this.content});

  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(title: title),
    body: content,
  );
}
