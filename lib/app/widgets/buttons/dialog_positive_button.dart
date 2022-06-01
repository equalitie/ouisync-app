import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class PositiveButton extends StatelessWidget {
  const PositiveButton({
    required this.text,
    required this.onPressed,
    Key? key}) : super(key: key);

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
        fillColor: Theme.of(context).colorScheme.primary, 
        shape: const RoundedRectangleBorder(
          borderRadius: Dimensions.borderRadiusDialogPositiveButton),
        textStyle: TextStyle(
          color: Theme.of(context).dialogBackgroundColor,
          fontWeight: FontWeight.w500)
      ));
  }
}