import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';

class RepositoryQRPage extends StatefulWidget {
  const RepositoryQRPage({required this.shareLink, super.key});

  final String shareLink;

  @override
  State<RepositoryQRPage> createState() => _RepositoryQRPageState();
}

class _RepositoryQRPageState extends State<RepositoryQRPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          leading: Fields.actionIcon(
              const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          elevation: 0.0,
          backgroundColor: Colors.transparent),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _getQRCodeImage(widget.shareLink),
        _buildShareMessage()
      ])));

  Widget _getQRCodeImage(String tokenLink) {
    double qrCodeSize = 0.0;
    qrCodeSize = (Platform.isAndroid || Platform.isIOS
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height) *
        0.6;

    final qrCodeImage = QrImageView(
      data: tokenLink,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      size: qrCodeSize,
    );

    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: Dimensions.borderQRCodeImage, color: Colors.white),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            color: Colors.white),
        child: qrCodeImage);
  }

  Widget _buildShareMessage() {
    return Padding(
        padding: Dimensions.paddingTop40,
        child: Column(children: [
          Text(S.current.messageShareWithWR,
              textAlign: TextAlign.center,
              style: context.theme.appTextStyle.titleLarge
                  .copyWith(color: Colors.white)),
          Dimensions.spacingVertical,
          Text(S.current.messageScanQROrShare,
              textAlign: TextAlign.center,
              style: context.theme.appTextStyle.bodyMedium
                  .copyWith(color: Colors.white))
        ]));
  }
}
