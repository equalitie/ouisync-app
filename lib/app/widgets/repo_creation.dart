import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart'
    show
        RepoCreationCubit,
        RepoCreationFailure,
        RepoCreationPending,
        RepoCreationSuccess,
        RepoCreationState,
        RepoCreationValid,
        RepoSecurityCubit,
        RepoSecurityState;
import '../utils/utils.dart'
    show AppThemeExtension, Constants, Dialogs, Dimensions, Fields, ThemeGetter;
import 'widgets.dart'
    show
        BlocHolder,
        ContentWithStickyFooterState,
        CustomAdaptiveSwitch,
        RepoSecurity;

class RepoCreation extends StatelessWidget {
  RepoCreation(this.creationCubit, {super.key});

  final RepoCreationCubit creationCubit;

  @override
  Widget build(BuildContext context) => BlocHolder(
        create: () => RepoSecurityCubit(
          oldLocalSecretMode: RepoCreationState.initialLocalSecretMode,
        ),
        builder: (context, securityCubit) => MultiBlocListener(
          listeners: [
            // Handle substate changes
            BlocListener<RepoCreationCubit, RepoCreationState>(
              bloc: creationCubit,
              listenWhen: (previous, current) =>
                  current.substate != previous.substate,
              listener: _handleSubstateChange,
            ),
            // Prefill suggested name on first load
            BlocListener<RepoCreationCubit, RepoCreationState>(
              bloc: creationCubit,
              listenWhen: (previous, current) =>
                  current.suggestedName.isNotEmpty &&
                  previous.suggestedName.isEmpty,
              listener: _handlePrefillSuggestedName,
            ),
            BlocListener<RepoSecurityCubit, RepoSecurityState>(
              bloc: securityCubit,
              listener: _handleLocalSecretChanged,
            ),
          ],
          child: BlocBuilder<RepoCreationCubit, RepoCreationState>(
            bloc: creationCubit,
            builder: (context, state) => ContentWithStickyFooterState(
              content: _buildContent(context, securityCubit, state),
              footer: Fields.dialogActions(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                buttons: _buildActions(context, securityCubit, state),
              ),
            ),
          ),
        ),
      );

  Widget _buildContent(
    BuildContext context,
    RepoSecurityCubit securityCubit,
    RepoCreationState creationState,
  ) =>
      Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (creationState.token != null)
            ..._buildTokenLabel(context, creationState),
          ..._buildNameField(context, creationState),
          _buildUseCacheServersSwitch(context, creationState),
          RepoSecurity(
            securityCubit,
            isBlind: creationState.accessMode == AccessMode.blind,
          ),
        ],
      );

  List<Widget> _buildActions(
    BuildContext context,
    RepoSecurityCubit securityCubit,
    RepoCreationState creationState,
  ) =>
      [
        Fields.inPageButton(
          text: S.current.actionCancel,
          onPressed: () async => await Navigator.of(context).maybePop(null),
        ),
        BlocBuilder<RepoSecurityCubit, RepoSecurityState>(
          bloc: securityCubit,
          builder: (context, securityState) => Fields.inPageButton(
            text: creationState.token == null
                ? S.current.actionCreate
                : S.current.actionImport,
            onPressed: creationState.substate is RepoCreationValid &&
                    securityState.isValid
                ? () => creationCubit.save()
                : null,
            autofocus: true,
            focusNode: creationCubit.positiveButtonFocusNode,
          ),
        ),
      ];

  List<Widget> _buildTokenLabel(
    BuildContext context,
    RepoCreationState state,
  ) =>
      [
        Container(
          padding: Dimensions.paddingShareLinkBox,
          decoration: const BoxDecoration(
            borderRadius: BorderRadiusDirectional.all(
              Radius.circular(Dimensions.radiusSmall),
            ),
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
        Dimensions.spacingVerticalHalf,
        Text(
          S.current.messageRepositoryAccessMode(state.accessMode.name),
          style: _smallMessageStyle(context),
        ),
        Dimensions.spacingVertical,
      ];

  List<Widget> _buildNameField(BuildContext context, RepoCreationState state) =>
      [
        Fields.formTextField(
          key: ValueKey('name'),
          context: context,
          controller: creationCubit.nameController,
          labelText: S.current.labelName,
          hintText: S.current.messageRepositoryName,
          errorText: state.nameError,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.next,
        ),
        Visibility(
          visible: state.suggestedName.isNotEmpty,
          child: GestureDetector(
            onTap: () => creationCubit.acceptSuggestedName(),
            child: Text(
              S.current.messageRepositorySuggestedName(state.suggestedName),
              style: _smallMessageStyle(context),
            ),
          ),
        ),
        Dimensions.spacingVertical,
      ];

  Widget _buildUseCacheServersSwitch(
    BuildContext context,
    RepoCreationState state,
  ) =>
      state.accessMode == AccessMode.write
          ? CustomAdaptiveSwitch(
              key: ValueKey('use-cache-servers'),
              value: state.useCacheServers,
              title: S.current.messageUseCacheServers,
              contentPadding: EdgeInsetsDirectional.zero,
              onChanged: (value) => creationCubit.setUseCacheServers(value),
            )
          : SizedBox.shrink();

  TextStyle _smallMessageStyle(BuildContext context) =>
      context.theme.appTextStyle.bodySmall.copyWith(color: Colors.black54);

  Future<void> _handleSubstateChange(
    BuildContext context,
    RepoCreationState state,
  ) async {
    switch (state.substate) {
      case RepoCreationPending():
      case RepoCreationValid():
        break;
      case RepoCreationSuccess(location: final location):
        await Navigator.of(context).maybePop(location);
      case RepoCreationFailure(location: final location, error: final error):
        await Dialogs.simpleAlertDialog(
          context,
          title: S.current.messageFailedCreateRepository(location.path),
          message: error,
        );
    }
  }

  void _handleLocalSecretChanged(
    BuildContext context,
    RepoSecurityState state,
  ) {
    final localSecretInput = state.newLocalSecretInput;
    if (localSecretInput == null) {
      return;
    }

    creationCubit.setLocalSecret(localSecretInput);
  }

  void _handlePrefillSuggestedName(
    BuildContext context,
    RepoCreationState state,
  ) =>
      creationCubit.acceptSuggestedName();
}
