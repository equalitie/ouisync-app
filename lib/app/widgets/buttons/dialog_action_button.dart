import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../async_callback_builder.dart';

class PositiveButton extends _ActionButton {
  final bool dangerous;

  PositiveButton({
    required super.text,
    required super.onPressed,
    this.dangerous = false,
    super.focusNode,
    super.constrains = Dimensions.sizeConstrainsDialogAction,
    super.key,
  });
}

class NegativeButton extends _ActionButton {
  NegativeButton({
    required super.text,
    required super.onPressed,
    super.focusNode,
    super.constrains = Dimensions.sizeConstrainsDialogAction,
    super.key,
  });
}

sealed class _ActionButton extends StatelessWidget {
  final String? text;
  final AsyncCallback? onPressed;
  final BoxConstraints constrains;
  final FocusNode? focusNode;

  _ActionButton({
    required this.text,
    required this.onPressed,
    required this.constrains,
    this.focusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: _margin(),
    child: AsyncCallbackBuilder(
      callback: onPressed,
      builder: (context, callback) => RawMaterialButton(
        onPressed: callback,
        focusNode: focusNode,
        child: Text((text ?? '').toUpperCase()),
        constraints: constrains,
        elevation: Dimensions.elevationDialogAction,
        fillColor: _fillColor(context),
        shape: _shape(context),
        textStyle: _textStyle(context),
      ),
    ),
  );

  EdgeInsetsDirectional _margin() => switch (this) {
    PositiveButton() => Dimensions.marginDialogPositiveButton,
    NegativeButton() => Dimensions.marginDialogNegativeButton,
  };

  ShapeBorder _shape(BuildContext context) => switch (this) {
    PositiveButton() => const RoundedRectangleBorder(
      borderRadius: Dimensions.borderRadiusDialogPositiveButton,
    ),
    NegativeButton() => RoundedRectangleBorder(),
  };

  TextStyle? _textStyle(BuildContext context) => switch (this) {
    PositiveButton() => TextStyle(
      color: Theme.of(context).dialogTheme.backgroundColor,
      fontWeight: FontWeight.w500,
    ),
    NegativeButton() => Dimensions.textStyleDialogNegativeButton,
  };

  Color? _fillColor(context) => switch (this) {
    PositiveButton(dangerous: final dangerous) =>
      onPressed == null
          ? Colors.grey
          : dangerous
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
    NegativeButton() => null,
  };
}
