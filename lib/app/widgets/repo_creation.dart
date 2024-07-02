import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../utils/actions.dart';
import '../utils/constants.dart';
import '../utils/dialogs.dart';
import '../utils/dimensions.dart';
import '../utils/extensions.dart';
import '../utils/fields.dart';
import 'repo_security.dart';
import 'states/content_with_sticky_footer_state.dart';
import 'switches/custom_adaptive_switch.dart';

class RepoCreation extends StatelessWidget {
  RepoCreation(this.cubit, {super.key});

  final RepoCreationCubit cubit;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          // Show snackbar when initial token valid is invalid
          BlocListener<RepoCreationCubit, RepoCreationState>(
            bloc: cubit,
            listenWhen: (previous, current) =>
                current.tokenError.isNotEmpty &&
                current.tokenError != previous.tokenError,
            listener: _handleTokenError,
          ),
          // Handle substate changes
          BlocListener<RepoCreationCubit, RepoCreationState>(
            bloc: cubit,
            listenWhen: (previous, current) =>
                current.substate != previous.substate,
            listener: _handleSubstateChange,
          ),
          // Show loading indicator
          BlocListener<RepoCreationCubit, RepoCreationState>(
            bloc: cubit,
            listenWhen: (previous, current) =>
                current.loading && !previous.loading,
            listener: _handleLoading,
          ),
        ],
        child: BlocBuilder<RepoCreationCubit, RepoCreationState>(
          bloc: cubit,
          builder: (context, state) => ContentWithStickyFooterState(
            content: _buildContent(context, state),
            footer: Fields.dialogActions(
              context,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              buttons: _buildActions(context, state),
            ),
          ),
        ),
      );

  Widget _buildContent(BuildContext context, RepoCreationState state) => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (state.token != null) ..._buildTokenLabel(context, state),
          ..._buildNameField(context, state),
          if (state.accessMode == AccessMode.write)
            _buildUseCacheServersSwitch(context, state),
          RepoSecurity(
            initialLocalSecretMode: RepoCreationState.initialLocalSecretMode,
            isBiometricsAvailable: state.isBiometricsAvailable,
            onChanged: (localSecretMode, localPassword) =>
                cubit.setLocalSecret(localSecretMode, localPassword),
          ),
        ],
      );

  List<Widget> _buildActions(BuildContext context, RepoCreationState state) => [
        Fields.inPageButton(
          text: S.current.actionCancel,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        Fields.inPageButton(
          text: state.token == null
              ? S.current.actionCreate
              : S.current.actionImport,
          onPressed:
              state.substate is RepoCreationValid ? () => cubit.save() : null,
        ),
      ];

  List<Widget> _buildTokenLabel(
          BuildContext context, RepoCreationState state) =>
      [
        Padding(
          padding: Dimensions.paddingVertical10,
          child: Container(
            padding: Dimensions.paddingShareLinkBox,
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
              color: Constants.inputBackgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Fields.constrainedText(
                  S.current.labelRepositoryLink,
                  flex: 0,
                  style: context.theme.appTextStyle.labelMedium
                      .copyWith(color: Constants.inputLabelForeColor),
                ),
                Dimensions.spacingVerticalHalf,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.token?.toString() ?? '',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.theme.appTextStyle.bodySmall
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Fields.constrainedText(
                S.current.messageRepositoryAccessMode(state.accessMode.name),
                style: _smallMessageStyle(context),
              ),
            ],
          ),
        ),
      ];

  List<Widget> _buildNameField(BuildContext context, RepoCreationState state) =>
      [
        Padding(
          padding: Dimensions.paddingVertical10,
          child: Fields.formTextField(
            key: ValueKey('name'),
            context: context,
            controller: cubit.nameController,
            labelText: S.current.labelName,
            hintText: S.current.messageRepositoryName,
            errorText: state.nameError,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
        ),
        Visibility(
          visible: state.suggestedName.isNotEmpty,
          child: GestureDetector(
            onTap: () => cubit.acceptSuggestedName(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fields.constrainedText(
                  S.current.messageRepositorySuggestedName(state.suggestedName),
                  style: _smallMessageStyle(context),
                )
              ],
            ),
          ),
        ),
      ];

  Widget _buildUseCacheServersSwitch(
    BuildContext context,
    RepoCreationState state,
  ) =>
      CustomAdaptiveSwitch(
        key: ValueKey('use-cache-servers'),
        value: state.useCacheServers,
        title: S.current.messageUseCacheServers,
        contentPadding: EdgeInsets.zero,
        onChanged: (value) => cubit.setUseCacheServers(value),
      );

  TextStyle _smallMessageStyle(BuildContext context) =>
      context.theme.appTextStyle.bodySmall.copyWith(color: Colors.black54);

  void _handleTokenError(BuildContext context, RepoCreationState state) =>
      showSnackBar(state.tokenError);

  Future<void> _handleSubstateChange(
    BuildContext context,
    RepoCreationState state,
  ) async {
    switch (state.substate) {
      case RepoCreationPending():
      case RepoCreationValid():
        break;
      case RepoCreationSuccess(location: final location):
        Navigator.of(context).pop(location);
      case RepoCreationFailure(location: final location, error: final error):
        await Dialogs.simpleAlertDialog(
          context: context,
          title: S.current.messsageFailedCreateRepository(location.path),
          message: error,
        );
    }
  }

  Future<void> _handleLoading(
    BuildContext context,
    RepoCreationState state,
  ) async {
    Future<void> done() async {
      // Make sure to check the initial state as well, to avoid race conditions.
      if (!cubit.state.loading) {
        return;
      }

      await cubit.stream.where((state) => !state.loading).first;
    }

    await Dialogs.executeFutureWithLoadingDialog(context, done());
  }
}
