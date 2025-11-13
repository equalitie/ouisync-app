import 'package:flutter/services.dart';

Future<void> copyStringToClipboard(String data) async {
  await Clipboard.setData(ClipboardData(text: data));
}

String? Function(String?) validateNoEmptyMaybeRegExpr({
  required String emptyError,
  String? regExp,
  String? regExpError,
}) => (String? value) {
  if (value?.isEmpty ?? true) return emptyError;
  if (regExp != null) {
    if (value!.contains(RegExp(regExp))) return regExpError;
  }

  return null;
};
