import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../mixins/mixins.dart';
import '../../utils/utils.dart';

class LockedRepositoryState extends StatelessWidget
    with OuiSyncAppLogger, RepositoryActionsMixin {
  const LockedRepositoryState(this.parentContext,
      {required this.databaseId,
      required this.repositoryName,
      required this.checkForBiometricsCallback,
      required this.getAuthenticationModeCallback,
      required this.setAuthenticationModeCallback,
      required this.unlockRepositoryCallback});

  final BuildContext parentContext;

  final String databaseId;
  final String repositoryName;

  final CheckForBiometricsFunction checkForBiometricsCallback;
  final AuthMode Function(String repoName) getAuthenticationModeCallback;
  final Future<void> Function(String repoName, AuthMode? value)
      setAuthenticationModeCallback;
  final Future<AccessMode?> Function(String repositoryName,
      {required String password}) unlockRepositoryCallback;

  @override
  Widget build(BuildContext context) {
    final lockedRepoImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return Center(
        child: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.center,
            child: Fields.placeholderWidget(
                assetName: Constants.assetLockedRepository,
                assetHeight: lockedRepoImageHeight)),
        Dimensions.spacingVerticalDouble,
        Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(S.current.messageLockedRepository,
                tags: {
                  Constants.inlineTextColor:
                      InlineTextStyles.color(Colors.black),
                  Constants.inlineTextSize: InlineTextStyles.size(),
                  Constants.inlineTextBold: InlineTextStyles.bold
                })),
        Dimensions.spacingVertical,
        Align(
            alignment: Alignment.center,
            child: Fields.inPageSecondaryMessage(
                S.current.messageInputPasswordToUnlock,
                tags: {
                  Constants.inlineTextSize: InlineTextStyles.size(),
                  Constants.inlineTextBold: InlineTextStyles.bold,
                })),
        Dimensions.spacingVerticalDouble,
        Fields.inPageButton(
            onPressed: () async => await unlockRepository(parentContext,
                databaseId: databaseId,
                repositoryName: repositoryName,
                checkForBiometrics: checkForBiometricsCallback,
                getAuthenticationMode: getAuthenticationModeCallback,
                setAuthenticationMode: setAuthenticationModeCallback,
                cubitUnlockRepository: unlockRepositoryCallback),
            leadingIcon: const Icon(Icons.lock_open_rounded),
            text: S.current.actionUnlock,
            autofocus: true)
      ],
    )));
  }
}
