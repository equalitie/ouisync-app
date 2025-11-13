import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show Session;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart';

class LockedRepositoryState extends StatefulWidget {
  const LockedRepositoryState({
    required this.directionality,
    required this.repoCubit,
    required this.masterKey,
    required this.passwordHasher,
    required this.settings,
    required this.session,
    required this.stage,
  });

  final TextDirection directionality;
  final RepoCubit repoCubit;
  final MasterKey masterKey;
  final PasswordHasher passwordHasher;
  final Settings settings;
  final Session session;
  final Stage stage;

  @override
  State<LockedRepositoryState> createState() => _LockedRepositoryStateState();
}

class _LockedRepositoryStateState extends State<LockedRepositoryState>
    with AppLogger, RepositoryActionsMixin {
  final unlockButtonFocus = FocusNode(debugLabel: 'unlock_button_focus');

  @override
  void initState() {
    super.initState();
    unlockButtonFocus.requestFocus();
  }

  @override
  void dispose() {
    unlockButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockedRepoImageHeight =
        MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return Directionality(
      textDirection: widget.directionality,
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
                  assetHeight: lockedRepoImageHeight,
                ),
              ),
              Dimensions.spacingVerticalDouble,
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageMainMessage(
                  S.current.messageLockedRepository,
                  style: context.theme.appTextStyle.bodyLarge,
                  tags: {
                    Constants.inlineTextColor: InlineTextStyles.color(
                      Colors.black,
                    ),
                    Constants.inlineTextSize: InlineTextStyles.size(),
                    Constants.inlineTextBold: InlineTextStyles.bold,
                  },
                ),
              ),
              Dimensions.spacingVertical,
              Align(
                alignment: AlignmentDirectional.center,
                child: Fields.inPageSecondaryMessage(
                  S.current.messageInputPasswordToUnlock,
                  tags: {
                    Constants.inlineTextSize: InlineTextStyles.size(),
                    Constants.inlineTextBold: InlineTextStyles.bold,
                  },
                ),
              ),
              Dimensions.spacingVerticalDouble,
              Fields.inPageButton(
                onPressed: () async {
                  await unlockRepository(
                    context: context,
                    settings: widget.settings,
                    session: widget.session,
                    repoCubit: widget.repoCubit,
                    passwordHasher: widget.passwordHasher,
                    stage: widget.stage,
                  );
                },
                leadingIcon: const Icon(Icons.lock_open_rounded),
                text: S.current.actionUnlock,
                focusNode: unlockButtonFocus,
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
