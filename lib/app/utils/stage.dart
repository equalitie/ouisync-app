import 'dart:async';

import 'package:flutter/material.dart' hide showDialog;
import 'package:flutter/material.dart' as flutter;

/// Utility to navigate between pages, show/hide modal and non modal dialogs and notification
/// messages.
class Stage {
  ScaffoldMessengerState? _messengerState;
  NavigatorState? _navigatorState;

  // Set of currently shown snack bar messages. Used to prevent the same message to show more than
  // once at a time.
  final Set<String> _currentSnackBarMessages = {};

  var _loadingInvocations = 0;

  Stage([BuildContext? context]) {
    if (context != null) {
      update(context);
    }
  }

  void update(BuildContext context) {
    _messengerState = ScaffoldMessenger.of(context);
    _navigatorState = Navigator.of(context);
  }

  void showSnackBar(
    String message, {
    SnackBarAction? action,
    bool showCloseIcon = true,
    SnackBarBehavior? behavior = SnackBarBehavior.floating,
  }) {
    final state = _messengerState;
    if (state == null) {
      return;
    }

    if (!_currentSnackBarMessages.add(message)) {
      return;
    }

    state
        .showSnackBar(
          SnackBar(
            content: Text(message),
            action: action,
            showCloseIcon: showCloseIcon,
            behavior: behavior,
          ),
        )
        .closed
        .whenComplete(() {
          _currentSnackBarMessages.remove(message);
        });
  }

  /// Push the given route onto the navigator stack.
  Future<T?> push<T>(Route<T> route) {
    final state = _navigatorState;
    if (state != null) {
      return state.push(route);
    } else {
      return Future.value(null);
    }
  }

  /// Pop the topmost route from the navigator stack.
  void pop<T>([T? result]) => _navigatorState?.pop(result);

  /// Pop the topmost route from the navigator stack if the route allows it. Returns whether the
  /// route has been popped.
  Future<bool> maybePop<T>([T? result]) async =>
      await _navigatorState?.maybePop(result) ?? false;

  Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    //Color? barrierColor,
    //String? barrierLabel,
    //bool useSafeArea = true,
    //bool useRootNavigator = true,
    //RouteSettings? routeSettings,
    //Offset? anchorPoint,
    //TraversalEdgeBehavior? traversalEdgeBehavior,
    //bool fullscreenDialog = false,
    //bool? requestFocus,
    //AnimationStyle? animationStyle,
  }) {
    final state = _navigatorState;
    if (state != null) {
      return flutter.showDialog(
        context: state.context,
        builder: builder,
        barrierDismissible: barrierDismissible,
      );
    } else {
      return Future.value(null);
    }
  }

  Future<T?> showModalBottomSheet<T>({
    required WidgetBuilder builder,
    //Color? backgroundColor,
    //String? barrierLabel,
    //double? elevation,
    ShapeBorder? shape,
    //Clip? clipBehavior,
    BoxConstraints? constraints,
    //Color? barrierColor,
    bool isScrollControlled = false,
    //double scrollControlDisabledMaxHeightRatio = _defaultScrollControlDisabledMaxHeightRatio,
    //bool useRootNavigator = false,
    //bool isDismissible = true,
    //bool enableDrag = true,
    //bool? showDragHandle,
    //bool useSafeArea = false,
    //RouteSettings? routeSettings,
    //AnimationController? transitionAnimationController,
    //Offset? anchorPoint,
    //AnimationStyle? sheetAnimationStyle,
    //bool? requestFocus,
  }) {
    final state = _navigatorState;
    if (state != null) {
      return flutter.showModalBottomSheet(
        context: state.context,
        builder: builder,
        shape: shape,
        constraints: constraints,
        isScrollControlled: isScrollControlled,
      );
    } else {
      return Future.value(null);
    }
  }

  /// Show loading dialog while the given future is being executed and return whatever the future
  /// resolves into. If invoked multiple times concurrently, only one loading dialog is shown and
  /// it lasts until the last invocation completes.
  Future<T> loading<T>(Future<T> future) async {
    if (_loadingInvocations == 0) {
      unawaited(
        showDialog(
          barrierDismissible: false,
          builder: (BuildContext context) => PopScope(
            canPop: false,
            child: Center(
              child: const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    _loadingInvocations += 1;

    try {
      return await future;
    } finally {
      _loadingInvocations -= 1;

      if (_loadingInvocations == 0) {
        _navigatorState?.pop();
      }
    }
  }
}
