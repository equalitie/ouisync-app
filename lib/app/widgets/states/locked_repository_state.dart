import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../utils/utils.dart';

class LockedRepositoryState extends HookWidget
    with AppLogger, RepositoryActionsMixin {
  const LockedRepositoryState({
    required this.parentContext,
    required this.directionality,
    required this.repoCubit,
    required this.masterKey,
    required this.passwordHasher,
  });

  final BuildContext parentContext;
  final TextDirection directionality;
  final RepoCubit repoCubit;
  final MasterKey masterKey;
  final PasswordHasher passwordHasher;

  @override
  Widget build(BuildContext context) {
    final lockedRepoImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    final FocusNode unlockButtonFocus =
        useFocusNode(debugLabel: 'unlock_button_focus');

    unlockButtonFocus.requestFocus();

    return Directionality(
      textDirection: directionality,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                  alignment: AlignmentDirectional.center,
                  child: Fields.placeholderWidget(
                      assetName: Constants.assetLockedRepository,
                      assetHeight: lockedRepoImageHeight)),
              Dimensions.spacingVerticalDouble,
              Align(
                  alignment: AlignmentDirectional.center,
                  child: Fields.inPageMainMessage(
                      S.current.messageLockedRepository,
                      style: context.theme.appTextStyle.bodyLarge,
                      tags: {
                        Constants.inlineTextColor:
                            InlineTextStyles.color(Colors.black),
                        Constants.inlineTextSize: InlineTextStyles.size(),
                        Constants.inlineTextBold: InlineTextStyles.bold
                      })),
              Dimensions.spacingVertical,
              Align(
                  alignment: AlignmentDirectional.center,
                  child: Fields.inPageSecondaryMessage(
                      S.current.messageInputPasswordToUnlock,
                      tags: {
                        Constants.inlineTextSize: InlineTextStyles.size(),
                        Constants.inlineTextBold: InlineTextStyles.bold,
                      })),
              Dimensions.spacingVerticalDouble,
              Fields.inPageButton(
                  onPressed: () async {
                    await unlockRepository(
                      parentContext,
                      repoCubit,
                      masterKey,
                      passwordHasher,
                    );
                  },
                  leadingIcon: const Icon(Icons.lock_open_rounded),
                  text: S.current.actionUnlock,
                  focusNode: unlockButtonFocus,
                  autofocus: true)
            ],
          ),
        ),
      ),
    );
  }
}
