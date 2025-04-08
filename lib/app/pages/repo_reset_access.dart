import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../models/auth_mode.dart';
import '../models/access_mode.dart';
import '../cubits/cubits.dart' show RepoCubit, RepoState;
import '../utils/random.dart';
import '../utils/utils.dart'
    show AppThemeExtension, Constants, Fields, LocalAuth, Settings, ThemeGetter;
import '../widgets/widgets.dart'
    show ActionsDialog, DirectionalAppBar, PositiveButton, NegativeButton;

class RepoResetAccessPage extends StatefulWidget {
  final Session session;
  final RepoCubit repo;
  final Access startAccess;
  final Settings settings;
  final _Jobs _jobs;

  // Returns `null` if nothing changes (e.g. the user presses the back button
  // before submitting any changes).
  static Future<Access> show({
    required BuildContext context,
    required Session session,
    required Settings settings,
    required RepoCubit repo,
    required Access startAccess,
  }) async {
    final route = MaterialPageRoute<Access>(
      builder: (context) => RepoResetAccessPage._(
        session: session,
        settings: settings,
        repo: repo,
        startAccess: startAccess,
      ),
    );

    return (await Navigator.push(context, route)) ?? startAccess;
  }

  RepoResetAccessPage._({
    required this.session,
    required this.settings,
    required this.repo,
    required this.startAccess,
  }) : _jobs = _Jobs();

  @override
  State<RepoResetAccessPage> createState() =>
      RepoResetAccessPageState(startAccess);
}

class RepoResetAccessPageState extends State<RepoResetAccessPage> {
  _TokenStatus _tokenStatus;
  Access currentAccess;

  RepoResetAccessPageState(this.currentAccess)
      : _tokenStatus = _InvalidTokenStatus(_InvalidTokenType.empty);

  bool get hasPendingChanges => _tokenStatus is _SubmitableTokenStatus;

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, currentAccess);
      },
      child: Scaffold(
        appBar: DirectionalAppBar(title: Text(S.current.repoResetTitle)),
        body: BlocBuilder<RepoCubit, RepoState>(
          bloc: widget.repo,
          builder: (context, repoState) {
            return Column(
              children: [
                Expanded(
                    child: ListView(children: [
                  _buildRepoNameInfo(),
                  _buildCurrentAccessModeInfo(),
                  _buildAuthMethodInfo(),
                  _buildTokenInputWidget(),
                  _buildTokenInfo(),
                  _buildActionInfo(),
                ])),
                Container(
                  // TODO: Constants should be defined globally.
                  padding: EdgeInsetsDirectional.symmetric(vertical: 18.0),
                  child: _buildSubmitButton(),
                ),
              ],
            );
          },
        ),
      ));

  // -----------------------------------------------------------------

  Widget _buildInfoWidget(
      {required String title, required String subtitle, String? warning}) {
    final dangerStyle = context.theme.appTextStyle.bodySmall
        .copyWith(color: Constants.dangerColor);

    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(subtitle),
          if (warning != null)
            SelectableText("⚠️ $warning", style: dangerStyle),
        ],
      ),
    );
  }

  Widget _buildRepoNameInfo() {
    return ListTile(
      title: Text(S.current.repoResetRepoNameLabel),
      subtitle: Text(widget.repo.name),
    );
  }

  Widget _buildCurrentAccessModeInfo() {
    String subtitle;

    switch (currentAccess) {
      case BlindAccess():
        subtitle = S.current.repoResetAccessTypeInfoBlindOrLocked;
      case ReadAccess():
        subtitle = S.current.repoResetAccessTypeInfoRead;
      case WriteAccess():
        subtitle = S.current.repoResetAccessTypeInfoWrite;
    }

    return _buildInfoWidget(
      title: S.current.repoResetAccessTypeLabel,
      subtitle: subtitle,
    );
  }

  Widget _buildAuthMethodInfo() {
    String subtitle;
    String? warning;

    switch (widget.repo.state.authMode) {
      case AuthModeBlindOrManual():
        switch (currentAccess) {
          case BlindAccess():
            subtitle = S.current.repoResetAuthInfoBlindOrLocked;
            warning = S.current.repoResetAuthInfoBlindOrLockedWarn;
          case ReadAccess():
          case WriteAccess():
            subtitle = S.current.repoResetAuthInfoLocked;
        }
      case AuthModePasswordStoredOnDevice():
        subtitle = S.current.repoResetAuthInfoPasswordIsStored;
        warning = null;
      case AuthModeKeyStoredOnDevice authMode:
        subtitle = switch (authMode.secureWithBiometrics) {
          false => S.current.repoResetAuthInfoKeyIsStored,
          true => S.current.repoResetAuthInfoKeyIsStoredAndProtected,
        };
        warning = null;
    }

    return _buildInfoWidget(
      title: S.current.repoResetAuthInfoLabel,
      subtitle: subtitle,
      warning: warning,
    );
  }

  Widget _buildTokenInfo() {
    final info = switch (_tokenStatus) {
      _SubmitableTokenStatus status =>
        _capitalized(status.inputToken.accessMode.localized),
      _SubmittedTokenStatus status =>
        _capitalized(status.inputToken.accessMode.localized),
      _NonMatchingTokenStatus status =>
        _capitalized(status.inputToken.accessMode.localized),
      _InvalidTokenStatus status => switch (status.type) {
          _InvalidTokenType.empty => "",
          _InvalidTokenType.malformed => S.current.repoResetTokenInvalid,
        },
    };

    return _buildInfoWidget(
      title: S.current.repoResetTokenTypeLabel,
      subtitle: info,
    );
  }

  // Capitalize first letter of a string
  String _capitalized(String str) {
    return str.isNotEmpty
        ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
        : str;
  }

  Widget _buildActionInfo() {
    final (action, warning) = switch (_tokenStatus) {
      _SubmitableTokenStatus status => _buildTokenStatusSubmitable(status),
      _SubmittedTokenStatus status => _buildTokenStatusSubmitted(status),
      _InvalidTokenStatus status => _buildTokenStatusInvalid(status),
      _NonMatchingTokenStatus status => _buildTokenStatusNonMatching(status),
    };

    return _buildInfoWidget(
      title: S.current.repoResetActionInfoLabel,
      subtitle: action,
      warning: warning,
    );
  }

  // -----------------------------------------------------------------

  (String, String?) _buildTokenStatusSubmitable(_SubmitableTokenStatus status) {
    final repoAccessMode = widget.repo.state.accessMode;
    final tokenAccessMode = status.inputToken.accessMode;

    final String info;
    final String? warn;

    switch ((repoAccessMode, tokenAccessMode)) {
      case (AccessMode.blind, AccessMode.blind):
        info = S.current.repoResetActionBlindToBlind;
        warn = S.current.repoResetActionBlindToBlindWarn;
      case (AccessMode.read, AccessMode.read):
      case (AccessMode.write, AccessMode.write):
        info = S.current.repoResetActionSame;
        warn = null;
      case (AccessMode.blind, AccessMode.read):
        info = S.current.repoResetActionBlindToRead;
        warn = S.current.repoResetActionBlindToReadWarn;
      case (AccessMode.blind, AccessMode.write):
      case (AccessMode.read, AccessMode.write):
        info = S.current.repoResetActionAnyToWrite;
        warn = null;
      case (AccessMode.read, AccessMode.blind):
        info = S.current.repoResetActionReadToBlind;
        warn = S.current.repoResetActionReadToBlindWarn;
      case (AccessMode.write, AccessMode.read):
        info = S.current.repoResetActionWriteToRead;
        warn = S.current.repoResetActionWriteToReadWarn;
      case (AccessMode.write, AccessMode.blind):
        info = S.current.repoResetActionWriteToBlind;
        warn = S.current.repoResetActionWriteToBlindWarn;
    }

    return (info, warn);
  }

  (String, String?) _buildTokenStatusInvalid(_InvalidTokenStatus status) {
    final String info;
    switch (status.type) {
      case _InvalidTokenType.empty:
        info = S.current.repoResetTokenEmptyInfo;
      case _InvalidTokenType.malformed:
        info = S.current.repoResetTokenInvalidInfo;
    }
    return (info, null);
  }

  (String, String?) _buildTokenStatusNonMatching(
      _NonMatchingTokenStatus status) {
    return (S.current.repoResetTokenNonMatching, null);
  }

  (String, String?) _buildTokenStatusSubmitted(_SubmittedTokenStatus status) {
    return (S.current.repoResetTokenAlreadySubmitted, null);
  }

  // -----------------------------------------------------------------

  Widget _buildTokenInputWidget() => ListTile(
          title: Fields.formTextField(
        key: Key('token-input'), // Used in tests
        context: context,
        labelText: S.current.labelRepositoryLink,
        hintText: S.current.messageRepositoryToken,
        suffixIcon: const Icon(Icons.key_rounded),
        onChanged: (input) {
          widget._jobs.addJob(() async {
            final inputToken = await _parseTokenInput(input);
            _updateTokenStatusOnTokenInputChange(inputToken);
          });
        },
      ));

  // -----------------------------------------------------------------

  Widget _buildSubmitButton() {
    Future<void> Function()? onPressed;

    switch (_tokenStatus) {
      case _SubmitableTokenStatus valid:
        onPressed = () async {
          if (await _confirmUpdateDialog()) {
            await _submit(valid.inputToken);
          }
        };
      default:
    }

    return Fields.inPageAsyncButton(
        key: Key('repo-reset-submit'),
        text: S.current.actionUpdate,
        onPressed: onPressed);
  }

  Future<bool> _confirmUpdateDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ActionsDialog(
        title: S.current.repoResetConfirmUpdateTitle,
        body: ListBody(
          children: <Widget>[
            const SizedBox(height: 20.0),
            Text(
              S.current.repoResetConfirmUpdateMessage,
              style: context.theme.appTextStyle.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Fields.dialogActions(
              buttons: [
                NegativeButton(
                  text: S.current.actionCancel,
                  onPressed: () async =>
                      await Navigator.of(context).maybePop(false),
                ),
                PositiveButton(
                  text: S.current.actionYes,
                  isDangerButton: true,
                  onPressed: () async =>
                      await Navigator.of(context).maybePop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _submit(_ValidInputToken input) async {
    final repo = widget.repo;

    // This unlocks or locks the repository in the `AccessMode` of the token.
    await repo.resetAccess(input.token);

    // Generate new local secret which will unlock the repo in the future.
    final newSetLocalSecret = SetLocalSecretKeyAndSalt(
      key: randomSecretKey(),
      salt: randomSalt(),
    );
    AccessChange readAccessChange;
    AccessChange writeAccessChange;

    switch (input.accessMode) {
      case AccessMode.blind:
        readAccessChange = AccessChangeDisable();
        writeAccessChange = AccessChangeDisable();
      case AccessMode.read:
        readAccessChange = AccessChangeEnable(newSetLocalSecret);
        writeAccessChange = AccessChangeDisable();
      case AccessMode.write:
        readAccessChange = AccessChangeDisable();
        writeAccessChange = AccessChangeEnable(newSetLocalSecret);
    }

    // Encrypt the global secret from the token using the `newLocalSecret` and
    // store it (the encrypted global secret) in the repo.
    await repo.setAccess(read: readAccessChange, write: writeAccessChange);

    final AuthMode newAuthMode;
    final Access currentAccess;

    if (readAccessChange is AccessChangeEnable ||
        writeAccessChange is AccessChangeEnable) {
      // Use a reasonably secure and convenient auth mode, the user can go to
      // the security screen to change it later.
      newAuthMode = await AuthModeKeyStoredOnDevice.encrypt(
        widget.settings.masterKey,
        newSetLocalSecret.key,
        keyOrigin: SecretKeyOrigin.random,
        // TODO: This isn't really correct, biometric (or other, e.g. pin) should be
        // available whenever the OS supports it **and** when the repository DB files
        // are stored inside a FS directory that the system protects from other app
        // access.
        secureWithBiometrics: await LocalAuth.canAuthenticate(),
      );

      if (writeAccessChange is AccessChangeEnable) {
        currentAccess = WriteAccess(newSetLocalSecret.toLocalSecret());
      } else {
        currentAccess = ReadAccess(newSetLocalSecret.toLocalSecret());
      }
    } else {
      newAuthMode = AuthModeBlindOrManual();
      currentAccess = BlindAccess();
    }

    // Store the auth mode inside the repository so it can be the next time
    // after it's locked (e.g. after the app restart).
    await repo.setAuthMode(newAuthMode);

    setState(() {
      _tokenStatus = _SubmittedTokenStatus(input);
      this.currentAccess = currentAccess;
    });
  }

  // -----------------------------------------------------------------

  void _updateTokenStatusOnTokenInputChange(_InputToken token) {
    final repoState = widget.repo.state;
    final _TokenStatus newStatus;

    switch (token) {
      case _InvalidInputToken token:
        newStatus = _InvalidTokenStatus(token.type);
      case _ValidInputToken token:
        if (repoState.infoHash != token.infoHash) {
          newStatus = _NonMatchingTokenStatus(token);
        } else {
          newStatus = _SubmitableTokenStatus(token);
        }
    }

    if (mounted) {
      setState(() {
        _tokenStatus = newStatus;
      });
    }
  }

  // -----------------------------------------------------------------

  Future<_InputToken> _parseTokenInput(String input) async {
    if (input.isEmpty) {
      return _InvalidInputToken.empty();
    }

    ShareToken token;

    try {
      token = await widget.session.validateShareToken(input);
    } catch (e) {
      return _InvalidInputToken.malformed();
    }

    final accessMode = await widget.session.getShareTokenAccessMode(token);
    final infoHash = await widget.session.getShareTokenInfoHash(token);

    return _ValidInputToken(token, accessMode, infoHash);
  }
}

//--------------------------------------------------------------------

enum _InvalidTokenType { empty, malformed }

//--------------------------------------------------------------------

sealed class _TokenStatus {}

class _SubmitableTokenStatus implements _TokenStatus {
  final _ValidInputToken inputToken;
  _SubmitableTokenStatus(this.inputToken);
}

class _SubmittedTokenStatus implements _TokenStatus {
  final _ValidInputToken inputToken;
  _SubmittedTokenStatus(this.inputToken);
}

class _NonMatchingTokenStatus implements _TokenStatus {
  final _ValidInputToken inputToken;
  _NonMatchingTokenStatus(this.inputToken);
}

class _InvalidTokenStatus implements _TokenStatus {
  final _InvalidTokenType type;
  _InvalidTokenStatus(this.type);
}

//--------------------------------------------------------------------

sealed class _InputToken {}

class _ValidInputToken implements _InputToken {
  final ShareToken token;
  final AccessMode accessMode;
  final String infoHash;

  _ValidInputToken(this.token, this.accessMode, this.infoHash);
}

class _InvalidInputToken implements _InputToken {
  final _InvalidTokenType type;

  _InvalidInputToken(this.type);

  factory _InvalidInputToken.empty() =>
      _InvalidInputToken(_InvalidTokenType.empty);
  factory _InvalidInputToken.malformed() =>
      _InvalidInputToken(_InvalidTokenType.malformed);
}

//--------------------------------------------------------------------

// Job queue with the maximum size of two: One running and one pending.
class _Jobs {
  Future<void>? runningJob;
  Future<void> Function()? pendingJob;

  _Jobs();

  void addJob(Future<void> Function() job) {
    if (runningJob == null) {
      runningJob = () async {
        await job();

        runningJob = null;

        final pj = pendingJob;
        pendingJob = null;

        if (pj != null) {
          addJob(pj);
        }
      }();
    } else {
      pendingJob = job;
    }
  }
}
