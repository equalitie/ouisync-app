import 'dart:io';

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart' show AppThemeExtension, ThemeGetter;

/// Dialog for adding user provided peer
class AddPeerDialog extends StatefulWidget {
  const AddPeerDialog(this.stage);

  final Stage stage;

  @override
  State<AddPeerDialog> createState() => _AddPeerDialogState();
}

class _AddPeerDialogState extends State<AddPeerDialog> {
  InternetAddress? _address;
  int? _port;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Add peer', style: context.theme.appTextStyle.titleLarge),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _address?.address,
            validator: _validateAddress,
            onChanged: _onAddressChanged,
            decoration: InputDecoration(labelText: 'IP address'),
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          TextFormField(
            initialValue: _port?.toString(),
            validator: _validatePort,
            onChanged: _onPortChanged,
            decoration: InputDecoration(labelText: 'Port'),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(child: Text(S.current.actionOK), onPressed: _submit),
      TextButton(child: Text(S.current.actionCancel), onPressed: _cancel),
    ],
  );

  String? _validateAddress(String? value) {
    if (_parseAddress(value) == null) {
      return 'Invalid IP address';
    } else {
      return null;
    }
  }

  void _onAddressChanged(String value) {
    final address = _parseAddress(value);

    if (address != null) {
      setState(() {
        _address = address;
      });
    }
  }

  String? _validatePort(String? value) {
    if (_parsePort(value) == null) {
      return 'Invalid port';
    } else {
      return null;
    }
  }

  void _onPortChanged(String value) {
    final port = _parsePort(value);

    if (port != null) {
      setState(() {
        _port = port;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.stage.maybePop(_value);
    }
  }

  Future<void> _cancel() => widget.stage.maybePop();

  String? get _value {
    final a = _address;

    if (a == null) {
      return null;
    }

    return switch (a.type) {
      InternetAddressType.IPv4 => '${a.address}:$_port',
      InternetAddressType.IPv6 => '[${a.address}]:$_port',
      _ => null,
    };
  }
}

InternetAddress? _parseAddress(String? input) {
  if (input == null) {
    return null;
  }

  // Check ip (use the InternetAddress class from dart.io for the heavy lifting)
  InternetAddress addr;

  try {
    addr = InternetAddress(input.trim());
  } catch (_) {
    return null;
  }

  if (addr.type != InternetAddressType.IPv4 &&
      addr.type != InternetAddressType.IPv6) {
    return null;
  }

  return addr;
}

int? _parsePort(String? input) {
  if (input == null) {
    return null;
  }

  final port = int.tryParse(input.trim());

  if (port == null) {
    return null;
  }

  if (port < 0 || port > 65535) {
    return null;
  }

  return port;
}
