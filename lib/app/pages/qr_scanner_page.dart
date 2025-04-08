import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ouisync/ouisync.dart' as plugin;

import '../../generated/l10n.dart';
import '../utils/utils.dart' show AppLogger, Dimensions;
import '../widgets/widgets.dart' show DirectionalAppBar;

class QRScanner extends StatefulWidget {
  final plugin.Session session;

  const QRScanner(this.session, {super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> with AppLogger {
  final cameraController =
      MobileScannerController(formats: [BarcodeFormat.qrCode]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DirectionalAppBar(
          title: Text(S.current.titleScanRepoQR),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          actions: [
            IconButton(
              color: Theme.of(context).primaryColorDark,
              icon: ValueListenableBuilder(
                valueListenable: cameraController,
                builder: (context, state, child) => switch (state.torchState) {
                  TorchState.off =>
                    const Icon(Icons.flash_off_outlined, color: Colors.grey),
                  TorchState.on =>
                    Icon(Icons.flash_on_outlined, color: Colors.yellow[800]),
                  TorchState.auto =>
                    const Icon(Icons.flash_auto_outlined, color: Colors.grey),
                  TorchState.unavailable =>
                    const Icon(Icons.flash_off_outlined, color: Colors.white54),
                },
              ),
              iconSize: Dimensions.sizeIconAverage,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Theme.of(context).primaryColorDark,
              icon: ValueListenableBuilder(
                valueListenable: cameraController,
                builder: (context, state, child) =>
                    switch (state.cameraDirection) {
                  CameraFacing.front => const Icon(Icons.camera_front),
                  CameraFacing.back => const Icon(Icons.camera_rear),
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
        controller: cameraController,
        onDetect: (capture) async {
          String? code;

          if (capture.barcodes.isNotEmpty) {
            code = capture.barcodes
                .map((bc) => bc.rawValue)
                .firstWhere((code) => code != null, orElse: () => null);
          }

          if (code == null) {
            loggy.debug('Failed to scan Barcode');
          } else {
            if (scanned == true) {
              loggy.debug('Barcode found! $code (skipped)');
              return;
            }

            try {
              await widget.session.validateShareToken(code);
            } catch (_) {
              loggy.debug('Barcode found! $code (invalid)');
              return;
            }

            loggy.debug('Barcode found! $code');
            scanned = true;

            await Navigator.of(context).maybePop(code);
          }
        });
  }
}
