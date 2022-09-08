import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';

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

String getDirname(String path) => p.dirname(path);

String getFileExtension(String fileName) => p.extension(fileName);

Future<void> copyStringToClipboard(String data) async {
  await Clipboard.setData(ClipboardData(text: data));
}

void showTokenLinkQRCode(BuildContext context, String tokenLink) {
  final qrCodeSize = MediaQuery.of(context).size.width * 0.5;
  final qrCodeImage = QrImage(
    data: tokenLink,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
    size: qrCodeSize,
    padding: const EdgeInsets.all(5.0),
  );

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 800),
    pageBuilder: (
      BuildContext buildContext,
      Animation animation,
      Animation secondaryAnimation) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            color: Colors.white,
            child: qrCodeImage),
        ));
    });
}

String? Function(String?) validateNoEmpty(String error) => (String? value) {
  if (value == null || value.isEmpty) {
    return error;
  }

  return null;
};
