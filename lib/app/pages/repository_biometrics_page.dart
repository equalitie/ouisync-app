import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/repos.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class RepositoryBiometrics extends StatefulWidget {
  const RepositoryBiometrics(
      {required this.repositoryName,
      required this.repositories,
      required this.biometrics,
      super.key});

  final String repositoryName;
  final ReposCubit repositories;
  final bool biometrics;

  @override
  State<RepositoryBiometrics> createState() => _RepositoryBiometricsState();
}

class _RepositoryBiometricsState extends State<RepositoryBiometrics>
    with OuiSyncAppLogger {
  String? _password;

  bool _usesBiometrics = false;
  bool _managePassword = false;
  bool _previewPassword = false;
  bool _removeBiometrics = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _usesBiometrics = widget.biometrics;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Biometrics'),
        elevation: 0.0,
      ),
      body: _biometricsState());
  // Repositories without passwords are not yet implemented
  //
  // body:
  //     _password?.isEmpty ?? true ? _noPasswordState() : _biometricsState());

  // Widget _noPasswordState() {
  //   return Container(
  //       child: Column(
  //     children: [],
  //   ));
  // }

  Widget _biometricsState() {
    return SingleChildScrollView(
        child: Container(
            child: Column(
      children: [
        SwitchListTile.adaptive(
            value: _usesBiometrics,
            title: Text('Unlock using biometrics'),
            onChanged: (useBiometrics) async =>
                await _unlockUsingBiometrics(useBiometrics)),
        Divider(),
        if (_usesBiometrics) ...[..._manageBiometrics(), Divider()],
        // ...[
        //   ..._usesBiometrics ? _manageBiometrics() : _manualSecurity(),
        //   Divider()
        // ],
        ListTile(
          title: Text(
            'Password',
          ),
          subtitle: Text(_formattPassword(_password, mask: !_previewPassword)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  flex: 0,
                  child: IconButton(
                      onPressed: _managePassword
                          ? () => setState(
                              () => _previewPassword = !_previewPassword)
                          : null,
                      icon: _previewPassword
                          ? const Icon(Constants.iconVisibilityOff)
                          : const Icon(Constants.iconVisibilityOn),
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).primaryColor)),
              Expanded(
                  flex: 0,
                  child: IconButton(
                      onPressed: _managePassword
                          ? () async {
                              if (_password == null) return;

                              await copyStringToClipboard(_password!);
                              showSnackBar(context,
                                  content: Text(
                                      '"${widget.repositoryName}" password copied to the clipboard'));
                            }
                          : null,
                      icon: const Icon(Icons.copy_rounded),
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).primaryColor))
            ],
          ),
        ),
        Visibility(
            visible: _removeBiometrics,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Text(
                    'Once you navigate out of this screen you wont be able to see or copy '
                    'the password anymore; please save it in a secure place.',
                    style: TextStyle(color: Colors.red)))),
        Divider(),
        ListTile(
          title: Text('Repository name'),
          subtitle: Text(widget.repositoryName),
        ),

        Divider()
      ],
    )));
  }

  List<Widget> _manageBiometrics() {
    return [
      Visibility(
          visible: _usesBiometrics,
          child: SwitchListTile.adaptive(
              value: _managePassword,
              title: Text('Manage password'),
              onChanged: (enableManagement) async {
                if (!enableManagement) {
                  setState(() {
                    _managePassword = enableManagement;
                    _password = '';
                  });
                  return;
                }

                String? biometricPassword;
                try {
                  biometricPassword = await Biometrics.getRepositoryPassword(
                      repositoryName: widget.repositoryName);
                } catch (e) {
                  loggy.app(e);
                  return;
                }

                if (biometricPassword?.isEmpty ?? true) return;

                setState(() {
                  _password = biometricPassword;
                  _managePassword = enableManagement;
                });
              }))
    ];
  }

  String _formattPassword(String? password, {bool mask = true}) =>
      (mask ? "*" * (password ?? '').length : password) ?? '';

  // Removing a repository from the biometrics storage:
  // After authenticating using biometrics, we remove the password from the
  // biometric storage and enable the "Manage password" section so the user
  // can see / copy the password and saved it on its own.
  // We also display a meesage telling the user to do this.
  Future<void> _unlockUsingBiometrics(bool useBiometrics) async => useBiometrics
      ? await _addRepoBiometrics()
      : await _removeRepoBiometrics();

  Future<void> _addRepoBiometrics() async {
    final wasLocked =
        (widget.repositories.currentRepo?.maybeCubit?.accessMode ??
                AccessMode.blind) ==
            AccessMode.blind;

    final newAccessMode = await showDialog<AccessMode>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
              title: S.current.messageUnlockRepository,
              body: UnlockRepository(
                  context: context,
                  repositoryName: widget.repositoryName,
                  useBiometrics: true,
                  unlockRepositoryCallback: _unlockRepository),
            ));

    final biometricsAddedSuccessfully = newAccessMode != AccessMode.blind;
    if (!biometricsAddedSuccessfully) return;

    // Validating the password would unlock the repo, if successful; so if it was
    // originally locked, we need to leave it that way.
    if (wasLocked) {
      await _unlockRepository(
          repositoryName: widget.repositoryName, password: '');
    }

    setState(() => _usesBiometrics = biometricsAddedSuccessfully);
  }

  Future<void> _removeRepoBiometrics() async {
    final removeBiometrics = await _removeBiometricsDialog();
    if (!(removeBiometrics ?? false)) return;

    String? biometricPassword;
    try {
      biometricPassword = await Biometrics.getRepositoryPassword(
          repositoryName: widget.repositoryName);
    } catch (e) {
      loggy.app(e);
      return;
    }

    if (biometricPassword?.isEmpty ?? true) return;

    await Biometrics.deleteRepositoryPassword(
        repositoryName: widget.repositoryName);

    setState(() {
      _password = biometricPassword;

      _removeBiometrics = true;
      _managePassword = true;

      _usesBiometrics = false;
    });
  }

  Future<AccessMode?> _unlockRepository(
          {required String repositoryName, required String password}) async =>
      await widget.repositories
          .unlockRepository(repositoryName, password: password);

  Future<bool?> _removeBiometricsDialog() async =>
      await Dialogs.alertDialogWithActions(
          context: context,
          title: 'Remove biometrics',
          body: [
            Text('Are you sure you want to remove this repository biometrics?')
          ],
          actions: [
            TextButton(
              child: Text(S.current.actionAccept),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text(S.current.actionCancel),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ]);
}
