import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class DangerButton extends StatelessWidget {
  const DangerButton({required this.text, required this.onPressed, super.key});

  final String? text;
  final GestureTapCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: Dimensions.marginDialogPositiveButton,
        child: RawMaterialButton(
            onPressed: onPressed,
            child: Text((text ?? '').toUpperCase()),
            constraints: Dimensions.sizeConstrainsDialogAction,
            elevation: Dimensions.elevationDialogAction,
            fillColor: _fillColorStatus(context),
            shape: const RoundedRectangleBorder(
                borderRadius: Dimensions.borderRadiusDialogPositiveButton),
            textStyle: TextStyle(
                color: Theme.of(context).dialogTheme.backgroundColor,
                fontWeight: FontWeight.w500)));
  }

  Color _fillColorStatus(context) {
    return onPressed == null
        ? Colors.grey
        : Theme.of(context).colorScheme.error;
  }
}
