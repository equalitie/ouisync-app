import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class PositiveButton extends StatelessWidget {
  const PositiveButton({
    required this.text,
    required this.onPressed,
    required this.buttonsAspectRatio,
    this.buttonConstrains = Dimensions.sizeConstrainsDialogAction,
    this.focusNode,
    this.isDangerButton = false,
    super.key,
  });

  final String? text;
  final GestureTapCallback? onPressed;
  final double buttonsAspectRatio;
  final BoxConstraints buttonConstrains;
  final FocusNode? focusNode;
  final bool isDangerButton;

  @override
  Widget build(BuildContext context) => Expanded(
          child: Row(
        children: [
          Expanded(
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: AspectRatio(
                      aspectRatio: buttonsAspectRatio,
                      child: Container(
                        margin: Dimensions.marginDialogPositiveButton,
                        child: RawMaterialButton(
                            onPressed: onPressed,
                            child: Text((text ?? '').toUpperCase()),
                            constraints: buttonConstrains,
                            elevation: Dimensions.elevationDialogAction,
                            fillColor: _fillColorStatus(context),
                            shape: const RoundedRectangleBorder(
                                borderRadius: Dimensions
                                    .borderRadiusDialogPositiveButton),
                            textStyle: TextStyle(
                                color: Theme.of(context).dialogBackgroundColor,
                                fontWeight: FontWeight.w500),
                            focusNode: focusNode),
                      ))))
        ],
      ));

  Color _fillColorStatus(context) {
    return onPressed == null
        ? Colors.grey
        : isDangerButton
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary;
  }
}
