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
      required this.hasBiometrics,
      required this.validateManualPasswordCallback,
      super.key});

  final String repositoryName;
  final String databaseId;
  final ReposCubit repositories;
  final String? password;
  final bool hasBiometrics;

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
  bool _previewPassword = false;

  String? _newPassword;
  bool _previewNewPassword = false;

  bool _isNewPasswordGenerated = false;

  bool _hasBiometrics = false;
  bool _useBiometricState = false;
  bool _showRemoveBiometricsWarning = false;

  bool _isUnsavedNewPassword = false;
  bool _isUnsavedBiometrics = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _password = widget.password;

      _hasBiometrics = widget.hasBiometrics;
      _useBiometricState = widget.hasBiometrics;

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
    if (_hasUnsavedChanges) {
      final discardChanges = await _discardUnsavedChangesAlert();
      return discardChanges ?? false;
    }

    return true;
  }

  Future<bool?> _discardUnsavedChangesAlert() async =>
      await Dialogs.alertDialogWithActions(
          context: context,
          title: S.current.titleUnsavedChanges,
          body: [
            Text(S.current.messageUnsavedChanges)
          ],
          actions: [
            TextButton(
              child: Text(S.current.actionDiscard),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text(S.current.actionCancel),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ]);

  Widget _securityState() => SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(children: [
            _repositoryName(),
            Divider(),
            ..._managePassword(),
            Divider(),
            ..._manageBiometrics(),
            Divider(),
            _securityActions()
          ])));

  Widget _repositoryName() => ListTile(
        title: Text(S.current.titleRepositoryName),
        subtitle: Text(widget.repositoryName),
      );

  List<Widget> _managePassword() => [
        ListTile(
            leading: const Icon(Icons.password_rounded, color: Colors.black),
            title: Text(S.current.messagePassword),
            subtitle:
                Text(_formattPassword(_password, mask: !_previewPassword)),
            trailing: _passwordActions()),
        ListTile(
            leading: Icon(Icons.lock_reset_rounded, color: Colors.black),
            title: Badge(
                showBadge: _isUnsavedNewPassword,
                padding: EdgeInsets.all(2.0),
                alignment: Alignment.centerLeft,
                position: BadgePosition.topEnd(),
                child: Text(S.current.titleChangePassword)),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.black),
            onTap: () async => await _getNewPassword()),
        Visibility(
            visible: _newPassword?.isNotEmpty ?? false,
            child: ListTile(
                dense: false,
                visualDensity: VisualDensity.compact,
                style: ListTileStyle.drawer,
                tileColor: Colors.blueGrey.shade100,
                title: Text(S.current.messageNewPassword),
                subtitle: Text(
                    _formattPassword(_newPassword, mask: !_previewNewPassword)),
                trailing: _newPasswordActions())),
        Visibility(
            visible: _newPassword?.isNotEmpty ?? false,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                  padding: EdgeInsets.only(right: 16.0),
                  child: TextButton(
                      child: Text(S.current.actionClear),
                      onPressed: (() {
                        setState(() {
                          _newPassword = null;
                          _previewNewPassword = false;

                          _isUnsavedNewPassword = false;
                        });

                        _updateUnsavedChanges();
                      })))
            ]))
      ];

  String _formattPassword(String? password, {bool mask = true}) =>
      (mask ? "*" * (password ?? '').length : password) ?? '';

  Widget _passwordActions() => Wrap(children: [
        IconButton(
            icon: _previewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            onPressed: _password?.isNotEmpty ?? false
                ? () => setState(() => _previewPassword = !_previewPassword)
                : null),
        IconButton(
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            onPressed: _password?.isNotEmpty ?? false
                ? () async {
                    if (_password == null) return;

                    await copyStringToClipboard(_password!);
                    showSnackBar(context,
                        message: S.current.messagePasswordCopiedClipboard);
                  }
                : null)
      ]);

  Future<void> _getNewPassword() async {
    assert(_password != null, 'The password is null');

    if (_password == null) return;

    final setPasswordResult = await showDialog<SetPasswordResult?>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.titleSetPasswordFor,
            body: SetPassword(
                context: context,
                cubit: widget.repositories,
                repositoryName: widget.repositoryName,
                currentPassword: _password!,
                newPassword: _newPassword,
                generated: _isNewPasswordGenerated)));

    if (setPasswordResult == null) return;

    if (setPasswordResult.newPassword.isEmpty) return;

    setState(() {
      _newPassword = setPasswordResult.newPassword;
      _isNewPasswordGenerated = setPasswordResult.generated;

      _previewNewPassword = false;
      _isUnsavedNewPassword = true;
    });

    _updateUnsavedChanges();
  }

  Widget _newPasswordActions() => Wrap(children: [
        IconButton(
            icon: _previewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            onPressed: _newPassword?.isNotEmpty ?? false
                ? () =>
                    setState(() => _previewNewPassword = !_previewNewPassword)
                : null),
        IconButton(
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            onPressed: _newPassword?.isNotEmpty ?? false
                ? () async {
                    if (_newPassword == null) return;

                    await copyStringToClipboard(_newPassword!);
                    showSnackBar(context,
                        message: S.current.messageNewPasswordCopiedClipboard);
                  }
                : null)
      ]);

  List<Widget> _manageBiometrics() => [
        SwitchListTile.adaptive(
            value: _useBiometricState,
            secondary: Icon(Icons.fingerprint_rounded, color: Colors.black),
            title: Badge(
                showBadge: _isUnsavedBiometrics,
                padding: EdgeInsets.all(2.0),
                alignment: Alignment.centerLeft,
                position: BadgePosition.topEnd(),
                child: Text(S.current.messageSecureUsingBiometrics)),
            onChanged: ((useBiometrics) {
              setState(() {
                _useBiometricState = useBiometrics;

                _showRemoveBiometricsWarning =
                    !useBiometrics && (!useBiometrics && _hasBiometrics);

                _isUnsavedBiometrics = useBiometrics != _hasBiometrics;
              });

              _updateUnsavedChanges();
            })),
        Visibility(
            visible: _showRemoveBiometricsWarning,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                child: Text(S.current.messageAlertSaveCopyPassword,
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.red))))
      ];

  Widget _securityActions() => Visibility(
      visible: _hasUnsavedChanges,
      child: Container(
          padding: EdgeInsets.only(top: 30.0, right: 18.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
                child: Text(S.current.actionSaveChanges),
                onPressed: (() async {
                  final saveChanges = await _confirmSaveChanges();

                  if (saveChanges == null) return;

                  if (!saveChanges) return;

                  if (_isUnsavedNewPassword) {
                    assert(_newPassword != null, '_newPassword is null');

                    final metaInfo = widget.repositories.currentRepo!.metaInfo;
                    final changePasswordResult =
                        await Dialogs.executeFutureWithLoadingDialog(context,
                            f: widget.repositories.setReadWritePassword(
                                metaInfo, _newPassword!, null));

                    if (!changePasswordResult) {
                      showSnackBar(context,
                          message: S.current.messageErrorChangingPassword);
                      return;
                    }

                    setState(() {
                      _password = _newPassword;
                      _previewPassword = false;

                      _newPassword = null;
                      _previewNewPassword = false;

                      _isUnsavedNewPassword = false;
                    });

                    _updateUnsavedChanges();
                  }

                  if (_isUnsavedBiometrics) {
                    assert(_password != null, '_password is null');

                    _useBiometricState
                        ? await _addPasswordToBiometricStorage(
                            password: _password!)
                        : await _removeRepoBiometrics();
                  }
                }))
          ])));

  Future<bool?> _confirmSaveChanges() async {
    final passwordChangedChunk = ((_newPassword?.isNotEmpty ?? false)
            ? '${S.current.messageNewPassword}\n'
            : '')
        .trimLeft();
    final biometricsChunk = (_useBiometricState != _hasBiometrics
            ? _useBiometricState
                ? S.current.messageSecureUsingBiometrics
                : S.current.messageRemoveBiometrics
            : '')
        .trimLeft();
    final changes = '$passwordChangedChunk$biometricsChunk';

    final saveChanges = await Dialogs.alertDialogWithActions(
        context: context,
        title: S.current.titleSaveChanges,
        body: [
          Text(S.current.messageSavingChanges(changes))
        ],
        actions: [
          TextButton(
            child: Text(S.current.actionSave),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text(S.current.actionCancel),
            onPressed: () => Navigator.of(context).pop(false),
          )
        ]);

    return saveChanges;
  }

  Future<void> _addPasswordToBiometricStorage(
      {required String password}) async {
    final biometricsResult = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: Biometrics.addRepositoryPassword(
            databaseId: widget.databaseId, password: password));

    if (biometricsResult.exception != null) {
      loggy.app(biometricsResult.exception);
      return;
    }

    setState(() {
      _useBiometricState = true;
      _showRemoveBiometricsWarning = false;

      _isUnsavedBiometrics = false;

      _previewPassword = false;
      _password = password;
    });

    _updateUnsavedChanges();
  }

  Future<void> _removeRepoBiometrics() async {
    final removeBiometrics = await _removeBiometricsConfirmationDialog();
    if (!(removeBiometrics ?? false)) return;

    final biometricsResultDeletePassword =
        await Dialogs.executeFutureWithLoadingDialog(context,
            f: Biometrics.deleteRepositoryPassword(
                databaseId: widget.databaseId));

    if (biometricsResultDeletePassword.exception != null) {
      loggy.app(biometricsResultDeletePassword.exception);
      return;
    }

    showSnackBar(context, message: S.current.messageBiometricValidationRemoved);

    setState(() {
      _useBiometricState = false;
      _showRemoveBiometricsWarning = true;

      _isUnsavedBiometrics = false;

      _previewPassword = false;
    });

    _updateUnsavedChanges();
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

  _updateUnsavedChanges() {
    final unsavedChanges = _isUnsavedNewPassword || _isUnsavedBiometrics;
    setState(() => _hasUnsavedChanges = unsavedChanges);
  }
}
