import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show EntryType, Session;
import 'package:path/path.dart' as system_path;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../cubits/store_dirs.dart';
import '../models/models.dart';
import '../utils/dirs.dart';
import '../utils/platform/platform.dart';
import '../utils/stage.dart';
import '../utils/utils.dart';
import '../widgets/notification_badge.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef BottomSheetCallback =
    void Function(Widget? widget, double maxHeight, String entryPath);

typedef MoveEntryCallback =
    Future<bool> Function(String origin, String path, EntryType type);

typedef PreviewFileCallback =
    Future<void> Function(RepoCubit repo, FileEntry entry);

class MainPage extends StatefulWidget {
  const MainPage({
    required this.stage,
    required this.localeCubit,
    required this.mountCubit,
    required this.receivedMedia,
    required this.reposCubit,
    required this.errorCubit,
    required this.session,
    required this.settings,
    required this.windowManager,
    required this.dirs,
    required this.storeDirsCubit,
  });

  final Stage stage;
  final PlatformWindowManager windowManager;
  final Session session;
  final Settings settings;
  final Stream<List<SharedMediaFile>> receivedMedia;
  final ReposCubit reposCubit;
  final ErrorCubit errorCubit;
  final MountCubit mountCubit;
  final LocaleCubit localeCubit;
  final Dirs dirs;
  final StoreDirsCubit storeDirsCubit;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, AppLogger {
  late final PowerControl powerControl = PowerControl(
    widget.session,
    widget.settings,
  );
  late final SortListCubit sortListCubit;
  late final UpgradeExistsCubit upgradeExists;

  final _bottomSheetInfo = ValueNotifier<BottomSheetInfo>(
    BottomSheetInfo(type: BottomSheetType.gone, neededPadding: 0.0, entry: ''),
  );
  bool _isBottomSheetInfoDisposed = false;

  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  final _appSettingsIconFocus = FocusNode(
    debugLabel: 'app_settings_icon_focus',
  );

  final _fabFocus = FocusNode(debugLabel: 'fab_focus');

  StreamSubscription? _receivedMediaSubscription;

  @override
  void initState() {
    super.initState();

    upgradeExists = UpgradeExistsCubit(widget.session, widget.settings);

    sortListCubit = SortListCubit.create(
      sortBy: SortBy.name,
      direction: SortDirection.asc,
      listType: ListType.repos,
    );

    _receivedMediaSubscription = widget.receivedMedia.listen(
      handleReceivedMedia,
    );

    if (io.Platform.isWindows) {
      checkForDokan();
    }
  }

  @override
  void dispose() {
    _bottomSheetInfo.dispose();
    _isBottomSheetInfoDisposed = true;

    _appSettingsIconFocus.dispose();
    _fabFocus.dispose();
    _receivedMediaSubscription?.cancel();

    unawaited(upgradeExists.close());
    unawaited(sortListCubit.close());
    unawaited(powerControl.close());

    super.dispose();
  }

  void checkForDokan() {
    installationOk() => widget.mountCubit.init();

    Future<bool?> installationFailed() => widget.stage.showDialog(
      builder: (context) => SimpleAlertDialog(
        stage: widget.stage,
        title: S.current.titleDokanInstallation,
        message: S.current.messageDokanInstallationFailed,
      ),
    );

    final dokanValidation = DokanValidation(
      stage: widget.stage,
      installationOk: installationOk,
      installationFailed: installationFailed,
    );

    final dokanCheckResult = dokanValidation.checkDokanInstallation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (dokanCheckResult.result) {
        case DokanResult.notFound:
          unawaited(dokanValidation.tryInstallDokan());
          break;

        case DokanResult.differentMayor:
          unawaited(dokanValidation.tryInstallNewerDokanMayor());
          break;

        case DokanResult.olderVersionMayor:
          unawaited(dokanValidation.tryInstallDifferentDokanMayor());
          break;

        case DokanResult.sameVersion:
        case DokanResult.newerVersionMayor:
          loggy.debug(
            'The Dokan version installed is supported: '
            '${dokanCheckResult.result!.name}',
          );
          break;

        case null:
          loggy.debug(
            'Check Dokan installation status failed: '
            '${dokanCheckResult.error}',
          );
          break;
      }
    });
  }

  Widget buildMainWidget(
    TextDirection directionality,
  ) => BlocBuilder<ReposCubit, ReposState>(
    bloc: widget.reposCubit,
    builder: (context, state) {
      final currentRepoEntry = state.current;
      final currentRepoCubit = currentRepoEntry?.cubit;

      if (currentRepoCubit != null) {
        currentRepoCubit.updateNavigation();
      }

      if (state.repos.isNotEmpty && currentRepoCubit == null) {
        /// This needs to be structured better
        /// TODO: Add sorting to repo list
        // _sortListCubit?.sortBy(SortBy.name);

        // final sortBy = SortBy.name;
        // final sortDirection =
        //     _sortListCubit?.state.direction ?? SortDirection.asc;

        /// Using the "back" arrow causes the app settings icon (gear) to get
        /// the focus, even if we explicitly ask for it to losse it.
        /// So for now we request focus for the FAB, then unfocused it.
        _fabFocus.requestFocus();
        _fabFocus.unfocus();

        return RepoListState(
          reposCubit: widget.reposCubit,
          storeDirsCubit: widget.storeDirsCubit,
          bottomSheetInfo: _bottomSheetInfo,
          onShowRepoSettings: _showRepoSettings,
          stage: widget.stage,
        );
      }

      if (state.isLoading || currentRepoEntry is LoadingRepoEntry) {
        // This one is mainly for when we're unlocking the repository,
        // because during that time the current repository is destroyed so we
        // can't show it's content.
        return Center(child: _progressIndicatorWidget());
      }

      if (currentRepoCubit != null) {
        final navigationPath = currentRepoCubit.state.currentFolder.path;
        currentRepoCubit.navigateTo(navigationPath);

        return _repositoryContentBuilder(
          state,
          currentRepoCubit,
          directionality,
        );
      }

      if (currentRepoEntry is MissingRepoEntry) {
        return MissingRepositoryState(
          directionality: directionality,
          repositoryLocation: currentRepoEntry.location,
          errorMessage: currentRepoEntry.error,
          errorDescription: currentRepoEntry.errorDescription,
          onBackToList: () => widget.reposCubit.setCurrent(null),
          reposCubit: widget.reposCubit,
        );
      }

      if (currentRepoEntry is ErrorRepoEntry) {
        // This is a general purpose error state.
        // errorDescription is required, but nullable.
        return ErrorState(
          directionality: directionality,
          errorMessage: currentRepoEntry.error,
          errorDescription: currentRepoEntry.errorDescription,
          onBackToList: () => widget.reposCubit.setCurrent(null),
        );
      }

      if (currentRepoEntry == null) {
        return state.repos.isNotEmpty
            ? SizedBox.shrink()
            : NoRepositoriesState(
                directionality: directionality,
                onCreateRepoPressed: _createRepo,
                onImportRepoPressed: _importRepo,
              );
      }

      return Center(child: Text(S.current.messageErrorUnhandledState));
    },
  );

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Scaffold(
      appBar: _buildOuiSyncBar(),
      body: PopScope<Object?>(
        // Don't pop => don't exit
        //
        // We don't want to do the pop because that would destroy the current Isolate's execution
        // context and we would lose track of open OuiSync objects (i.e. repositories, files,
        // directories, network handles,...). This is bad because even though the current execution
        // context is deleted, the OuiSync Rust global variables and threads stay alive. If the
        // user at that point tried to open the app again, this widget would try to reinitialize
        // all those variables without previously properly closing them.
        canPop: false,
        onPopInvokedWithResult: _onBackPressed,
        child: buildMainWidget(Directionality.of(context)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: BlocBuilder<ReposCubit, ReposState>(
        bloc: widget.reposCubit,
        builder: _buildFAB,
      ),
      bottomSheet: modalBottomSheet(),
    ),
  );

  Future<void> _onBackPressed(bool didPop, Object? result) async {
    final currentRepoEntry = widget.reposCubit.state.current;

    if (currentRepoEntry != null) {
      if (currentRepoEntry is OpenRepoEntry) {
        final currentFolder = currentRepoEntry.cubit.state.currentFolder;
        if (!currentFolder.isRoot) {
          await currentRepoEntry.cubit.navigateTo(currentFolder.parent);
          return;
        }
      }

      widget.reposCubit.showRepoList();
      return;
    }
  }

  PreferredSizeWidget _buildOuiSyncBar() => OuiSyncBar(
    reposCubit: widget.reposCubit,
    repoPicker: RepositoriesBar(
      stage: widget.stage,
      mount: widget.mountCubit,
      errorCubit: widget.errorCubit,
      powerControl: powerControl,
      reposCubit: widget.reposCubit,
      upgradeExists: upgradeExists,
    ),
    appSettingsButton: _buildAppSettingsIcon(),
    searchButton: _buildSearchIcon(),
    repoSettingsButton: _buildRepoSettingsIcon(),
  );

  Widget _buildAppSettingsIcon() => NotificationBadge(
    mount: widget.mountCubit,
    errorCubit: widget.errorCubit,
    powerControl: powerControl,
    upgradeExists: upgradeExists,
    moveDownwards: 5,
    moveRight: 3,
    child: Fields.actionIcon(
      const Icon(Icons.settings_outlined),
      onPressed: _showAppSettings,
      size: Dimensions.sizeIconSmall,
      key: ValueKey('settings'),
    ),
  );

  Widget _buildRepoSettingsIcon() => Fields.actionIcon(
    const Icon(Icons.more_vert_rounded),
    onPressed: () async {
      final repoCubit = widget.reposCubit.state.current?.cubit;
      if (repoCubit == null) {
        return;
      }

      await _showRepoSettings(context, repoCubit: repoCubit);
    },
    size: Dimensions.sizeIconSmall,
    key: ValueKey('settings'),
  );

  Widget _buildSearchIcon() => Fields.actionIcon(
    const Icon(Icons.search_rounded),
    onPressed: () {
      /// TODO: Implement searching
    },
    size: Dimensions.sizeIconSmall,
  );

  Widget _buildFAB(BuildContext context, ReposState reposState) {
    final icon = const Icon(Icons.add_rounded);
    final current = reposState.current;

    if (current == null) {
      if (reposState.repos.isNotEmpty) {
        return FloatingActionButton(
          mini: true,
          focusNode: _fabFocus,
          heroTag: Constants.heroTagRepoListActions,
          child: icon,
          onPressed: _showRepoListActions,
        );
      }
    } else if (current is OpenRepoEntry) {
      return BlocBuilder<RepoCubit, RepoState>(
        bloc: current.cubit,
        builder: (context, state) => Visibility(
          visible: state.canWrite,
          child: FloatingActionButton(
            mini: true,
            focusNode: _fabFocus,
            heroTag: Constants.heroTagMainPageActions,
            child: icon,
            onPressed: () => unawaited(_showDirectoryActions(current)),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _repositoryContentBuilder(
    ReposState reposState,
    RepoCubit repoCubit,
    TextDirection directionality,
  ) => BlocBuilder<RepoCubit, RepoState>(
    bloc: repoCubit,
    builder: (context, state) =>
        _selectLayoutWidget(reposState, directionality),
  );

  Widget _selectLayoutWidget(
    ReposState reposState,
    TextDirection directionality,
  ) {
    final current = reposState.current;

    if (current == null || current is LoadingRepoEntry) {
      return NoRepositoriesState(
        directionality: directionality,
        onCreateRepoPressed: _createRepo,
        onImportRepoPressed: _importRepo,
      );
    }

    if (current is OpenRepoEntry) {
      if (!current.cubit.state.canRead) {
        return LockedRepositoryState(
          directionality: directionality,
          repoCubit: current.cubit,
          // TODO: masterKey is not needed when passing settings.
          masterKey: widget.settings.masterKey,
          settings: widget.settings,
          session: widget.session,
          passwordHasher: PasswordHasher(widget.session),
          stage: widget.stage,
        );
      }

      _appSettingsIconFocus.unfocus();

      return _contentBrowser(reposState, current.cubit, directionality);
    }

    return Center(
      child: Text(
        S.current.messageErrorUnhandledState,
        textDirection: directionality,
      ),
    );
  }

  Widget _contentBrowser(
    ReposState reposState,
    RepoCubit repo,
    TextDirection directionality,
  ) {
    Widget child;
    final folder = repo.state.currentFolder;

    if (folder.content.isEmpty) {
      if (repo.state.isLoading) {
        child = Center(child: _progressIndicatorWidget());
      } else {
        _fabFocus.requestFocus();
        child = NoContentsState(
          directionality: directionality,
          repository: repo,
          path: folder.path,
        );
      }
    } else {
      child = _contentsList(reposState, repo);
    }

    return ValueListenableBuilder(
      valueListenable: _bottomSheetInfo,
      builder: (_, btInfo, __) => Container(
        padding: EdgeInsetsDirectional.only(
          bottom: btInfo.neededPadding <= 0.0
              ? Dimensions.defaultListBottomPadding
              : btInfo.neededPadding,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // TODO: A shadow would be nicer.
            const Divider(height: 1),
            FolderContentsBar(
              stage: widget.stage,
              reposCubit: widget.reposCubit,
              repoCubit: repo,
              hasContents: folder.content.isNotEmpty,
              sortListCubit: sortListCubit,
              entrySelectionCubit: repo.entrySelectionCubit,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _contentsList(
    ReposState reposState,
    RepoCubit currentRepoCubit,
  ) => BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
    bloc: currentRepoCubit.entrySelectionCubit,
    builder: (context, selectionState) {
      final contents = currentRepoCubit.state.currentFolder.content;
      final totalEntries = contents.length;

      // TODO: Remove this RefreshIndicator (not needed, content refreshed automatically)
      return RefreshIndicator(
        onRefresh: () async {
          await reposState.current?.cubit?.refresh();
        },
        child: Container(
          child: ListView.separated(
            key: Key('directory_entry_list'),
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.transparent),
            itemCount: totalEntries,
            itemBuilder: (context, index) {
              final entry = contents[index];
              final key = ValueKey(entry.name);

              return Column(
                children: [
                  (entry is FileEntry
                      ? _builFileListItem
                      : _buildDirectoryListItem)(
                    context,
                    key,
                    currentRepoCubit,
                    selectionState,
                    entry,
                  ),
                  if (index == (totalEntries - 1)) SizedBox(height: 56),
                ],
              );
            },
          ),
        ),
      );
    },
  );

  FileListItem _builFileListItem(
    BuildContext context,
    ValueKey<String> key,
    RepoCubit currentRepoCubit,
    EntrySelectionState selectionState,
    FileSystemEntry entry,
  ) => FileListItem(
    key: key,
    entry: entry as FileEntry,
    repoCubit: currentRepoCubit,
    mainAction: () async => await _entryMainAction(currentRepoCubit, entry),
    verticalDotsAction: () async => await _entryDotsMenuAction(
      currentRepoCubit,
      entry,
      selectionState.status == SelectionStatus.on,
    ),
  );

  DirectoryListItem _buildDirectoryListItem(
    BuildContext context,
    ValueKey<String> key,
    RepoCubit currentRepoCubit,
    EntrySelectionState selectionState,
    FileSystemEntry entry,
  ) => DirectoryListItem(
    key: key,
    entry: entry as DirectoryEntry,
    repoCubit: currentRepoCubit,
    mainAction: () async => await _entryMainAction(
      currentRepoCubit,
      entry,
      selectionState.isEntrySelected(currentRepoCubit.state.infoHash, entry),
    ),
    verticalDotsAction: () async => await _entryDotsMenuAction(
      currentRepoCubit,
      entry,
      selectionState.status == SelectionStatus.on,
    ),
  );

  Future<void> _entryMainAction(
    RepoCubit currentRepoCubit,
    FileSystemEntry entry, [
    bool isSelected = false,
  ]) async {
    if (entry is FileEntry) {
      return viewFile(
        stage: widget.stage,
        repo: currentRepoCubit,
        path: entry.path,
        loggy: loggy,
      );
    }

    if (isSelected) {
      await _showNotAvailableMessage();
      return;
    }

    final path = entry.path;
    if (_bottomSheetInfo.value.entry != path) {
      return currentRepoCubit.navigateTo(path);
    }
  }

  Future<void> _entryDotsMenuAction(
    RepoCubit currentRepoCubit,
    FileSystemEntry entry,
    bool isSelecting,
  ) async {
    if (isSelecting) {
      await _showNotAvailableMessage();
      return;
    }

    if (_bottomSheetInfo.value.type == BottomSheetType.gone) {
      await _showEntryDetails(currentRepoCubit, entry);
    }
  }

  // void _showNotAvailableMessage() => showSnackBar(S.current.messageMovingEntry);
  Future<void> _showNotAvailableMessage() => SimpleAlertDialog.show(
    widget.stage,
    title: S.current.titleMovingEntry,
    message: S.current.messageMovingEntry,
  );

  Future<void> _showEntryDetails(
    RepoCubit repoCubit,
    FileSystemEntry entry,
  ) => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) => entry is FileEntry
        ? EntryDetails.file(
            repoCubit: repoCubit,
            entry: entry,
            onPreviewFile: (cubit, data) => viewFile(
              stage: widget.stage,
              repo: cubit,
              path: data.path,
              loggy: loggy,
            ),
            isActionAvailableValidator: _isEntryActionAvailable,
            dirs: widget.dirs,
            stage: widget.stage,
          )
        : EntryDetails.folder(
            repoCubit: repoCubit,
            entry: entry,
            isActionAvailableValidator: _isEntryActionAvailable,
            dirs: widget.dirs,
            stage: widget.stage,
          ),
    // TODO: Find out how to get this to work, so we can use the snackbar on the bottom sheet.
    //  ScaffoldMessenger(
    //   child: Scaffold(
    //     bottomSheet: entry is FileEntry
    //         ? EntryDetails.file(
    //             context,
    //             repoCubit: repoCubit,
    //             entry: entry,
    //             onPreviewFile: (cubit, data, useDefaultApp) => _previewFile(
    //               cubit,
    //               data,
    //               useDefaultApp,
    //             ),
    //             isActionAvailableValidator: _isEntryActionAvailable,
    //             packageInfo: widget.packageInfo,
    //             nativeChannels: widget.nativeChannels,
    //           )
    //         : EntryDetails.folder(
    //             context,
    //             repoCubit: repoCubit,
    //             entry: entry,
    //             isActionAvailableValidator: _isEntryActionAvailable,
    //           ),
    //   ),
    // ),
  );

  bool _isEntryActionAvailable(AccessMode accessMode, EntryAction action) {
    if (accessMode == AccessMode.write) return true;

    final readDisabledActions = [
      EntryAction.delete,
      EntryAction.copy,
      EntryAction.move,
      EntryAction.rename,
    ];

    return !readDisabledActions.contains(action);
  }

  Widget modalBottomSheet() =>
      BlocBuilder<EntryBottomSheetCubit, EntryBottomSheetState>(
        bloc: widget.reposCubit.bottomSheet,
        builder: (context, state) => switch (state) {
          MoveEntrySheetState() => _moveSingleEntryState(state),
          MoveSelectedEntriesSheetState() => _moveMultipleEntriesState(state),
          SaveMediaSheetState() => _saveSharedMediaState(state),
          HideSheetState() => _hideBottomSheet(),
        },
      );

  EntriesActionsDialog _moveSingleEntryState(MoveEntrySheetState state) =>
      EntriesActionsDialog.single(
        context,
        reposCubit: widget.reposCubit,
        originRepoCubit: state.repoCubit,
        entry: state.entry,
        sheetType: state.type,
        onUpdateBottomSheet: updateBottomSheetInfo,
        dirs: widget.dirs,
        stage: widget.stage,
      );

  EntriesActionsDialog _moveMultipleEntriesState(
    MoveSelectedEntriesSheetState state,
  ) => EntriesActionsDialog.multiple(
    context,
    reposCubit: widget.reposCubit,
    originRepoCubit: state.repoCubit,
    sheetType: state.type,
    onUpdateBottomSheet: updateBottomSheetInfo,
    dirs: widget.dirs,
    stage: widget.stage,
  );

  SaveSharedMedia _saveSharedMediaState(SaveMediaSheetState state) =>
      SaveSharedMedia(
        state.reposCubit,
        sharedMediaPaths: state.sharedMediaPaths,
        onUpdateBottomSheet: updateBottomSheetInfo,
        onSaveFile: trySaveFile,
        canSaveMedia: canSaveFiles,
      );

  Widget _hideBottomSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isBottomSheetInfoDisposed == false) {
        _bottomSheetInfo.value = BottomSheetInfo(
          type: BottomSheetType.gone,
          neededPadding: 0.0,
          entry: '',
        );
      }
    });

    return SizedBox.shrink();
  }

  void updateBottomSheetInfo(
    BottomSheetType type,
    double padding,
    String entry,
  ) {
    final newInfo = _bottomSheetInfo.value.copyWith(
      type: type,
      neededPadding: padding,
      entry: entry,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isBottomSheetInfoDisposed == false) {
        _bottomSheetInfo.value = newInfo;
      }
    });
  }

  Future<void> trySaveFile(String sourcePath) async {
    final current = widget.reposCubit.state.current;

    if (current is! OpenRepoEntry) {
      return;
    }

    await SaveMedia(
      context,
      repoCubit: current.cubit,
      sourcePath: sourcePath,
      type: EntryType.file,
      stage: widget.stage,
    ).save();
  }

  Future<bool> canSaveFiles() async {
    final current = widget.reposCubit.state.current;

    if (current is! OpenRepoEntry) {
      await SimpleAlertDialog.show(
        widget.stage,
        title: S.current.titleAddFile,
        message: S.current.messageNoRepo,
      );

      return false;
    }

    final accessModeMessage = current.cubit.state.canWrite
        ? null
        : current.cubit.state.canRead
        ? S.current.messageAddingFileToReadRepository
        : S.current.messageAddingFileToLockedRepository;

    if (accessModeMessage != null) {
      await widget.stage.showDialog<bool>(
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return AlertDialog(
            title: Flex(
              direction: Axis.horizontal,
              children: [
                Fields.constrainedText(
                  S.current.titleAddFile,
                  style: context.theme.appTextStyle.titleMedium,
                  maxLines: 2,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    accessModeMessage,
                    style: context.theme.appTextStyle.bodyMedium,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => widget.stage.maybePop(),
                child: Text(S.current.actionCloseCapital),
              ),
            ],
          );
        },
      );

      return false;
    }

    return true;
  }

  Future<void> handleReceivedMedia(List<SharedMediaFile> media) async {
    List<String> repos = [];
    List<String> files = [];
    List<String> tokens = [];

    for (final medium in media) {
      switch (medium.type) {
        case SharedMediaType.file
            when (widget.reposCubit.state.current == null ||
                    !PlatformValues.isDesktopDevice) &&
                system_path.extension(medium.path) ==
                    ".${RepoLocation.defaultExtension}":
          repos.add(medium.path);
        case SharedMediaType.file:
        case SharedMediaType.image:
        case SharedMediaType.video:
          files.add(medium.path);
        case SharedMediaType.url:
        case SharedMediaType.text:
          tokens.add(medium.path);
      }
    }

    // Handle imported repos
    for (final path in repos) {
      final location = RepoLocation.fromDbPath(path);
      await widget.reposCubit.importRepoFromLocation(location);
    }

    // Handle share tokens
    for (final token in tokens) {
      await importRepoDialog(initialTokenValue: token);
    }

    // Handle received files
    handleReceivedFiles(files);
  }

  void handleReceivedFiles(List<String> paths) {
    if (paths.isEmpty) {
      return;
    }

    widget.reposCubit.bottomSheet.showSaveMedia(
      reposCubit: widget.reposCubit,
      paths: paths,
    );
  }

  Future<void> _showDirectoryActions(OpenRepoEntry repo) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) => DirectoryActions(
          repoCubit: repo.cubit,
          bottomSheetCubit: widget.reposCubit.bottomSheet,
          stage: widget.stage,
        ),
      );

  Future<void> _showRepoListActions() => widget.stage.showModalBottomSheet(
    isScrollControlled: true,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) => RepoListActions(
      stage: widget.stage,
      reposCubit: widget.reposCubit,
      onCreateRepoPressed: _createRepo,
      onImportRepoPressed: _importRepo,
    ),
  );

  Future<RepoEntry?> _createRepo() async {
    final repoEntry = await createRepoDialog();

    if (repoEntry != null) {
      await widget.reposCubit.setCurrent(repoEntry);
    }

    return repoEntry;
  }

  Future<List<RepoEntry>> _importRepo() async {
    final repoEntries = await importRepoDialog();
    final repoEntry = repoEntries.singleOrNull;

    if (repoEntry != null) {
      await widget.reposCubit.setCurrent(repoEntry);
    }

    return repoEntries;
  }

  Future<RepoEntry?> createRepoDialog() => widget.stage.push<RepoEntry?>(
    MaterialPageRoute(
      builder: (context) => RepoCreationPage(
        stage: widget.stage,
        reposCubit: widget.reposCubit,
        storeDirsCubit: widget.storeDirsCubit,
      ),
    ),
  );

  Future<List<RepoEntry>> importRepoDialog({String? initialTokenValue}) async {
    RepoImportResult? result;

    final navigator = Navigator.of(context);

    if (initialTokenValue != null) {
      final tokenResult = await parseShareToken(
        widget.reposCubit,
        initialTokenValue,
      );
      switch (tokenResult) {
        case ShareTokenValid():
          result = RepoImportFromToken(tokenResult.value);
        case ShareTokenInvalid():
          widget.stage.showSnackBar(tokenResult.error.toString());
          return [];
      }
    } else {
      result = await navigator.push<RepoImportResult>(
        MaterialPageRoute(
          builder: (context) => RepoImportPage(
            reposCubit: widget.reposCubit,
            stage: widget.stage,
          ),
        ),
      );
    }

    switch (result) {
      case RepoImportFromToken(token: final token):
        final repoEntry = await navigator.push<RepoEntry?>(
          MaterialPageRoute(
            builder: (context) => RepoCreationPage(
              stage: widget.stage,
              reposCubit: widget.reposCubit,
              storeDirsCubit: widget.storeDirsCubit,
              token: token,
            ),
          ),
        );

        return repoEntry != null ? [repoEntry] : [];

      case RepoImportFromFiles():
        return result.locations
            .map((location) => widget.reposCubit.state.repos[location])
            .nonNulls
            .toList();

      case null:
        return [];
    }
  }

  Future<void> _showAppSettings() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SettingsPage(
        session: widget.session,
        localeCubit: widget.localeCubit,
        mount: widget.mountCubit,
        errorCubit: widget.errorCubit,
        powerControl: powerControl,
        reposCubit: widget.reposCubit,
        upgradeExists: upgradeExists,
        checkForDokan: checkForDokan,
        dirs: widget.dirs,
        stage: widget.stage,
      ),
    ),
  );

  Future<void> _showRepoSettings(
    BuildContext context, {
    required RepoCubit repoCubit,
  }) => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) => RepositorySettings(
      settings: widget.settings,
      session: widget.session,
      repoCubit: repoCubit,
      reposCubit: widget.reposCubit,
      storeDirsCubit: widget.storeDirsCubit,
      stage: widget.stage,
    ),
  );
}

Widget _progressIndicatorWidget() {
  // CircularProgressIndicator causes problems in tests making the
  // `pumpAndSettle` function time out. Note that making the tests wait until
  // the indicator disappears may not be ideal because we also want to test
  // what happens when tapping on a button while the indicator is still
  // spinning.
  if (!io.Platform.environment.containsKey('FLUTTER_TEST')) {
    return CircularProgressIndicator();
  } else {
    return Text("Working...");
  }
}
