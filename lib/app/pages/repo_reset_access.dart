import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_mode.dart';
import '../models/access_mode.dart';
import '../cubits/cubits.dart' show RepoCubit, RepoState;
import '../utils/utils.dart'
    show AppThemeExtension, Constants, Fields, LocalAuth, Settings, ThemeGetter;
import '../widgets/widgets.dart' show DirectionalAppBar;

class RepoResetAccessPage extends StatefulWidget {
  final Settings settings;
  final RepoCubit repo;
  final _Jobs _jobs;

  // Returns `null` if nothing changes (e.g. the user presses the back button
  // before submitting any changes).
  static Future<Access?> show(
      BuildContext context, RepoCubit repo, Settings settings) {
    final route = MaterialPageRoute<Access>(
        builder: (context) =>
            RepoResetAccessPage._(settings: settings, repo: repo));

    Navigator.push(context, route);

    return route.popped;
  }

  RepoResetAccessPage._({
    required this.settings,
    required this.repo,
  }) : _jobs = _Jobs();

  @override
  State<RepoResetAccessPage> createState() => _State();
}

class _State extends State<RepoResetAccessPage> {
  _TokenStatus tokenStatus;
  // Null means nothing has changed.
  Access? result;

  _State() : tokenStatus = _InvalidTokenStatus(_InvalidTokenType.empty);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DirectionalAppBar(title: Text("Reset repository access")),
        body: BlocBuilder<RepoCubit, RepoState>(
          bloc: widget.repo,
          builder: (context, repoState) {
            return ListView(children: [
              _buildRepoNameInfo(),
              _buildCurrentAccessModeInfo(),
              _buildAuthMethodInfo(),
              _buildTokenInputWidget(),
              _buildTokenInfo(),
              _buildActionInfo(),
              _buildSubmitButton(),
            ]);
          },
        ),
      );

  // -----------------------------------------------------------------

  Widget _buildInfoWidget(
      {required String title, required String subtitle, String? warning}) {
    final warningStyle = context.theme.appTextStyle.bodySmall
        .copyWith(color: Constants.warningColor);

    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(subtitle),
          if (warning != null) SelectableText(warning, style: warningStyle),
        ],
      ),
    );
  }

  Widget _buildRepoNameInfo() {
    return ListTile(
      title: Text("Repository name"),
      subtitle: Text(widget.repo.name),
    );
  }

  Widget _buildCurrentAccessModeInfo() {
    String subtitle;

    switch (widget.repo.state.accessMode) {
      case AccessMode.blind:
        subtitle = "Blind or locked";
      case AccessMode.read:
        subtitle = "Read";
      case AccessMode.write:
        subtitle = "Write";
    }

    return _buildInfoWidget(
      title: "Repository access type",
      subtitle: subtitle,
    );
  }

  Widget _buildAuthMethodInfo() {
    String subtitle;
    String? warning;

    switch (widget.repo.state.authMode) {
      case AuthModeBlindOrManual():
        subtitle = "Blind or protected by a local password";
        warning = "The application cannot tell the difference";
      case AuthModePasswordStoredOnDevice():
        subtitle = "Password stored on device";
        warning = null;
      case AuthModeKeyStoredOnDevice authMode:
        subtitle = switch (authMode.secureWithBiometrics) {
          false => "Key is stored on this device",
          true =>
            "Key is stored on this device and additional verification is needed to open the repository",
        };
        warning = null;
    }

    return _buildInfoWidget(
      title: "Authentication method",
      subtitle: subtitle,
      warning: warning,
    );
  }

  Widget _buildTokenInfo() {
    final info = switch (tokenStatus) {
      _SubmitableTokenStatus status =>
        _localizedAccessModeName(status.inputToken.accessMode),
      _InvalidTokenStatus status => switch (status.type) {
          _InvalidTokenType.empty => "",
          _InvalidTokenType.malformed => "Invalid",
        },
      _NonMatchingTokenStatus status =>
        _localizedAccessModeName(status.inputToken.accessMode),
      _SameAccessTokenStatus status =>
        _localizedAccessModeName(status.inputToken.accessMode),
    };

    return _buildInfoWidget(
      title: "Token access type",
      subtitle: info,
    );
  }

  // TODO: Localize the strings.
  String _localizedAccessModeName(AccessMode mode) => switch (mode) {
        AccessMode.blind => "Blind",
        AccessMode.read => "Read",
        AccessMode.write => "Write",
      };

  Widget _buildActionInfo() {
    final action = switch (tokenStatus) {
      _SubmitableTokenStatus status => _buildTokenStatusSubmitable(status),
      _InvalidTokenStatus status => _buildTokenStatusInvalid(status),
      _NonMatchingTokenStatus status => _buildTokenStatusNonMatching(status),
      _SameAccessTokenStatus status => _buildTokenStatusSameAccess(status),
    };

    return _buildInfoWidget(
      title: "Action to be submitted",
      subtitle: action,
    );
  }

  // -----------------------------------------------------------------

  String _buildTokenStatusSubmitable(_SubmitableTokenStatus status) {
    final repoAccessMode = widget.repo.state.accessMode;

    if (repoAccessMode == status.inputToken.accessMode) {
      return "No action will be performed because the token and repository access match";
    }

    switch (status.inputToken.accessMode) {
      case AccessMode.blind:
        return "The repository will become \"blind\" and no further writing nor reading will be possible";
      case AccessMode.read:
        if (repoAccessMode == AccessMode.write) {
          return "The repository will become read only";
        } else {
          return "The repository will gain read access";
        }
      case AccessMode.write:
        if (repoAccessMode == AccessMode.read) {
          return "The repository will gain write access";
        } else {
          return "The repository will gain read and write access";
        }
    }
  }

  String _buildTokenStatusInvalid(_InvalidTokenStatus status) {
    switch (status.type) {
      case _InvalidTokenType.empty:
        return "Please provide a valid token to determine the action";
      case _InvalidTokenType.malformed:
        return "The token is invalid, please ensure you are using a valid token";
    }
  }

  String _buildTokenStatusNonMatching(_NonMatchingTokenStatus status) {
    return "No action can be performed because the token does not correspond to this repository";
  }

  // TODO: This is handled inside *Submitable as well.
  String _buildTokenStatusSameAccess(_SameAccessTokenStatus status) {
    return "No action will be performed because the token and repository access are the same";
  }

  // -----------------------------------------------------------------

  Widget _buildTokenInputWidget() => ListTile(
          title: Fields.formTextField(
        key: Key('token-input'), // Used in tests
        context: context,
        onChanged: (input) {
          widget._jobs.addJob(() async {
            final inputToken = await parseTokenInput(input);
            _updateTokenStatusOnTokenInputChange(inputToken);
          });
        },
      ));

  // -----------------------------------------------------------------

  Widget _buildSubmitButton() {
    String buttonText;
    Future<void> Function()? onPressed;

    switch (tokenStatus) {
      case _SubmitableTokenStatus valid:
        buttonText = "Submit";
        onPressed = () async {
          await _submit(valid.inputToken);
        };
      case _InvalidTokenStatus():
      case _NonMatchingTokenStatus():
      case _SameAccessTokenStatus():
        buttonText = "Done";
        onPressed = () async {
          Navigator.pop(context, result);
        };
    }

    return AsyncTextButton(child: Text(buttonText), onPressed: onPressed);
  }

  Future<void> _submit(_ValidInputToken input) async {
    final repo = widget.repo;

    // This unlocks or locks the repository in the `AccessMode` of to the token.
    await repo.resetCredentials(input.token);

    // Generate new local secret which will unlock the repo in the future.
    final newLocalSecret = LocalSecretKeyAndSalt.random();
    AccessChange readAccessChange;
    AccessChange writeAccessChange;

    switch (input.accessMode) {
      case AccessMode.blind:
        readAccessChange = DisableAccess();
        writeAccessChange = DisableAccess();
      case AccessMode.read:
        readAccessChange = EnableAccess(newLocalSecret);
        writeAccessChange = DisableAccess();
      case AccessMode.write:
        readAccessChange = DisableAccess();
        writeAccessChange = EnableAccess(newLocalSecret);
    }

    // Encrypt the global secret from the token using the `newLocalSecret` and
    // store it (the encrypted global secret) in the repo.
    await repo.setAccess(read: readAccessChange, write: writeAccessChange);

    AuthMode newAuthMode;

    if (readAccessChange is EnableAccess || writeAccessChange is EnableAccess) {
      // Use a reasonably secure and convenient auth mode, the user can go to
      // the security screen to change it later.
      newAuthMode = await AuthModeKeyStoredOnDevice.encrypt(
        widget.settings.masterKey,
        newLocalSecret.key,
        keyOrigin: SecretKeyOrigin.random,
        // TODO: This isn't really correct, biometric (or other, e.g. pin) should be
        // available whenever the OS supports it **and** when the repository DB files
        // are stored inside a FS directory that the system protects from other app
        // access.
        secureWithBiometrics: await LocalAuth.canAuthenticate(),
      );

      if (writeAccessChange is EnableAccess) {
        result = WriteAccess(newLocalSecret.key);
      } else {
        result = ReadAccess(newLocalSecret.key);
      }
    } else {
      newAuthMode = AuthModeBlindOrManual();
      result = BlindAccess();
    }

    // Store the auth mode inside the repository so it can be the next time
    // after it's locked (e.g. after the app restart).
    await repo.setAuthMode(newAuthMode);

    _updateTokenStatusOnRepoStateChange();
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
        } else if (repoState.accessMode == token.accessMode) {
          newStatus = _SameAccessTokenStatus(token);
        } else {
          newStatus = _SubmitableTokenStatus(token);
        }
    }

    if (mounted) {
      setState(() {
        tokenStatus = newStatus;
      });
    }
  }

  void _updateTokenStatusOnRepoStateChange() {
    final _TokenStatus newStatus;
    final oldStatus = tokenStatus;

    switch (oldStatus) {
      case _InvalidTokenStatus status:
        newStatus = status;
      case _NonMatchingTokenStatus status:
        newStatus = status;
      case _SameAccessTokenStatus status:
        newStatus = status;
      case _SubmitableTokenStatus status:
        if (widget.repo.state.accessMode == status.inputToken.accessMode) {
          newStatus = _SameAccessTokenStatus(status.inputToken);
        } else {
          newStatus = status;
        }
    }

    setState(() {
      tokenStatus = newStatus;
    });
  }

  // -----------------------------------------------------------------

  Future<_InputToken> parseTokenInput(String input) async {
    if (input.isEmpty) {
      return _InvalidInputToken.empty();
    }

    ShareToken token;

    try {
      token = await ShareToken.fromString(widget.repo.session, input);
    } catch (e) {
      return _InvalidInputToken.malformed();
    }

    final accessMode = await token.mode;
    final infoHash = await token.infoHash;

    return _ValidInputToken(token, accessMode, infoHash);
  }
}

//--------------------------------------------------------------------

enum _InvalidTokenType { empty, malformed }

//--------------------------------------------------------------------

sealed class _TokenStatus {}

class _SubmitableTokenStatus implements _TokenStatus {
  _ValidInputToken inputToken;
  _SubmitableTokenStatus(this.inputToken);
}

class _NonMatchingTokenStatus implements _TokenStatus {
  _ValidInputToken inputToken;
  _NonMatchingTokenStatus(this.inputToken);
}

class _SameAccessTokenStatus implements _TokenStatus {
  _ValidInputToken inputToken;
  _SameAccessTokenStatus(this.inputToken);
}

class _InvalidTokenStatus implements _TokenStatus {
  _InvalidTokenStatus(this.type);
  final _InvalidTokenType type;
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

//--------------------------------------------------------------------

class AsyncTextButton extends StatefulWidget {
  AsyncTextButton({
    required this.child,
    this.onPressed,
  });

  final Widget child;
  final Future<void> Function()? onPressed;

  @override
  State<AsyncTextButton> createState() => _AsyncTextButtonState();
}

class _AsyncTextButtonState extends State<AsyncTextButton> {
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    final asyncOnPressed = widget.onPressed;
    final enabled = (asyncOnPressed != null && isRunning == false);

    final onPressed = enabled
        ? () {
            unawaited(() async {
              setState(() {
                isRunning = true;
              });
              await asyncOnPressed();
              setState(() {
                isRunning = false;
              });
            }());
          }
        : null;

    return TextButton(child: widget.child, onPressed: onPressed);
  }
}
