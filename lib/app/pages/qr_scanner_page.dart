import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final cameraController = MobileScannerController(formats: [BarcodeFormat.qrCode]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleScanRepoQR),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: const TextStyle(
            fontSize: Dimensions.fontAverage,
            color: Colors.black87
          ),
          actions: [
            IconButton(
              color: Theme.of(context).primaryColorDark,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return Icon(Icons.flash_on, color: Colors.yellow[800]);
                  }
                },
              ),
              iconSize: Dimensions.sizeIconAverage,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Theme.of(context).primaryColorDark,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: Dimensions.sizeIconAverage,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                debugPrint('Barcode found! $code');

                Navigator.of(context).pop(code);
              }
            }));
  }
}