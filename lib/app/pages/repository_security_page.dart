import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/repos.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class RepositorySecurity extends StatefulWidget {
  const RepositorySecurity(
      {required this.repositoryName,
      required this.databaseId,
      required this.repositories,
      required this.password,
      required this.biometrics,
      required this.validateManualPasswordCallback,
      super.key});

  final String repositoryName;
  final String databaseId;
  final ReposCubit repositories;
  final String? password;
  final bool biometrics;

  final Future<String?> Function(BuildContext context,
      {required ReposCubit repositories,
      required String databaseId,
      required String repositoryName}) validateManualPasswordCallback;

  @override
  State<RepositorySecurity> createState() => _RepositorySecurityState();
}

class _RepositorySecurityState extends State<RepositorySecurity>
    with OuiSyncAppLogger {
  String? _password;

  String? _newPassword;
  bool _generated = false;

  bool _previewPassword = false;
  bool _previewNewPassword = false;

  bool _usesBiometrics = false;
  bool _addBiometricState = false;
  bool _showRemoveBiometricsWarning = false;

  bool _unsavedChanges = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _password = widget.password;

      _usesBiometrics = widget.biometrics;
      _addBiometricState = widget.biometrics;

      _showRemoveBiometricsWarning = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(S.current.titleSecurity),
        elevation: 0.0,
      ),
      body: WillPopScope(child: _securityState(), onWillPop: _onBackPressed));

  Future<bool> _onBackPressed() async {
    if (_unsavedChanges) {
      final discardChanges = await _discardUnsavedChangesAlert();
      return discardChanges ?? false;
    }

    return true;
  }

  Future<bool?> _discardUnsavedChangesAlert() async =>
      await Dialogs.alertDialogWithActions(
          context: context,
          title: 'Unsaved changes',
          body: [
            Text('You have unsaved changes.\n\nDo you want to discard them?')
          ],
          actions: [
            TextButton(
              child: Text('Discard'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ]);

  Widget _securityState() {
    return SingleChildScrollView(
        child: Container(
            child: Column(children: [
      ListTile(
        title: Text(S.current.titleRepositoryName),
        subtitle: Text(widget.repositoryName),
      ),
      Divider(),
      ..._managePassword(),
      Divider(),
      ..._biometrics(),
      Divider(),
      _securityActions()
    ])));
  }

  List<Widget> _managePassword() => [
        ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            leading: const Icon(Icons.password_rounded, color: Colors.black),
            title: Text(S.current.messagePassword),
            subtitle:
                Text(_formattPassword(_password, mask: !_previewPassword)),
            trailing: _passwordActions()),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_reset_rounded, color: Colors.black),
                  title: Badge(
                      showBadge: _newPassword != null,
                      padding: EdgeInsets.all(2.0),
                      alignment: Alignment.centerLeft,
                      position: BadgePosition.topEnd(top: 0.0, end: 55.0),
                      child: Text('Change password')),
                  trailing:
                      Icon(Icons.chevron_right_rounded, color: Colors.black),
                  onTap: () async => await _getNewPassword())
            ])),
        Visibility(
            visible: _newPassword?.isNotEmpty ?? false,
            child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                dense: false,
                visualDensity: VisualDensity.compact,
                style: ListTileStyle.drawer,
                tileColor: Colors.blueGrey.shade100,
                title: Text('New password'),
                subtitle: Text(
                    _formattPassword(_newPassword, mask: !_previewNewPassword)),
                trailing: _newPasswordActions())),
        Visibility(
            visible: _newPassword?.isNotEmpty ?? false,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextButton(
                      onPressed: (() {
                        setState(() {
                          _newPassword = null;
                          _previewNewPassword = false;
                        });

                        _showActionSection();
                      }),
                      child: Text('Clear')))
            ]))
      ];

  String _formattPassword(String? password, {bool mask = true}) =>
      (mask ? "*" * (password ?? '').length : password) ?? '';

  Widget _passwordActions() => Wrap(children: [
        IconButton(
            onPressed: _password?.isNotEmpty ?? false
                ? () => setState(() => _previewPassword = !_previewPassword)
                : null,
            icon: _previewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor),
        IconButton(
            onPressed: _password?.isNotEmpty ?? false
                ? () async {
                    if (_password == null) return;

                    await copyStringToClipboard(_password!);
                    showSnackBar(context,
                        content:
                            Text(S.current.messagePasswordCopiedClipboard));
                  }
                : null,
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor)
      ]);

  Future<void> _getNewPassword() async {
    assert(_password != null, 'The password is null');

    if (_password == null) return;

    final setPasswordResult = await showDialog<SetPasswordResult?>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: 'Set password for',
            body: SetPassword(
                context: context,
                cubit: widget.repositories,
                repositoryName: widget.repositoryName,
                currentPassword: _password!,
                newPassword: _newPassword,
                generated: _generated)));

    if (setPasswordResult == null) return;

    if (setPasswordResult.newPassword.isNotEmpty) {
      final newPassword = setPasswordResult.newPassword;

      setState(() {
        _newPassword = newPassword.isEmpty ? null : newPassword;
        _generated = setPasswordResult.generated;

        _previewNewPassword = false;
      });

      _showActionSection();
    }
  }

  Widget _newPasswordActions() => Wrap(children: [
        IconButton(
            onPressed: _newPassword?.isNotEmpty ?? false
                ? () =>
                    setState(() => _previewNewPassword = !_previewNewPassword)
                : null,
            icon: _previewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor),
        IconButton(
            onPressed: _newPassword?.isNotEmpty ?? false
                ? () async {
                    if (_newPassword == null) return;

                    await copyStringToClipboard(_newPassword!);
                    showSnackBar(context,
                        content: Text('New password copied to clipboard'));
                  }
                : null,
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor)
      ]);

  List<Widget> _biometrics() => [
        SwitchListTile.adaptive(
            value: _addBiometricState,
            secondary: Icon(Icons.fingerprint_rounded, color: Colors.black),
            title: Badge(
                showBadge: _addBiometricState != _usesBiometrics,
                padding: EdgeInsets.all(2.0),
                alignment: Alignment.centerLeft,
                position: BadgePosition.topEnd(top: 0.0, end: 55.0),
                child: Text(S.current.messageSecureUsingBiometrics)),
            onChanged: ((noBiometrics) {
              setState(() {
                _addBiometricState = noBiometrics;

                _showRemoveBiometricsWarning =
                    !noBiometrics && (!noBiometrics && _usesBiometrics);
              });

              _showActionSection();
            })),
        Visibility(
            visible: _showRemoveBiometricsWarning,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Text(S.current.messageAlertSaveCopyPassword,
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.red))))
      ];

  Widget _securityActions() => Visibility(
      visible: _unsavedChanges,
      child: Container(
          padding: EdgeInsets.only(left: 16.0, top: 30.0, right: 16.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
                child: Text('Save changes'),
                onPressed: (() async {
                  final saveChanges = await _confirmSaveChanges();

                  if (saveChanges == null) return;

                  if (!saveChanges) return;

                  final changePassword = _newPassword?.isNotEmpty ?? false;
                  final updateBiometrics =
                      _addBiometricState != _usesBiometrics ||
                          (changePassword && _usesBiometrics);

                  if (changePassword) {
                    assert(_newPassword != null, '_newPassword is null');

                    final metaInfo = widget.repositories.currentRepo!.metaInfo;
                    final changePasswordResult = await widget.repositories
                        .setReadWritePassword(metaInfo, _newPassword!, null);

                    if (!changePasswordResult) {
                      showSnackBar(context,
                          content: Text(
                              'There was a problem changing the password. Please try again'));
                      return;
                    }

                    setState(() {
                      _password = _newPassword;
                      _previewPassword = false;

                      _newPassword = null;
                      _previewNewPassword = false;
                    });
                  }

                  if (updateBiometrics) {
                    assert(_password != null, '_password is null');

                    final biometricsResult = _addBiometricState
                        ? await _addPasswordToBiometricStorage(
                            password: _password!)
                        : await _removeRepoBiometrics();

                    if (biometricsResult == null) return;

                    if (!biometricsResult) return;
                  }
                }))
          ])));

  Future<bool?> _confirmSaveChanges() async {
    final passwordChangedChunk =
        ((_newPassword?.isNotEmpty ?? false) ? '- Change password\n' : '')
            .trimLeft();
    final biometricsChunk = (_addBiometricState != _usesBiometrics
            ? _addBiometricState
                ? '- Secure using biometrics'
                : '- Remove biometrics'
            : '')
        .trimLeft();
    final changes = '$passwordChangedChunk$biometricsChunk';

    final saveChanges = await Dialogs.alertDialogWithActions(
        context: context,
        title: 'Save changes',
        body: [
          Text('Save the following changes:\n\n$changes')
        ],
        actions: [
          TextButton(
            child: Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
          )
        ]);

    return saveChanges;
  }

  Future<bool?> _addPasswordToBiometricStorage(
      {required String password}) async {
    final biometricsResult = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: Biometrics.addRepositoryPassword(
            databaseId: widget.databaseId, password: password));

    if (biometricsResult.exception != null) {
      loggy.app(biometricsResult.exception);
      return false;
    }

    setState(() {
      _addBiometricState = true;
      _showRemoveBiometricsWarning = false;

      _previewPassword = false;
      _password = password;
    });

    _showActionSection();

    return true;
  }

  Future<bool> _removeRepoBiometrics() async {
    final removeBiometrics = await _removeBiometricsConfirmationDialog();
    if (!(removeBiometrics ?? false)) return false;

    final biometricsResultDeletePassword =
        await Dialogs.executeFutureWithLoadingDialog(context,
            f: Biometrics.deleteRepositoryPassword(
                databaseId: widget.databaseId));

    if (biometricsResultDeletePassword.exception != null) {
      loggy.app(biometricsResultDeletePassword.exception);
      return false;
    }

    showSnackBar(context,
        content: Text(S.current.messageBiometricValidationRemoved));

    setState(() {
      _addBiometricState = false;
      _showRemoveBiometricsWarning = true;

      _previewPassword = false;
    });

    _showActionSection();

    return true;
  }

  Future<bool?> _removeBiometricsConfirmationDialog() async =>
      await Dialogs.alertDialogWithActions(
          context: context,
          title: S.current.titleRemoveBiometrics,
          body: [
            Text(S.current.messageRemoveBiometricsConfirmation)
          ],
          actions: [
            TextButton(
              child: Text(S.current.actionRemove),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text(S.current.actionCancel),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ]);

  void _showActionSection() {
    final show = (_newPassword?.isNotEmpty ?? false) ||
        (_addBiometricState != _usesBiometrics);

    setState(() => _unsavedChanges = show);
  }
}
