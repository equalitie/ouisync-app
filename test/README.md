# Testing flutter apps

- Introduction to widget tests: https://docs.flutter.dev/testing/overview#widget-tests
- API docs:
  https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html.
  Especially the [WidgetTester](widget-tester-link) class which is used to
  simulate interaction with the widgets and [CommonFinders](common-finders-link)
  to find stuff in the widgets.
- `test/flutter_test_config.dart` is used to automatically setup test
  environment for all tests. Currently it configures `path_provider` to use a
  temp directory (unique per test) and `shared_preferences` to use mock in-memory
  store.
- `test/utils.dart` contains some utilities useful for tests:
    - `tester.takeScreenshot` is useful for debugging widget tests. It
      screenshots the widget under test and places it in `test/screenshots`.
      Note that all font glyphs by default render as rectangles. To fix this use the
      [`loadAppFonts` function](load-app-fonts-link) from the `golden_toolkit`
      package at the beginning of the failing test. Another option is to set up
      custom fonts as explained [here](override-custom-fonts)
       (it didn't work for us for some reason).
    - `testApp` creates a basic `MaterialApp` to wrap the widget under test.
    - `cubit.waitUntil` waits until the cubit transitions to the desired state.
      This is useful for testing cubits and widgets that contain cubits.

 ## Widget tests

Widget tests in flutter are tricky and have significant limitations. It's
therefore preferred to organize the app so that most of the actual logic is not
in widgets but rather in blocs/cubits or other auxiliary classes and then unit
tests those. In cases where actual widget tests are desired, this section has
some potentially useful information.

 After interacting with the widget under test (e.g., using `tester.tap` or
`tester.enterText`, ...) it's typically necessary to call `tester.pump` or
`tester.pumpAndSettle` before performing any assertions. It's unclear when to
call which. It seems `pump` is usually sufficiet but sometimes `pumpAndSettle`
is needed. It seems `pumpAndSettle` is needed mostly when the interaction
triggers some animation, so that the test waits until the animation completes,
but not 100% about this. I usually try `pump` first and when it doesn't work,
use `pumpAndSettle`. Use `tester.takeScreenshot` to debug.

 ### Async gotchas

 Invoking any async operation inside `testWidgets` must be done inside
[`tester.runAsync`](tester-runasync-link). The only exception are the methods
on [`tester`](tester-link) itself. This applies also when a widget interaction
(`tester.tap()`, ...) triggers an async operation. In that case the interaction
itself must also be inside `runAsync`. To keep things simple, it's probably
best to wrap the whole test in `runAsync`. Note this applies only to
`testWidgets`. Regular `test`, `setUp`, `tearDown`, etc... Don't need this as
async in them works as expected.

Note that if the widget under test invoked any async operation, neither `pump`
nor `pumpAndSettle` wait for it to complete. It's therefore necessary to do
this wait explicitly. This needs to happen **before** calling `pump` /
`pumpAndSettle`. When testing widgets that contain cubits, one way to do this
is to grab that cubit and wait for it's state to change. The `waitUntil`
extension is useful for this.

[widget-tester-link]: https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html
[common-finders-link]: https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html
[load-app-fonts-link]: https://pub.dev/packages/golden_toolkit#loading-fonts
[override-custom-fonts]: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
[tester-runasync-link]: https://api.flutter.dev/flutter/flutter_test/WidgetTester/runAsync.html
[tester-link]: https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html
