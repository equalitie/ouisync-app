import 'package:flutter/widgets.dart';

class AppBranding extends StatelessWidget {
  const AppBranding({
    required this.appName,
    this.logo
  });

  final String appName;
  final Image? logo;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Center(
          child: Text(
            appName,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w800
            ),),
        ),
      )
    );
  }
}