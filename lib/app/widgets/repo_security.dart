import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoSecurityCubit, RepoSecurityState;
import '../models/models.dart' show SecretKeyOrigin;
import '../utils/platform/platform_values.dart' show PlatformValues;
import '../utils/utils.dart'
    show AppThemeExtension, Dimensions, Fields, ThemeGetter;
import 'widgets.dart'
    show CustomAdaptiveSwitch, PasswordValidation, ScrollableTextWidget;

class RepoSecurity extends StatelessWidget {
  const RepoSecurity(
    this.cubit, {
    required this.isBlind,
    this.repoName,
    super.key,
  });

  final RepoSecurityCubit cubit;

  // If a repository is blind, the security options are disabled, and a message
  // is shown explaining this.
  final bool isBlind;
  final String? repoName;

  @override
  Widget build(BuildContext context) {
    final warningStyle =
        context.theme.appTextStyle.bodyMedium.copyWith(color: Colors.red);

    return BlocBuilder<RepoSecurityCubit, RepoSecurityState>(
      bloc: cubit,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRepoName(context, repoName),
          _buildOriginSwitch(state),
          _buildPasswordFields(state),
          _buildStoreSwitch(state),
          _buildSecureWithBiometricsSwitch(state),
          _buildDisabledOptionsMessage(isBlind, warningStyle),
          _buildManualPasswordWarning(state, warningStyle),
        ],
      ),
    );
  }

  Widget _buildRepoName(BuildContext context, String? repoName) {
    if (repoName == null) return const SizedBox.shrink();

    final titleFontSize = context.theme.textTheme.titleLarge?.fontSize;
    final textStyle = context.theme.textTheme.bodyMedium?.copyWith(
        fontSize: titleFontSize,
        fontWeight: FontWeight.w400,
        textBaseline: TextBaseline.ideographic);

    return Container(
      padding: Dimensions.paddingVertical10,
      child: ScrollableTextWidget(
        child: Text(
          '\'$repoName\'',
          style: textStyle,
        ),
        fontSize: titleFontSize,
      ),
    );
  }

  Widget _buildPasswordFields(RepoSecurityState state) =>
      switch (state.origin) {
        SecretKeyOrigin.manual => PasswordValidation(
            onChanged: cubit.setLocalPassword,
            required: state.isLocalPasswordRequired,
          ),
        SecretKeyOrigin.random => SizedBox.shrink(),
      };

  Widget _buildOriginSwitch(RepoSecurityState state) => _buildSwitch(
        key: Key('use-local-password'), // Used in tests
        value: state.origin == SecretKeyOrigin.manual,
        title: S.current.messageUseLocalPassword,
        onChanged: isBlind
            ? null
            : (value) => cubit.setOrigin(
                value ? SecretKeyOrigin.manual : SecretKeyOrigin.random),
      );

  Widget _buildStoreSwitch(RepoSecurityState state) => switch (state.origin) {
        SecretKeyOrigin.manual => _buildSwitch(
            key: Key('store-on-device'),
            value: state.secretWillBeStored,
            title: S.current.labelRememberPassword,
            onChanged: cubit.setStore,
          ),
        SecretKeyOrigin.random => SizedBox.shrink(),
      };

  // On desktops the keyring is accessible to any application once the user is
  // logged in into their account and thus giving the user the option to protect
  // their repository with system authentication might give them a false sense
  // of security. Therefore unlocking repositories with system authentication is
  // not supported on these systems.
  Widget _buildSecureWithBiometricsSwitch(RepoSecurityState state) =>
      state.isBiometricsAvailable
          ? _buildSwitch(
              value: state.secureWithBiometrics,
              title: S.current.messageSecureUsingBiometrics,
              onChanged: isBlind
                  ? null
                  : state.isSecureWithBiometricsEnabled
                      ? cubit.setSecureWithBiometrics
                      : null,
            )
          : SizedBox.shrink();

  Widget _buildDisabledOptionsMessage(
    bool visible,
    TextStyle warningStyle,
  ) =>
      _buildWarning(
        visible,
        S.current.messageSecurityOptionsNotAvailableBlind,
        warningStyle,
      );

  Widget _buildManualPasswordWarning(
    RepoSecurityState state,
    TextStyle warningStyle,
  ) {
    final visible = !state.secretWillBeStored;
    return _buildWarning(
      visible,
      S.current.messageRememberSavePasswordAlert,
      warningStyle,
    );
  }

  Widget _buildWarning(bool visible, String warning, TextStyle textStyle) =>
      Visibility(
        visible: visible,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 24.0),
          child: Fields.autosizeText(
            warning,
            style: textStyle,
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
        contentPadding: EdgeInsetsDirectional.zero,
        onChanged: onChanged,
      );
}
