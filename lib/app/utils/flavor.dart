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
      // Note the `const` is crucial here. According to the [docs]
      // (https://api.flutter.dev/flutter/dart-core/String/String.fromEnvironment.html):
      //
      // > This constructor is only guaranteed to work when invoked as const. It may work as a
      // > non-constant invocation on some platforms which have access to compiler options at
      // > run-time, but most ahead-of-time compiled platforms will not have this information.
      parse(const String.fromEnvironment('OUISYNC_FLAVOR')) ??
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
