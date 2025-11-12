import 'package:flutter/material.dart';

/// Utility to navigate between pages, show/hide modal and non modal dialogs and notification
/// messages.
class Stage {
  ScaffoldMessengerState? _messengerState;
  //NavigatorState? _navigatorState;

  // Set of currently shown snack bar messages. Used to prevent the same message to show more than
  // once at a time.
  final Set<String> _currentSnackBarMessages = {};

  Stage([BuildContext? context]) {
    if (context != null) {
      update(context);
    }
  }

  void update(BuildContext context) {
    _messengerState = ScaffoldMessenger.of(context);
    //_navigatorState = Navigator.of(context);
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
}
