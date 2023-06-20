import 'package:flutter/material.dart';

class WebViewPage extends StatelessWidget {
  const WebViewPage({required this.title, required this.content});

  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: title), body: content);
}
