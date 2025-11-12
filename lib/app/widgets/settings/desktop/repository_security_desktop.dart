import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../utils/platform/platform.dart';
import '../../../utils/utils.dart';

class RepositorySecurityDesktop extends StatefulWidget {
  const RepositorySecurityDesktop({required this.onRepositorySecurity});

  final Future<String?> Function(dynamic context) onRepositorySecurity;

  @override
  State<RepositorySecurityDesktop> createState() =>
      _RepositorySecurityDesktopState();
}

class _RepositorySecurityDesktopState extends State<RepositorySecurityDesktop> {
  String? _password;
  bool _previewPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [Text(S.current.titleSecurity, textAlign: TextAlign.start)],
        ),
        ListTile(
          leading: const Icon(Icons.password_rounded),
          title: _isPasswordAvailable(_password)
              ? Text(S.current.messagePassword)
              : null,
          subtitle: _isPasswordAvailable(_password)
              ? _passwordLabel(context)
              : _authenticationPlaceholder(context),
        ),
      ],
    );
  }

  Widget _authenticationPlaceholder(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.symmetric(vertical: 20.0),
    child: TextButton.icon(
      onPressed: () async => await _unlockSecurity(context),
      icon: const Icon(Icons.lock_outline_rounded),
      label: Text(S.current.messageAuthenticate),
    ),
  );

  Widget _passwordLabel(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: PlatformValues.getFormFactorMaxWidth(context) * 0.5,
        padding: EdgeInsetsDirectional.all(10.0), //Dimensions.paddingGreyBox,
        margin: EdgeInsetsDirectional.symmetric(vertical: 5.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(Dimensions.radiusSmall),
          ),
          color: Constants.inputBackgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(maskPassword(_password, mask: !_previewPassword)),
            ),
            Expanded(
              flex: 0,
              child: IconButton(
                icon: _previewPassword
                    ? const Icon(Constants.iconVisibilityOff)
                    : const Icon(Constants.iconVisibilityOn),
                padding: EdgeInsetsDirectional.zero,
                color: Theme.of(context).primaryColor,
                onPressed: _isPasswordAvailable(_password)
                    ? () => setState(() => _previewPassword = !_previewPassword)
                    : null,
              ),
            ),
          ],
        ),
      ),
      _passwordActions(),
    ],
  );

  Widget _passwordActions() => Wrap(
    children: [
      PopupMenuButton(
        icon: const Icon(Icons.more_horiz_rounded),
        position: PopupMenuPosition.under,
        itemBuilder: (context) => <PopupMenuEntry<PasswordItem>>[
          PopupMenuItem<PasswordItem>(
            value: PasswordItem.copy,
            child: Text(S.current.popupMenuItemCopyPassword),
            onTap: () async {
              if (_password == null) return;
              if (_password!.isEmpty) return;

              await copyStringToClipboard(_password!);
              showSnackBar(context, S.current.messagePasswordCopiedClipboard);
            },
          ),
          const PopupMenuDivider(),
          PopupMenuItem<PasswordItem>(
            value: PasswordItem.change,
            child: Text(S.current.popupMenuItemChangePassword),
            onTap: () {},
          ),
        ],
      ),
    ],
  );

  bool _isPasswordAvailable(String? password) =>
      password != null && password.isNotEmpty;

  Future<void> _unlockSecurity(BuildContext context) async {
    final password = await widget.onRepositorySecurity(context);
    setState(() => _password = password);
  }
}

enum PasswordItem { copy, change }
