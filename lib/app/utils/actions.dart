import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/l10n.dart';
import 'utils.dart';

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

void showTokenLinkQRCode(BuildContext context,{
  required String tokenLink,
  required String repoName,
  required String accessModeName,
  required IconData accessModeIcon,
  required String displayLink
}) {
  final repoNameMaxWidth = MediaQuery.of(context).size.width * 0.5;
  final qrCodeSize = MediaQuery.of(context).size.width * 0.4;
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          accessModeIcon,
                          size: Dimensions.sizeIconAverage,
                          color: Colors.black87
                        ),
                        Dimensions.spacingHorizontal,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(
                                Size.fromWidth(repoNameMaxWidth)),
                              child: Text(repoName,
                                textAlign: TextAlign.start,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: Dimensions.fontBig,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87
                                )
                              )),
                            Text(accessModeName,
                              textAlign: TextAlign.start,),
                          ],
                        )
                      ],)),
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColorDark,
                        width: 4.0
                      ),
                      borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: qrCodeImage),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0), 
                        bottomRight: Radius.circular(8.0)),
                      color: Constants.inputBackgroundColor,
                    ),
                    child:Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        displayLink,
                        style: const TextStyle(
                          fontSize: Dimensions.fontSmall,
                          fontWeight: FontWeight.bold
                        ),)))
                ],))));
    });
}

String? Function(String?) validateNoEmpty(String error) => (String? value) {
  if (value == null || value.isEmpty) {
    return error;
  }

  return null;
};
