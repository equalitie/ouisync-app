import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../mixins/repo_actions_mixin.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class RepositorySecurityPage extends StatefulWidget {
  const RepositorySecurityPage({
    required this.settings,
    required this.repo,
    required this.currentLocalSecret,
    required this.passwordHasher,
  });

  final Settings settings;
  final RepoCubit repo;
  final LocalSecret currentLocalSecret;
  final PasswordHasher passwordHasher;

  @override
  State<RepositorySecurityPage> createState() => _RepositorySecurityState();
}

class _RepositorySecurityState extends State<RepositorySecurityPage>
    with AppLogger, RepositoryActionsMixin {
  var isBiometricsAvailable = false;

  late LocalSecretMode oldLocalSecretMode =
      widget.repo.state.authMode.localSecretMode;
  late LocalSecretMode newLocalSecretMode = oldLocalSecretMode;

  late LocalSecret oldLocalSecret = widget.currentLocalSecret;
  LocalPassword? newLocalPassword;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    unawaited(LocalAuth.canAuthenticate().then(
      (value) => setState(() {
        isBiometricsAvailable = value;
      }),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
        body: SingleChildScrollView(
          child: Padding(
            padding: Dimensions.paddingInPageMain,
            child: Form(
              key: formKey,
              canPop: false,
              onPopInvoked: (didPop) => _onPopInvoked(context, didPop),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepoSecurity(
                    localSecretMode: oldLocalSecretMode,
                    isBiometricsAvailable: isBiometricsAvailable,
                    onChanged: _onLocalSecretChanged,
                  ),
                  Dimensions.spacingVertical,
                  Center(
                    child: Fields.inPageButton(
                      text: S.current.actionUpdate,
                      onPressed:
                          _isSubmitEnabled ? () => _onSubmit(context) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _onLocalSecretChanged(
    LocalSecretMode localSecretMode,
    LocalPassword? localPassword,
  ) {
    setState(() {
      newLocalSecretMode = localSecretMode;
      newLocalPassword = localPassword;
    });
  }

  // If origin is manual, only allow submit if something actually changed.
  // If it's random, always allow it to allow regenerating the random secret key.
  bool get _isSubmitEnabled =>
      _hasPendingChanges || newLocalSecretMode.origin == SecretKeyOrigin.random;

  bool get _hasPendingChanges =>
      newLocalSecretMode != oldLocalSecretMode || newLocalPassword != null;

  void _onPopInvoked(BuildContext context, bool didPop) {
    if (didPop) {
      return;
    }

    if (!_hasPendingChanges) {
      Navigator.pop(context);
      return;
    }

    Dialogs.alertDialogWithActions(
      context: context,
      title: S.current.titleUnsavedChanges,
      body: [Text(S.current.messageUnsavedChanges)],
      actions: [
        TextButton(
            child: Text(S.current.actionCancel),
            onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
            child: Text(S.current.actionAccept),
            onPressed: () => Navigator.of(context).pop(true))
      ],
    ).then((pop) {
      if (pop ?? false) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final confirm = await _confirmSaveChanges(context);
    if (!confirm) {
      return;
    }

    final newLocalSecret = await _computeLocalSecret();
    final newAuthMode = await _computeAuthMode(newLocalSecret?.key);

    // Keep the old auth mode in case we need to revert to it on error.
    final oldAuthMode = widget.repo.state.authMode;

    // Save the new auth mode
    if (newAuthMode != null) {
      try {
        await widget.repo.setAuthMode(newAuthMode);

        setState(() {
          oldLocalSecretMode = newAuthMode.localSecretMode;
        });

        loggy.debug('Repo auth mode updated: $newAuthMode');
      } catch (e, st) {
        loggy.error(
          'Failed to update repo auth mode:',
          e,
          st,
        );

        showSnackBar(S.current.messageUpdateLocalSecretFailed);

        return;
      }
    }

    // Save the new local secret, if it changed
    //
    // NOTE: If `newAuthMode` is null then `newLocalSecret` is also null so we can never get the
    // situation where we would save a new local secret but not update the auth mode
    // accordingly.
    if (newLocalSecret != null) {
      try {
        await widget.repo.setLocalSecret(
          oldSecret: oldLocalSecret,
          newSecret: newLocalSecret,
        );

        setState(() {
          oldLocalSecret = newLocalSecret.key;
          newLocalPassword = null;
        });

        loggy.debug('Repo local secret updated');
      } catch (e, st) {
        loggy.error(
          'Failed to update repo local secret:',
          e,
          st,
        );

        showSnackBar(S.current.messageUpdateLocalSecretFailed);

        // Revert to the old auth mode
        await widget.repo.setAuthMode(oldAuthMode);

        return;
      }
    }

    showSnackBar(S.current.messageUpdateLocalSecretOk);
  }

  Future<bool> _confirmSaveChanges(BuildContext context) async {
    final message = S.current.messageConfirmIrreversibleChange;

    final saveChanges = await Dialogs.alertDialogWithActions(
      context: context,
      title: S.current.titleSaveChanges,
      body: [Text(message, style: context.theme.appTextStyle.bodyMedium)],
      actions: [
        TextButton(
            child: Text(S.current.actionCancel),
            onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
            child: Text(S.current.actionAccept),
            onPressed: () => Navigator.of(context).pop(true))
      ],
    );

    return saveChanges ?? false;
  }

  Future<LocalSecretKeyAndSalt?> _computeLocalSecret() async {
    switch (newLocalSecretMode.origin) {
      case SecretKeyOrigin.manual:
        final localPassword = newLocalPassword;
        if (localPassword == null) {
          return null;
        }

        return await widget.passwordHasher.hashPassword(localPassword);
      case SecretKeyOrigin.random:
        return LocalSecretKeyAndSalt.random();
    }
  }

  Future<AuthMode?> _computeAuthMode(LocalSecretKey? localSecretKey) async {
    if (newLocalSecretMode.isStored) {
      if (localSecretKey != null) {
        return await AuthModeKeyStoredOnDevice.encrypt(
          widget.settings.masterKey,
          localSecretKey,
          keyOrigin: newLocalSecretMode.origin,
          secureWithBiometrics: newLocalSecretMode.isSecuredWithBiometrics,
        );
      } else {
        final oldAuthMode = widget.repo.state.authMode;
        switch (oldAuthMode) {
          case AuthModeKeyStoredOnDevice():
            return oldAuthMode.copyWith(
              keyOrigin: newLocalSecretMode.origin,
              secureWithBiometrics: newLocalSecretMode.isSecuredWithBiometrics,
            );
          case AuthModeBlindOrManual():
          case AuthModePasswordStoredOnDevice():
            return null;
        }
      }
    } else {
      return AuthModeBlindOrManual();
    }
  }
}
