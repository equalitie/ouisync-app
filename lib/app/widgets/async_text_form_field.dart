import 'dart:async';

import 'package:flutter/material.dart';

/// Same as TextFormField but the validator function can be async.
class AsyncTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool? enabled;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Future<String?> Function(String?) validator;
  final AutovalidateMode? autovalidateMode;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;
  final TextStyle? style;

  const AsyncTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    required this.validator,
    this.autovalidateMode,
    this.autofocus = false,
    this.focusNode,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
    this.decoration,
    this.style,
  });

  @override
  State<AsyncTextFormField> createState() => _State();
}

class _State extends State<AsyncTextFormField> {
  String? _validationResult;
  String? _validationInput;
  bool _validating = false;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    initialValue: widget.initialValue,
    enabled: widget.enabled,
    onSaved: widget.onSaved,
    onFieldSubmitted: widget.onFieldSubmitted,
    autovalidateMode: widget.autovalidateMode,
    autofocus: widget.autofocus,
    focusNode: widget.focusNode,
    obscureText: widget.obscureText,
    textInputAction: widget.textInputAction,
    keyboardType: widget.keyboardType,
    decoration: widget.decoration,
    style: widget.style,
    validator: (_) => _validationResult,
    onChanged: _onChanged,
  );

  Future<void> _onChanged(String value) async {
    _validationInput = value;

    if (_validating) {
      return;
    }

    _validating = true;

    while (_validationInput != null) {
      final input = _validationInput;
      _validationInput = null;

      final result = await widget.validator(input);
      setState(() {
        _validationResult = result;
      });
    }

    _validating = false;

    final onChanged = widget.onChanged;

    if (onChanged != null) {
      onChanged(value);
    }
  }
}
