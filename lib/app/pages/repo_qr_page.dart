import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/utils.dart';

class RepositoryQRPage extends StatefulWidget {
  const RepositoryQRPage({
    required this.shareLink,
    Key? key}) : super(key: key);

  final String shareLink;

  @override
  State<RepositoryQRPage> createState() => _RepositoryQRPageState();
}

class _RepositoryQRPageState extends State<RepositoryQRPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Fields.actionIcon(
          const Icon(Icons.close,
            color: Colors.white,),
          onPressed: () => Navigator.of(context).pop()),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: Dimensions.fontAverage,
          color: Colors.white
        ),),
        backgroundColor: Theme.of(context).primaryColorDark,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getQRCodeImage(widget.shareLink),
          _buildShareMessage(),
        ],
      )));
  }

  Widget _getQRCodeImage(String tokenLink) {
    final qrCodeSize = MediaQuery.of(context).size.width * 0.6;
    final qrCodeImage = QrImage(
      data: tokenLink,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      size: qrCodeSize,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: Dimensions.borderQRCodeImage,
          color: Colors.white
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Colors.white
      ),
      child: qrCodeImage);
  }

  Widget _buildShareMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [
          const Text('Share with QR Code',
            style: TextStyle(
              fontSize: Dimensions.fontBig,
              fontWeight: FontWeight.w500,
              color: Colors.white
            ),),
          Dimensions.spacingVertical,
          const Text('Scan this with your other device or share it with your peers',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white
            ),),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       Fields.paddedActionText(S.current.iconShare,
          //         flex: 0,
          //         onTap: () {},
          //         textColor: Colors.white,
          //         textFontSize: Dimensions.fontAverage,
          //         icon: Icons.share,
          //         iconColor: Colors.white),
          //       Fields.paddedActionText(S.current.iconDownload,
          //         flex: 0,
          //         onTap: () {},
          //         textColor: Colors.white,
          //         textFontSize: Dimensions.fontAverage,
          //         icon: Icons.arrow_downward_outlined,
          //         iconColor: Colors.white),
          //     ],),)
        ],
      ));
  }
}