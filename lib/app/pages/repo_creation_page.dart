import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/utils/dialogs.dart';
import 'package:ouisync_app/app/widgets/store_dir.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart'
    show
        RepoCreationCubit,
        RepoCreationFailure,
        RepoCreationPending,
        RepoCreationSuccess,
        RepoCreationState,
        RepoCreationValid,
        ReposCubit;

import '../cubits/store_dirs.dart';
import '../utils/log.dart' show AppLogger;
import '../utils/stage.dart';
import '../utils/utils.dart'
    show AppThemeExtension, Constants, Dimensions, Fields, ThemeGetter;

import '../widgets/widgets.dart'
    show
        BlocHolder,
        DirectionalAppBar,
        ContentWithStickyFooterState,
        CustomAdaptiveSwitch;

class RepoCreationPage extends StatelessWidget {
  RepoCreationPage({
    super.key,
    required this.stage,
    required this.reposCubit,
    required this.storeDirsCubit,
    this.token,
  });

  final Stage stage;
  final ReposCubit reposCubit;
  final StoreDirsCubit storeDirsCubit;
  final ShareToken? token;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(
      title: Text(
        token == null
            ? S.current.titleCreateRepository
            : S.current.titleAddRepository,
      ),
    ),
    body: BlocHolder(
      create: () => _createCubit(context),
      builder: (context, creationCubit) => RepoCreation(
        stage: stage,
        creationCubit: creationCubit,
        storeDirsCubit: storeDirsCubit,
      ),
    ),
  );

  RepoCreationCubit _createCubit(BuildContext context) {
    final cubit = RepoCreationCubit(reposCubit: reposCubit);

    unawaited(
      // Wrapping this in `Future(() => ...)` to ensure the future does not start executing in
      // the same frame this function is invoked, which would result in exception from flutter.
      Future(() => stage.loading(cubit.setToken(token))),
    );

    return cubit;
  }
}

class RepoCreation extends StatelessWidget with AppLogger {
  RepoCreation({
    required this.stage,
    required this.creationCubit,
    required this.storeDirsCubit,
    super.key,
  });

  final Stage stage;
  final RepoCreationCubit creationCubit;
  final StoreDirsCubit storeDirsCubit;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
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
            current.suggestedName.isNotEmpty && previous.suggestedName.isEmpty,
        listener: _handlePrefillSuggestedName,
      ),
    ],
    child: BlocBuilder<RepoCreationCubit, RepoCreationState>(
      bloc: creationCubit,
      builder: (context, state) => ContentWithStickyFooterState(
        content: _buildContent(context, state),
        footer: Fields.dialogActions(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          buttons: _buildActions(context, state),
        ),
      ),
    ),
  );

  Widget _buildContent(BuildContext context, RepoCreationState creationState) =>
      Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (creationState.token != null)
            ..._buildTokenLabel(context, creationState),
          ..._buildNameField(context, creationState),
          _buildUseCacheServersSwitch(context, creationState),
          _buildStoreSelector(context, creationState),
        ],
      );

  List<Widget> _buildActions(
    BuildContext context,
    RepoCreationState creationState,
  ) => [
    Fields.inPageButton(
      text: S.current.actionCancel,
      onPressed: () async => await Navigator.of(context).maybePop(null),
    ),
    Fields.inPageAsyncButton(
      key: Key('create-repository'),
      text: creationState.token == null
          ? S.current.actionCreate
          : S.current.actionImport,
      onPressed: creationState.substate is RepoCreationValid
          ? () => creationCubit.save()
          : null,
      autofocus: true,
      focusNode: creationCubit.positiveButtonFocusNode,
    ),
  ];

  List<Widget> _buildTokenLabel(
    BuildContext context,
    RepoCreationState state,
  ) => [
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
            style: context.theme.appTextStyle.labelMedium.copyWith(
              color: Constants.inputLabelForeColor,
            ),
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
                  style: context.theme.appTextStyle.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
  ) => state.accessMode == AccessMode.write
      ? CustomAdaptiveSwitch(
          key: ValueKey('use-cache-servers'),
          value: state.useCacheServers,
          title: S.current.messageUseCacheServers,
          contentPadding: EdgeInsetsDirectional.zero,
          onChanged: (value) => creationCubit.setUseCacheServers(value),
        )
      : SizedBox.shrink();

  Widget _buildStoreSelector(BuildContext context, RepoCreationState state) =>
      BlocBuilder<StoreDirsCubit, StoreDirs>(
        bloc: storeDirsCubit,
        builder: (context, storeDirs) => storeDirs.length > 1
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Text(
                    S.current.messageStorage,
                    style: TextStyle(
                      fontSize: context.theme.appTextStyle.titleMedium.fontSize,
                    ),
                  ),
                  StoreDirSelector(
                    storeDirsCubit: storeDirsCubit,
                    value: storeDirs.firstWhereOrNull(
                      (dir) => dir.path == state.dir,
                    ),
                    onChanged: (dir) => creationCubit.setDir(dir.path),
                  ),
                ],
              )
            : SizedBox.shrink(),
      );

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
      case RepoCreationSuccess(entry: final entry):
        await stage.maybePop(entry);
      case RepoCreationFailure(location: final location, error: final error):
        await SimpleAlertDialog.show(
          stage,
          title: S.current.messageFailedCreateRepository(location.path),
          message: error,
        );
    }
  }

  void _handlePrefillSuggestedName(
    BuildContext context,
    RepoCreationState state,
  ) => creationCubit.acceptSuggestedName();
}
