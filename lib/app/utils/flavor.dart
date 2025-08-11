import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Application flavor. This is set to the current [android]
/// (https://docs.flutter.dev/deployment/flavors) or [ios/macos]
/// (https://docs.flutter.dev/deployment/flavors-ios) flavor or to the value of the `OUISYNC_FLAVOR`
/// env variable on other platforms. If not explicitly set, defaults to `production`.
enum Flavor {
  production,
  nightly,
  unofficial,
  // Used for integration tests (note, for some reason, product flavors on android can't
  // start with "test").
  itest;

  static Flavor? parse(String input) => switch (input.trim().toLowerCase()) {
    'production' => production,
    'nightly' => nightly,
    'unofficial' => unofficial,
    'itest' || 'test' => itest,
    _ => null,
  };

  static Flavor _current =
      parse(appFlavor ?? '') ??
      parse(String.fromEnvironment('OUISYNC_FLAVOR')) ??
      production;

  static Flavor get current => _current;

  @visibleForTesting
  static set current(value) {
    _current = value;
  }

  @override
  String toString() => switch (this) {
    production => 'production',
    nightly => 'nightly',
    unofficial => 'unofficial',
    itest => 'itest',
  };
}
