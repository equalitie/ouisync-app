import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as plugin;

import '../../generated/l10n.dart';
import '../utils/utils.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final cameraController =
      MobileScannerController(formats: [BarcodeFormat.qrCode]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleScanRepoQR),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: const TextStyle(
              fontSize: Dimensions.fontAverage, color: Colors.black87),
          actions: [
            IconButton(
              color: Theme.of(context).primaryColorDark,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
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
                  switch (state) {
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
        body: oneTimeScanner());
  }

  MobileScanner oneTimeScanner() {
    var scanned = false;

    return MobileScanner(
        allowDuplicates: false,
        controller: cameraController,
        onDetect: (barcode, args) {
          final code = barcode.rawValue;

          if (code == null) {
            debugPrint('Failed to scan Barcode');
          } else {
            if (scanned == true) {
              debugPrint('Barcode found! $code (skipped)');
              return;
            }

            if (plugin.ShareToken.fromString(code) == null) {
              debugPrint('Barcode found! $code (invalid)');
              return;
            }

            debugPrint('Barcode found! $code');
            scanned = true;
            Navigator.of(context).pop(code);
          }
        });
  }
}
