import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/repos.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';

class RepositorySecurity extends StatefulWidget {
  const RepositorySecurity(
      {required this.repositoryName,
      required this.repositories,
      required this.password,
      required this.biometrics,
      required this.validateManualPasswordCallback,
      super.key});

  final String repositoryName;
  final ReposCubit repositories;
  final String? password;
  final bool biometrics;

  final Future<String?> Function(BuildContext context,
      {required ReposCubit repositories,
      required String repositoryName}) validateManualPasswordCallback;

  @override
  State<RepositorySecurity> createState() => _RepositorySecurityState();
}

class _RepositorySecurityState extends State<RepositorySecurity>
    with OuiSyncAppLogger {
  String? _password;

  bool _usesBiometrics = false;
  bool _previewPassword = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _password = widget.password;
      _usesBiometrics = widget.biometrics;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(S.current.titleSecurity),
        elevation: 0.0,
      ),
      body: _biometricsState());

  Widget _biometricsState() {
    return SingleChildScrollView(
        child: Container(
            child: Column(children: [
      ListTile(
        title: Text(S.current.titleRepositoryName),
        subtitle: Text(widget.repositoryName),
      ),
      Divider(),
      ..._managePassword(),
      Divider()
    ])));
  }

  List<Widget> _managePassword() {
    return [
      ListTile(
          contentPadding: EdgeInsets.only(left: 16.0),
          title: Text(S.current.messagePassword),
          subtitle: Text(_formattPassword(_password, mask: !_previewPassword)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
                flex: 0,
                child: IconButton(
                    onPressed: _password?.isNotEmpty ?? false
                        ? () =>
                            setState(() => _previewPassword = !_previewPassword)
                        : null,
                    icon: _previewPassword
                        ? const Icon(Constants.iconVisibilityOff)
                        : const Icon(Constants.iconVisibilityOn),
                    padding: EdgeInsets.zero,
                    color: Theme.of(context).primaryColor)),
            Expanded(
                flex: 0,
                child: IconButton(
                    onPressed: _password?.isNotEmpty ?? false
                        ? () async {
                            if (_password == null) return;

                            await copyStringToClipboard(_password!);
                            showSnackBar(context,
                                content: Text(
                                    S.current.messagePasswordCopiedClipboard));
                          }
                        : null,
                    icon: const Icon(Icons.copy_rounded),
                    padding: EdgeInsets.zero,
                    color: Theme.of(context).primaryColor))
          ])),
      _usesBiometrics ? _removeBiometrics() : _useBiometrics()
    ];
  }

  Widget _removeBiometrics() => Visibility(
      visible: _usesBiometrics,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.current.messageRemoveBiometricValidation),
                  trailing: const Icon(Icons.fingerprint_rounded)),
              Text(S.current.messageAlertSaveCopyPassword,
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.red)),
              Dimensions.spacingVertical,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () async => await _removeRepoBiometrics(),
                      child: Text(S.current.actionRemove))
                ],
              )
            ],
          )));

  Widget _useBiometrics() => Visibility(
      visible: !_usesBiometrics,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(children: [
            ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(S.current.messageSecureUsingBiometrics),
                trailing: Icon(Icons.fingerprint_rounded,
                    color: Theme.of(context).primaryColor),
                onTap: () async => await _addRepoBiometrics())
          ])));

  String _formattPassword(String? password, {bool mask = true}) =>
      (mask ? "*" * (password ?? '').length : password) ?? '';

  Future<void> _addRepoBiometrics() async {
    if (_password?.isEmpty ?? true) {
      await _unlockAndAddPasswordToBiometricStorage();
      return;
    }

    await _addPasswordToBiometricStorage(password: _password!);
  }

  Future<void> _unlockAndAddPasswordToBiometricStorage() async {
    final password = await widget.validateManualPasswordCallback.call(context,
        repositories: widget.repositories,
        repositoryName: widget.repositoryName);

    if (password?.isNotEmpty ?? false) {
      _useBiometricsStatus(password!);
    }
  }

  Future<void> _addPasswordToBiometricStorage(
      {required String password}) async {
    final biometricsResult = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: Biometrics.addRepositoryPassword(
            repositoryName: widget.repositoryName, password: password));

    if (biometricsResult.exception != null) {
      loggy.app(biometricsResult.exception);
      return;
    }

    _useBiometricsStatus(password);
  }

  void _useBiometricsStatus(String password) {
    setState(() {
      _usesBiometrics = true;

      _previewPassword = false;
      _password = password;
    });
  }

  Future<void> _removeRepoBiometrics() async {
    final removeBiometrics = await _removeBiometricsConfirmationDialog();
    if (!(removeBiometrics ?? false)) return;

    final biometricsResultDeletePassword =
        await Dialogs.executeFutureWithLoadingDialog(context,
            f: Biometrics.deleteRepositoryPassword(
                repositoryName: widget.repositoryName));

    if (biometricsResultDeletePassword.exception != null) {
      loggy.app(biometricsResultDeletePassword.exception);
      return;
    }

    showSnackBar(context,
        content: Text(S.current.messageBiometricValidationRemoved));

    setState(() {
      _usesBiometrics = false;
      _previewPassword = false;
    });
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
}
