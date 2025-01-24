import 'package:build_context_provider/build_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n.dart';

//------------------------------------------------------------------------------
// Keep track of what snackbar messages we're showing so as to not show them
// redundantly. The _SnackBarWrap class is used to remove the message from
// _snackbars.

List<String> _snackbars = [];

class _SnackBarWrap extends StatefulWidget {
  final String _message;
  const _SnackBarWrap(this._message);

  @override
  State<_SnackBarWrap> createState() => _SnackBarWrapState(_message);
}

class _SnackBarWrapState extends State<_SnackBarWrap> {
  final String _message;
  _SnackBarWrapState(this._message);

  @override
  Widget build(BuildContext context) {
    return Text(_message);
  }

  @override
  void dispose() {
    super.dispose();
    _snackbars.retainWhere((item) => item != _message);
  }
}

//------------------------------------------------------------------------------

showSnackBar(
  String message, {
  BuildContext? context,
  SnackBarAction? action,
  bool showCloseIcon = true,
  SnackBarBehavior? behavior = SnackBarBehavior.floating,
}) =>
    context != null
        ? _showSnackBar(context, message, action, showCloseIcon, behavior!)
        : WidgetsBinding.instance.addPostFrameCallback(
            (_) => BuildContextProvider().call(
              (context) => _showSnackBar(
                context,
                message,
                action,
                showCloseIcon,
                behavior!,
              ),
            ),
          );

_showSnackBar(
  BuildContext context,
  String message,
  SnackBarAction? action,
  bool showCloseIcon,
  SnackBarBehavior behavior,
) {
  final messenger = ScaffoldMessenger.of(context);

  if (_snackbars.contains(message)) {
    return;
  }

  _snackbars.add(message);

  messenger.showSnackBar(
    SnackBar(
      content: _SnackBarWrap(message),
      action: action,
      showCloseIcon: showCloseIcon,
      behavior: behavior,
    ),
  );
}

hideSnackBar(context) => SnackBarAction(
    label: S.current.actionHideCapital,
    onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar());

Future<void> copyStringToClipboard(String data) async {
  await Clipboard.setData(ClipboardData(text: data));
}

String? Function(String?) validateNoEmptyMaybeRegExpr(
        {required String emptyError, String? regExp, String? regExpError}) =>
    (String? value) {
      if (value?.isEmpty ?? true) return emptyError;
      if (regExp != null) {
        if (value!.contains(RegExp(regExp))) return regExpError;
      }

      return null;
    };
