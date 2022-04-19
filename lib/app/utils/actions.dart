import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';

showSnackBar(BuildContext context, { required Widget content, SnackBarAction? action }) =>
  ScaffoldMessenger
  .of(context)
  .showSnackBar(
    SnackBar(
      content: content,
      action: action,
    ),  
  );

hideSnackBar(context) => 
  SnackBarAction(
    label: S.current.actionHideCapital,
    onPressed: () => 
      ScaffoldMessenger.of(context).hideCurrentSnackBar()
  );

String getBasename(String path) => p.basename(path);

String getParentSection (String path) => p.dirname(path);

String getFileExtension(String fileName) => p.extension(fileName);

Future<void> copyStringToClipboard(String data) async {
  await Clipboard.setData(ClipboardData(text: data));
}

String? formNameValidator(String? value, { String? error }) {
  return value!.isEmpty ? (error ?? S.current.messageErrorFormValidatorNameDefault) : null;
}