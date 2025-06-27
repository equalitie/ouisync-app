import 'package:flutter/services.dart';

/// Application flavor. This is set to the current [android]
/// (https://docs.flutter.dev/deployment/flavors) or [ios/macos]
/// (https://docs.flutter.dev/deployment/flavors-ios) flavor or to the value of the `OUISYNC_FLAVOR`
/// env variable on other platforms. If not explicitly set, defaults to `production`.
enum Flavor {
  production,
  nightly,
  unofficial;

  static Flavor? parse(String input) => switch (input.trim().toLowerCase()) {
    'production' => production,
    'nightly' => nightly,
    'unofficial' => unofficial,
    _ => null,
  };

  static final current =
      parse(appFlavor ?? '') ??
      parse(String.fromEnvironment('OUISYNC_FLAVOR')) ??
      production;
}
