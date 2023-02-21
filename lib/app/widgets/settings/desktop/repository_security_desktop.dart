import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../utils/platform/platform.dart';
import '../../../utils/utils.dart';

class RepositorySecurityDesktop extends StatefulWidget {
  const RepositorySecurityDesktop({required this.onRepositorySecurity});

  final Future<void> Function(dynamic context) onRepositorySecurity;

  @override
  State<RepositorySecurityDesktop> createState() =>
      _RepositorySecurityDesktopState();
}

class _RepositorySecurityDesktopState extends State<RepositorySecurityDesktop> {
  String _password = 'dummyPassword';
  bool _previewPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [Text('Security', textAlign: TextAlign.start)]),
      ListTile(
          leading: const Icon(Icons.password_rounded),
          title: _password.isEmpty ? null : Text(S.current.messagePassword),
          subtitle: _password.isEmpty
              ? _authenticationPlaceholder(context)
              : _passwordLabel(context))
    ]);
  }

  Widget _authenticationPlaceholder(BuildContext context) => Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: TextButton.icon(
          onPressed: () =>
              widget.onRepositorySecurity(context), //_unlockSecurity,
          icon: const Icon(Icons.lock_outline_rounded),
          label: Text('Authenticate')));

  Widget _passwordLabel(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: PlatformValues.getFormFactorMaxWidth(context) * 0.5,
            padding: EdgeInsets.all(10.0), //Dimensions.paddingGreyBox,
            margin: EdgeInsets.symmetric(vertical: 5.0),
            decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                color: Constants.inputBackgroundColor),
            child: Row(children: [
              Expanded(
                  child:
                      Text(maskPassword(_password, mask: !_previewPassword))),
              Expanded(
                  flex: 0,
                  child: IconButton(
                      icon: _previewPassword
                          ? const Icon(Constants.iconVisibilityOff)
                          : const Icon(Constants.iconVisibilityOn),
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).primaryColor,
                      onPressed: _password.isNotEmpty
                          ? () => setState(
                              () => _previewPassword = !_previewPassword)
                          : null))
            ])),
        _passwordActions()
      ]);

  Widget _passwordActions() => Wrap(children: [
        PopupMenuButton(
            icon: const Icon(Icons.more_horiz_rounded),
            position: PopupMenuPosition.under,
            itemBuilder: (context) => <PopupMenuEntry<PasswordItem>>[
                  PopupMenuItem<PasswordItem>(
                      value: PasswordItem.copy,
                      child: Text('Copy password'),
                      onTap: () {}),
                  const PopupMenuDivider(),
                  PopupMenuItem<PasswordItem>(
                      value: PasswordItem.change,
                      child: Text('Change password'),
                      onTap: () {})
                ])
      ]);

  void _unlockSecurity() {}
}

enum PasswordItem { copy, change }
