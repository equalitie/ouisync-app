import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/flavor.dart';

class FlavorBanner extends StatelessWidget {
  final Widget child;

  FlavorBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) => switch (Flavor.current) {
    Flavor.production => child,
    Flavor.nightly || Flavor.unofficial => Banner(
      location: BannerLocation.topEnd,
      message: Flavor.current.toString(),
      color: _flavorColor(Flavor.current),
      child: child,
    ),
  };
}

Color _flavorColor(Flavor flavor) => switch (flavor) {
  Flavor.production => Colors.grey,
  Flavor.nightly => const Color(0xFFE65100),
  Flavor.unofficial => const Color(0xFF0D47A1),
};
