import 'dart:async';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

typedef _GestureTapAsyncCallback = Future<void> Function();

class PositiveButton extends _ActionButton {
  PositiveButton({
    this.isDangerButton = false,
    required super.text,
    required super.onPressed,
    super.focusNode,
    super.buttonConstrains = Dimensions.sizeConstrainsDialogAction,
    super.buttonsAspectRatio,
    super.key,
  }) : super(_Type.positive);

  final bool isDangerButton;

  @override
  Color? _fillColor(context) {
    return onPressed == null
        ? Colors.grey
        : isDangerButton
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
  }
}

class NegativeButton extends _ActionButton {
  NegativeButton({
    required super.text,
    required super.onPressed,
    super.focusNode,
    super.buttonConstrains = Dimensions.sizeConstrainsDialogAction,
    super.buttonsAspectRatio,
    super.key,
  }) : super(_Type.negative);

  @override
  Color? _fillColor(context) => null;
}

enum _Type { positive, negative }

abstract class _ActionButton extends StatelessWidget {
  final String? text;
  final _GestureTapAsyncCallback? onPressed;
  final double buttonsAspectRatio;
  final _Type _type;
  final BoxConstraints buttonConstrains;
  final FocusNode? focusNode;
  final ValueNotifier<bool> _enabled;

  _ActionButton(
    this._type, {
    required this.text,
    required this.onPressed,
    double? buttonsAspectRatio,
    this.focusNode,
    required this.buttonConstrains,
    super.key,
  }) : buttonsAspectRatio =
           buttonsAspectRatio ?? Dimensions.aspectRatioModalDialogButton,
       _enabled = ValueNotifier<bool>(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: AspectRatio(
                aspectRatio: buttonsAspectRatio,
                child: Container(
                  margin: _margin(),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _enabled,
                    builder: (BuildContext _, bool enabled, Widget? child) =>
                        RawMaterialButton(
                          onPressed: _getOnPressed(enabled),
                          focusNode: focusNode,
                          child: Text((text ?? '').toUpperCase()),
                          constraints: buttonConstrains,
                          elevation: Dimensions.elevationDialogAction,
                          fillColor: _fillColor(context),
                          shape: _shape(context),
                          textStyle: _textStyle(context),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Disables the button while the async `onPressed` is executing
  GestureTapCallback? _getOnPressed(bool enabled) {
    final callback = onPressed;

    if (!enabled || callback == null) return null;

    return () {
      unawaited(() async {
        _enabled.value = false;
        try {
          await callback();
        } finally {
          _enabled.value = true;
        }
      }());
    };
  }

  EdgeInsetsDirectional _margin() {
    switch (_type) {
      case _Type.positive:
        return Dimensions.marginDialogPositiveButton;
      case _Type.negative:
        return Dimensions.marginDialogNegativeButton;
    }
  }

  ShapeBorder _shape(BuildContext context) {
    switch (_type) {
      case _Type.positive:
        return const RoundedRectangleBorder(
          borderRadius: Dimensions.borderRadiusDialogPositiveButton,
        );
      case _Type.negative:
        return RoundedRectangleBorder();
    }
  }

  TextStyle? _textStyle(BuildContext context) {
    switch (_type) {
      case _Type.positive:
        return TextStyle(
          color: Theme.of(context).dialogTheme.backgroundColor,
          fontWeight: FontWeight.w500,
        );
      case _Type.negative:
        return Dimensions.textStyleDialogNegativeButton;
    }
  }

  Color? _fillColor(context);
}
