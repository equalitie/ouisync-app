import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/auth_mode.dart';
import '../models/local_secret.dart';
import '../utils/extensions.dart';
import '../utils/fields.dart';
import '../utils/log.dart';
import '../utils/platform/platform_values.dart';
import 'widgets.dart';

class RepoSecurity extends StatefulWidget {
  const RepoSecurity({
    super.key,
    required this.initialLocalSecretMode,
    required this.onChanged,
    this.isBiometricsAvailable = false,
  });

  /// Initial value of the local secret mode
  final LocalSecretMode initialLocalSecretMode;

  /// Function called when the local secret mode and/or the password change.
  /// With manual origin password is null means the password is invalid. With random origin
  /// password is always null and should be ignored.
  final void Function(LocalSecretMode localSecretMode, LocalPassword? password)
      onChanged;

  final bool isBiometricsAvailable;

  @override
  State<RepoSecurity> createState() => _RepoSecurityState();
}

class _RepoSecurityState extends State<RepoSecurity> with AppLogger {
  SecretKeyOrigin origin = SecretKeyOrigin.random;
  bool store = false;
  bool secureWithBiometrics = false;
  LocalPassword? password;

  @override
  void initState() {
    super.initState();

    origin = widget.initialLocalSecretMode.origin;

    // We want store to be explicitly opt-in so the switch must be initially off even if the
    // initial origin is random which is implicitly stored.
    store = switch (widget.initialLocalSecretMode) {
      LocalSecretMode.manualStored ||
      LocalSecretMode.manualSecuredWithBiometrics =>
        true,
      LocalSecretMode.manual ||
      LocalSecretMode.randomStored ||
      LocalSecretMode.randomSecuredWithBiometrics =>
        false
    };

    secureWithBiometrics =
        widget.initialLocalSecretMode.isSecuredWithBiometrics;
  }

  // If the secret is already stored and is not random then we can keep using it and only change
  // the other properties. So in those cases putting in a new password is not required.
  bool get _isPasswordRequired => switch (widget.initialLocalSecretMode) {
        LocalSecretMode.manual ||
        LocalSecretMode.randomStored ||
        LocalSecretMode.randomSecuredWithBiometrics =>
          true,
        LocalSecretMode.manualStored ||
        LocalSecretMode.manualSecuredWithBiometrics =>
          false,
      };

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPasswordFields(),
          _buildOriginSwitch(),
          _buildStoreSwitch(),
          _buildSecureWithBiometricsSwitch(),
          _buildManualPasswordWarning(),
        ],
      );

  Widget _buildPasswordFields() => switch (origin) {
        SecretKeyOrigin.manual => PasswordValidation(
            onChanged: _onPasswordChanged,
            required: _isPasswordRequired,
          ),
        SecretKeyOrigin.random => SizedBox.shrink(),
      };

  Widget _buildOriginSwitch() => _buildSwitch(
        key: ValueKey('use-local-password'),
        value: origin == SecretKeyOrigin.manual,
        title: S.current.messageUseLocalPassword,
        onChanged: _onOriginChanged,
      );

  Widget _buildStoreSwitch() => switch (origin) {
        SecretKeyOrigin.manual => _buildSwitch(
            value: store,
            title: S.current.labelRememberPassword,
            onChanged: _onStoreChanged,
          ),
        SecretKeyOrigin.random => SizedBox.shrink(),
      };

  // On desktops the keyring is accessible to any application once the user is
  // logged in into their account and thus giving the user the option to protect
  // their repository with system authentication might give them a false sense
  // of security. Therefore unlocking repositories with system authentication is
  // not supported on these systems.
  Widget _buildSecureWithBiometricsSwitch() => PlatformValues.isMobileDevice
      ? _buildSwitch(
          value: secureWithBiometrics,
          title: S.current.messageSecureUsingBiometrics,
          onChanged: _isSecureWithBiometricsSwitchEnabled
              ? _onSecureWithBiometricsChanged
              : null,
        )
      : SizedBox.shrink();

  Widget _buildManualPasswordWarning() => Visibility(
        visible: origin == SecretKeyOrigin.manual,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Fields.autosizeText(
            S.current.messageRememberSavePasswordAlert,
            style: context.theme.appTextStyle.bodyMedium
                .copyWith(color: Colors.red),
            maxLines: 10,
            softWrap: true,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      );

  Widget _buildSwitch({
    Key? key,
    required bool value,
    required String title,
    required void Function(bool)? onChanged,
  }) =>
      CustomAdaptiveSwitch(
        key: key,
        value: value,
        title: title,
        contentPadding: EdgeInsets.zero,
        onChanged: onChanged,
      );

  bool get _isSecureWithBiometricsSwitchEnabled {
    if (!widget.isBiometricsAvailable) {
      return false;
    }

    if (origin == SecretKeyOrigin.manual && !store) {
      return false;
    }

    return true;
  }

  void _onOriginChanged(bool value) {
    setState(() {
      origin = value ? SecretKeyOrigin.manual : SecretKeyOrigin.random;
    });

    _emitOnChanged();
  }

  void _onPasswordChanged(String? value) {
    setState(() {
      password = value != null ? LocalPassword(value) : null;
    });

    _emitOnChanged();
  }

  void _onStoreChanged(bool value) {
    setState(() {
      store = value;
    });

    _emitOnChanged();
  }

  void _onSecureWithBiometricsChanged(bool value) {
    setState(() {
      secureWithBiometrics = value;
    });

    _emitOnChanged();
  }

  void _emitOnChanged() {
    switch (origin) {
      case SecretKeyOrigin.manual:
        if (store) {
          if (secureWithBiometrics) {
            widget.onChanged(
                LocalSecretMode.manualSecuredWithBiometrics, password);
          } else {
            widget.onChanged(LocalSecretMode.manualStored, password);
          }
        } else {
          widget.onChanged(LocalSecretMode.manual, password);
        }
      case SecretKeyOrigin.random:
        if (secureWithBiometrics) {
          widget.onChanged(LocalSecretMode.randomSecuredWithBiometrics, null);
        } else {
          widget.onChanged(LocalSecretMode.randomStored, null);
        }
    }
  }
}
