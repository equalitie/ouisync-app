import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class NegativeButton extends StatelessWidget {
  const NegativeButton(
      {required this.text,
      required this.onPressed,
      this.buttonsAspectRatio = Dimensions.aspectRatioModalDialogButton,
      Key? key})
      : super(key: key);

  final String? text;
  final GestureTapCallback? onPressed;
  final double buttonsAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: AspectRatio(
              aspectRatio: buttonsAspectRatio,
              child: Container(
                margin: Dimensions.marginDialogNegativeButton,
                child: RawMaterialButton(
                  onPressed: onPressed,
                  child: Text((text ?? '').toUpperCase()),
                  constraints: Dimensions.sizeConstrainsDialogAction,
                  elevation: Dimensions.elevationDialogAction,
                  textStyle: Dimensions.textStyleDialogNegativeButton,
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
