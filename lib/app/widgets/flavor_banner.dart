import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlavorBanner extends StatelessWidget {
  final Widget child;

  FlavorBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final flavor = appFlavor;

    if (flavor == null || flavor == 'production') {
      return child;
    } else {
      return Banner(
        location: BannerLocation.topEnd,
        message: flavor,
        color: _flavorColor(flavor),
        child: child,
      );
    }
  }
}

Color _flavorColor(String flavor) => switch (flavor) {
  'nightly' => const Color(0xFFE65100),
  'unofficial' => const Color(0xFF0D47A1),
  _ => Colors.grey,
};
