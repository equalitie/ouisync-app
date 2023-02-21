import 'dart:async';

import 'package:flutter/material.dart';

/// Same as TextFormField but the validator function can be async.
class AsyncTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String?)? onSaved;
  final Future<String?> Function(String?) validator;
  final AutovalidateMode? autovalidateMode;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;

  const AsyncTextFormField({
    Key? key,
    this.controller,
    this.onSaved,
    required this.validator,
    this.autovalidateMode,
    this.autofocus = false,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.decoration,
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
        key: widget.key,
        controller: widget.controller,
        onSaved: widget.onSaved,
        autovalidateMode: widget.autovalidateMode,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        decoration: widget.decoration,
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
  }
}
