import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class PositiveButton extends StatelessWidget {
  const PositiveButton({required this.text, required this.onPressed, Key? key})
      : super(key: key);

  final String? text;
  final GestureTapCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
      children: [
        Expanded(
            child: Align(
                alignment: Alignment.bottomRight,
                child: AspectRatio(
                    aspectRatio: Dimensions.aspectRatioModalDialogButton,
                    child: Container(
                      margin: Dimensions.marginDialogPositiveButton,
                      child: RawMaterialButton(
                        onPressed: onPressed,
                        child: Text((text ?? '').toUpperCase()),
                        constraints: Dimensions.sizeConstrainsDialogAction,
                        elevation: Dimensions.elevationDialogAction,
                        fillColor: _fillColorStatus(context),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                Dimensions.borderRadiusDialogPositiveButton),
                        textStyle: TextStyle(
                            color: Theme.of(context).dialogBackgroundColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ))))
      ],
    ));
  }

  Color _fillColorStatus(context) {
    return onPressed == null
        ? Colors.grey
        : Theme.of(context).colorScheme.primary;
  }
}
