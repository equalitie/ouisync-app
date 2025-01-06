import 'dart:async';
import 'dart:io' as io;

import 'package:build_context_provider/build_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync/state_monitor.dart' as oui;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as system_path;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/notification_badge.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef BottomSheetCallback = void Function(
  Widget? widget,
  double maxHeight,
  String entryPath,
);

typedef MoveEntryCallback = Future<bool> Function(
  String origin,
  String path,
  EntryType type,
);

typedef PreviewFileCallback = Future<void> Function(
  RepoCubit repo,
  FileEntry entry,
  bool useDefaultApp,
);

class MainPage extends StatefulWidget {
  const MainPage({
    required this.localeCubit,
    required this.mountCubit,
    required this.nativeChannels,
    required this.packageInfo,
    required this.powerControl,
    required this.receivedMedia,
    required this.reposCubit,
    required this.session,
    required this.settings,
    required this.windowManager,
  });

  final PlatformWindowManager windowManager;
  final Session session;
  final NativeChannels nativeChannels;
  final Settings settings;
  final PackageInfo packageInfo;
  final PowerControl powerControl;
  final Stream<List<SharedMediaFile>> receivedMedia;
  final ReposCubit reposCubit;
  final MountCubit mountCubit;
  final LocaleCubit localeCubit;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, AppLogger {
  late final StateMonitorIntCubit panicCounter;
  late final SortListCubit sortListCubit;
  late final UpgradeExistsCubit upgradeExists;

  final _bottomSheetInfo = ValueNotifier<BottomSheetInfo>(BottomSheetInfo(
    type: BottomSheetType.gone,
    neededPadding: 0.0,
    entry: '',
  ));

  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  final _appSettingsIconFocus =
      FocusNode(debugLabel: 'app_settings_icon_focus');

  final _fabFocus = FocusNode(debugLabel: 'fab_focus');

  StreamSubscription? _receivedMediaSubscription;

  RepoEntry? get _currentRepo => widget.reposCubit.currentRepo;

  @override
  void initState() {
    super.initState();

    panicCounter = StateMonitorIntCubit(
      widget.reposCubit.rootStateMonitor.child(
        oui.MonitorId.expectUnique("Session"),
      ),
      "panic_counter",
    );

    upgradeExists = UpgradeExistsCubit(
      widget.session,
      widget.settings,
    );

    sortListCubit = SortListCubit.create(
      sortBy: SortBy.name,
      direction: SortDirection.asc,
      listType: ListType.repos,
    );

    _receivedMediaSubscription =
        widget.receivedMedia.listen(handleReceivedMedia);

    if (io.Platform.isWindows) {
      checkForDokan();
    }
  }

  @override
  void dispose() {
    _bottomSheetInfo.dispose();
    _appSettingsIconFocus.dispose();
    _fabFocus.dispose();
    _receivedMediaSubscription?.cancel();

    unawaited(upgradeExists.close());
    unawaited(sortListCubit.close());
    unawaited(panicCounter.close());

    super.dispose();
  }

  getContent() {
    final current = _currentRepo;
    if (current is OpenRepoEntry) {
      current.cubit.refresh();
    }
  }

  void checkForDokan() {
    installationOk() => widget.mountCubit.init();
    Future<bool?> installationFailed() => Dialogs.simpleAlertDialog(
          context,
          title: S.current.titleDokanInstallation,
          message: S.current.messageDokanInstallationFailed,
        );

    final dokanValidation = DokanValidation(
      context,
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
          loggy.app('The Dokan version installed is supported: '
              '${dokanCheckResult.result!.name}');
          break;

        case null:
          loggy.app('Check Dokan installation status failed: '
              '${dokanCheckResult.error}');
          break;
      }
    });
  }

  Widget buildMainWidget(TextDirection directionality) {
    return widget.reposCubit.builder((repos) {
      final currentRepo = repos.currentRepo;
      final currentRepoCubit = currentRepo?.cubit;

      if (currentRepoCubit != null) {
        final isFolder = !repos.showList;
        currentRepoCubit.updateNavigation(isFolder: isFolder);
      }

      if (repos.repos.isNotEmpty && repos.showList) {
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
          reposCubit: repos,
          bottomSheetInfo: _bottomSheetInfo,
          onShowRepoSettings: _showRepoSettings,
        );
      }

      if (repos.isLoading || currentRepo is LoadingRepoEntry) {
        // This one is mainly for when we're unlocking the repository,
        // because during that time the current repository is destroyed so we
        // can't show it's content.
        return const Center(child: CircularProgressIndicator());
      }

      if (currentRepo is OpenRepoEntry) {
        final navigationPath = currentRepo.cubit.state.currentFolder.path;
        currentRepo.cubit.navigateTo(navigationPath);

        return _repositoryContentBuilder(currentRepo, directionality);
      }

      if (currentRepo is MissingRepoEntry) {
        return MissingRepositoryState(
            directionality: directionality,
            repositoryLocation: currentRepo.location,
            errorMessage: currentRepo.error,
            errorDescription: currentRepo.errorDescription,
            onBackToList: () => repos.setCurrent(null),
            reposCubit: repos);
      }

      if (currentRepo is ErrorRepoEntry) {
        // This is a general purpose error state.
        // errorDescription is required, but nullable.
        return ErrorState(
          directionality: directionality,
          errorMessage: currentRepo.error,
          errorDescription: currentRepo.errorDescription,
          onBackToList: () => repos.setCurrent(null),
        );
      }

      if (currentRepo == null) {
        return repos.repos.isNotEmpty
            ? SizedBox.shrink()
            : NoRepositoriesState(
                directionality: directionality,
                onCreateRepoPressed: _createRepo,
                onImportRepoPressed: _importRepo,
              );
      }

      return Center(child: Text(S.current.messageErrorUnhandledState));
    });
  }

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
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                Column(
                  children: [
                    Expanded(
                      child: buildMainWidget(Directionality.of(context)),
                    )
                  ],
                ),
                const ListenerThatRunsFunctionsWithBuildContext(),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniEndFloat,
          floatingActionButton: widget.reposCubit
              .builder((repos) => _buildFAB(context, repos.currentRepo)),
          bottomSheet: modalBottomSheet(),
        ),
      );

  Future<void> _onBackPressed(bool didPop, Object? result) async {
    final currentRepo = _currentRepo;

    if (currentRepo != null) {
      if (currentRepo is OpenRepoEntry) {
        final currentFolder = currentRepo.cubit.state.currentFolder;
        if (!currentFolder.isRoot) {
          await currentRepo.cubit.navigateTo(currentFolder.parent);
          return;
        }
      }

      widget.reposCubit.showRepoList();
      return;
    }

    int clickCount = exitClickCounter.registerClick();

    if (clickCount <= 1) {
      showSnackBar(S.current.messageExitOuiSync, context: context);
    } else {
      exitClickCounter.reset();
      await MoveToBackground.moveTaskToBack();
    }
  }

  _buildOuiSyncBar() => OuiSyncBar(
        reposCubit: widget.reposCubit,
        repoPicker: RepositoriesBar(
          mount: widget.mountCubit,
          panicCounter: panicCounter,
          powerControl: widget.powerControl,
          reposCubit: widget.reposCubit,
          upgradeExists: upgradeExists,
        ),
        appSettingsButton: _buildAppSettingsIcon(),
        searchButton: _buildSearchIcon(),
        repoSettingsButton: _buildRepoSettingsIcon(),
      );

  Widget _buildAppSettingsIcon() => NotificationBadge(
        mount: widget.mountCubit,
        panicCounter: panicCounter,
        powerControl: widget.powerControl,
        upgradeExists: upgradeExists,
        moveDownwards: 5,
        moveRight: 3,
        child: Fields.actionIcon(
          const Icon(Icons.settings_outlined),
          onPressed: _showAppSettings,
          size: Dimensions.sizeIconSmall,
        ),
      );

  Widget _buildRepoSettingsIcon() =>
      Fields.actionIcon(const Icon(Icons.more_vert_rounded),
          onPressed: () async {
        final cubit = _currentRepo?.cubit;
        if (cubit == null) {
          return;
        }

        await _showRepoSettings(context, repoCubit: cubit);
      }, size: Dimensions.sizeIconSmall);

  Widget _buildSearchIcon() => Fields.actionIcon(
        const Icon(Icons.search_rounded),
        onPressed: () {
          /// TODO: Implement searching
        },
        size: Dimensions.sizeIconSmall,
      );

  Widget _buildFAB(BuildContext context, RepoEntry? current) {
    final icon = const Icon(Icons.add_rounded);

    if (widget.reposCubit.showList) {
      if (widget.reposCubit.repos.isNotEmpty) {
        return FloatingActionButton(
          mini: true,
          focusNode: _fabFocus,
          heroTag: Constants.heroTagRepoListActions,
          child: icon,
          onPressed: () => unawaited(_showRepoListActions(context)),
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
            onPressed: () => unawaited(_showDirectoryActions(
              context,
              current,
            )),
          ),
        ),
      );
    }

    return Container();
  }

  Widget _repositoryContentBuilder(
    OpenRepoEntry repo,
    TextDirection directionality,
  ) =>
      BlocBuilder<RepoCubit, RepoState>(
        bloc: repo.cubit,
        builder: (context, state) => _selectLayoutWidget(directionality),
      );

  Widget _selectLayoutWidget(TextDirection directionality) {
    final current = _currentRepo;

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
          parentContext: context,
          directionality: directionality,
          repoCubit: current.cubit,
          masterKey: widget.settings.masterKey,
          passwordHasher: PasswordHasher(widget.session),
        );
      }

      _appSettingsIconFocus.unfocus();
      return _contentBrowser(current.cubit, directionality);
    }

    return Center(
      child: Text(
        S.current.messageErrorUnhandledState,
        textDirection: directionality,
      ),
    );
  }

  Widget _contentBrowser(RepoCubit repo, TextDirection directionality) {
    Widget child;
    final folder = repo.state.currentFolder;

    if (folder.content.isEmpty) {
      if (repo.state.isLoading) {
        child = const Center(child: CircularProgressIndicator());
      } else {
        _fabFocus.requestFocus();
        child = NoContentsState(
          directionality: directionality,
          repository: repo,
          path: folder.path,
        );
      }
    } else {
      child = _contentsList(repo);
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

  Future<void> _previewFile(
    RepoCubit repo,
    FileEntry entry,
    bool useDefaultApp,
  ) async {
    if (io.Platform.isAndroid) {
      // TODO: Consider using `launchUrl` also here, using the 'content://' scheme.

      final previewResult = await widget.nativeChannels.previewOuiSyncFile(
        widget.packageInfo.packageName,
        entry.path,
        entry.size ?? 0,
        useDefaultApp: useDefaultApp,
      );

      if (previewResult == PreviewFileResult.previewOK) return;

      final message = switch (previewResult) {
        PreviewFileResult.mimeTypeNull => S.current.messageUnknownFileExtension,
        PreviewFileResult.noDefaultApp => S.current.messageNoAppsForThisAction,
        _ => S.current.messageFilePreviewFailed
      };

      showSnackBar(message);
    } else if (io.Platform.isWindows ||
        io.Platform.isLinux ||
        io.Platform.isMacOS) {
      final mountPoint = repo.mountPoint;
      if (mountPoint == null) {
        showSnackBar(S.current.messageRepositoryNotMounted);
        return;
      }

      bool previewOk = false;
      var errorMessage = S.current.messagePreviewingFileFailed(entry.path);
      try {
        if (io.Platform.isWindows) {
          // Special non ASCII characters are encoded using Escape Encoding
          // https://datatracker.ietf.org/doc/html/rfc2396#section-2.4.1
          // which are not decoded back by the url_launcher plugin on Windows
          // before passing to the system for execution. Thus on Windows
          // we use the `launchUrlString` function instead of `launchUrl`.
          final path = '$mountPoint${entry.path}';
          final can = await canLaunchUrlString(path);
          previewOk = await launchUrlString(path);
        } else if (io.Platform.isMacOS) {
          // TODO: There is some issue with permissions, launchUrl doesn't work
          // and when I try to send this Uri to Swift to run
          // `NSWorkspace.shared.open(url)` it just returns `false`. Tried also
          // with running `url.startAccessingSecurityScopedResource()` but that
          // also just returns `false`. I'll leave this to later or to someone
          // who understands the macOS file permissions better.
          showSnackBar("Not yet implemented");
          return;
        } else {
          final url = Uri.parse('file:$mountPoint${entry.path}');
          final can = await canLaunchUrl(url);
          previewOk = await launchUrl(url);
        }
      } on PlatformException catch (e, st) {
        loggy.app(
          'Preview file (desktop): Error previewing file ${entry.path}:',
          e,
          st,
        );

        showSnackBar(S.current.messagePreviewingFileFailed(entry.path));
        return;
      }

      if (!previewOk) {
        showSnackBar(S.current.messageNoAppsForThisAction);
      }
    } else {
      /// Until we have a proper implementation for OSX (iOS, macOS), we are
      /// using a local HTTP server and the internet navigator previewer.
      try {
        final url = await Dialogs.executeFutureWithLoadingDialog(
          null,
          repo.previewFileUrl(entry.path),
        );

        await launchUrl(url);
      } on PlatformException catch (e, st) {
        loggy.app(
          '(FileServer) Error previewing file ${entry.path}:',
          e,
          st,
        );
      }
    }
  }

  Widget _contentsList(RepoCubit currentRepoCubit) {
    final contents = currentRepoCubit.state.currentFolder.content;
    final totalEntries = contents.length;

    return RefreshIndicator(
      onRefresh: () async => getContent(),
      child: Container(
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            color: Colors.transparent,
          ),
          itemCount: totalEntries,
          itemBuilder: (context, index) {
            final entry = contents[index];
            final key = ValueKey(entry.name);

            return Column(
              children: [
                switch (entry) {
                  FileEntry entry => FileListItem(
                      key: key,
                      entry: entry,
                      repoCubit: currentRepoCubit,
                      mainAction: () async {
                        if (_bottomSheetInfo.value.type ==
                            BottomSheetType.gone) {
                          await _previewFile(currentRepoCubit, entry, true);
                          return;
                        }

                        await _showMovingEntryAlertDialog(context);
                      },
                      verticalDotsAction: () async {
                        if (_bottomSheetInfo.value.type ==
                            BottomSheetType.gone) {
                          await _showFileDetails(currentRepoCubit, entry);
                          return;
                        }

                        await _showMovingEntryAlertDialog(context);
                      }),
                  DirectoryEntry entry => DirectoryListItem(
                      key: key,
                      entry: entry,
                      repoCubit: currentRepoCubit,
                      mainAction: () {
                        if (_bottomSheetInfo.value.entry != entry.path) {
                          currentRepoCubit.navigateTo(entry.path);
                          return;
                        }

                        // TODO: Show toast with explanation
                      },
                      verticalDotsAction: () async {
                        if (_bottomSheetInfo.value.type ==
                            BottomSheetType.gone) {
                          await _showFolderDetails(currentRepoCubit, entry);
                          return;
                        }

                        await _showMovingEntryAlertDialog(context);
                      },
                    ),
                },
                if (index == (totalEntries - 1)) SizedBox(height: 56)
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showMovingEntryAlertDialog(BuildContext context) =>
      Dialogs.simpleAlertDialog(
        context,
        title: S.current.titleMovingEntry,
        message: S.current.messageMovingEntry,
      );

  Future<dynamic> _showFileDetails(
    RepoCubit repoCubit,
    FileEntry entry,
  ) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) => FileDetail(
          repoCubit: repoCubit,
          entry: entry,
          onPreviewFile: (cubit, data, useDefaultApp) => _previewFile(
            cubit,
            data,
            useDefaultApp,
          ),
          isActionAvailableValidator: _isEntryActionAvailable,
          packageInfo: widget.packageInfo,
          nativeChannels: widget.nativeChannels,
        ),
      );

  Future<dynamic> _showFolderDetails(
    RepoCubit repoCubit,
    DirectoryEntry entry,
  ) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) => FolderDetail(
          context: context,
          repoCubit: repoCubit,
          entry: entry,
          isActionAvailableValidator: _isEntryActionAvailable,
        ),
      );

  bool _isEntryActionAvailable(
    AccessMode accessMode,
    EntryAction action,
  ) {
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
          HideSheetState() => SizedBox.shrink(),
        },
      );

  EntriesActionsDialog _moveSingleEntryState(MoveEntrySheetState state) =>
      EntriesActionsDialog.single(
        context,
        reposCubit: widget.reposCubit,
        originRepoCubit: state.repoCubit,
        navigationCubit: widget.reposCubit.navigation,
        entryPath: state.entryPath,
        entryType: state.entryType,
        sheetType: state.type,
        onUpdateBottomSheet: updateBottomSheetInfo,
      );

  EntriesActionsDialog _moveMultipleEntriesState(
    MoveSelectedEntriesSheetState state,
  ) =>
      EntriesActionsDialog.multiple(
        context,
        reposCubit: widget.reposCubit,
        originRepoCubit: state.repoCubit,
        navigationCubit: widget.reposCubit.navigation,
        entrySelectionCubit: state.repoCubit.entrySelectionCubit,
        sheetType: state.type,
        onUpdateBottomSheet: updateBottomSheetInfo,
      );

  SaveSharedMedia _saveSharedMediaState(SaveMediaSheetState state) =>
      SaveSharedMedia(
        state.reposCubit,
        sharedMediaPaths: state.sharedMediaPaths,
        onUpdateBottomSheet: updateBottomSheetInfo,
        onSaveFile: trySaveFile,
        canSaveMedia: canSaveFiles,
      );

  void updateBottomSheetInfo(
      BottomSheetType type, double padding, String entry) {
    final newInfo = _bottomSheetInfo.value.copyWith(
      type: type,
      neededPadding: padding,
      entry: entry,
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _bottomSheetInfo.value = newInfo);
  }

  Future<void> trySaveFile(String sourcePath) async {
    if (_currentRepo is! OpenRepoEntry) {
      return;
    }

    if (_currentRepo?.cubit == null) return;

    await SaveMedia(
      context,
      repoCubit: _currentRepo!.cubit!,
      sourcePath: sourcePath,
      type: EntryType.file,
    ).save();
  }

  Future<bool> canSaveFiles() async {
    final currentRepo = _currentRepo;
    if (currentRepo is! OpenRepoEntry) {
      await Dialogs.simpleAlertDialog(
        context,
        title: S.current.titleAddFile,
        message: S.current.messageNoRepo,
      );

      return false;
    }

    final accessModeMessage = currentRepo.cubit.state.canWrite
        ? null
        : currentRepo.cubit.state.canRead
            ? S.current.messageAddingFileToReadRepository
            : S.current.messageAddingFileToLockedRepository;

    if (accessModeMessage != null) {
      await showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (context) {
            return AlertDialog(
                title: Flex(direction: Axis.horizontal, children: [
                  Fields.constrainedText(S.current.titleAddFile,
                      style: context.theme.appTextStyle.titleMedium,
                      maxLines: 2)
                ]),
                content: SingleChildScrollView(
                    child: ListBody(children: [
                  Text(accessModeMessage,
                      style: context.theme.appTextStyle.bodyMedium)
                ])),
                actions: [
                  TextButton(
                      onPressed: () async =>
                          await Navigator.of(context).maybePop(),
                      child: Text(S.current.actionCloseCapital))
                ]);
          });

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
            when (widget.reposCubit.showList ||
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
      await importRepoDialog(context, initialTokenValue: token);
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

  Future<void> _showDirectoryActions(
    BuildContext parentContext,
    OpenRepoEntry repo,
  ) async =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: parentContext,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) => DirectoryActions(
          parentContext,
          repoCubit: repo.cubit,
          bottomSheetCubit: widget.reposCubit.bottomSheet,
        ),
      );

  Future<void> _showRepoListActions(BuildContext context) async =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) {
          return RepoListActions(
            context: context,
            reposCubit: widget.reposCubit,
            onCreateRepoPressed: _createRepo,
            onImportRepoPressed: _importRepo,
          );
        },
      );

  Future<RepoLocation?> _createRepo() async {
    final location = await createRepoDialog(context);

    if (location != null) {
      await setCurrent(location);
    }

    return location;
  }

  Future<List<RepoLocation>> _importRepo() async {
    final locations = await importRepoDialog(context);
    final location = locations.singleOrNull;

    if (location != null) {
      await setCurrent(location);
    }

    return locations;
  }

  Future<void> setCurrent(RepoLocation location) async {
    final repo = widget.reposCubit.get(location);
    await widget.reposCubit.setCurrent(repo);
  }

  Future<RepoLocation?> createRepoDialog(BuildContext parentContext) async =>
      Navigator.push<RepoLocation?>(
        context,
        MaterialPageRoute(
          builder: (context) => RepoCreationPage(
            reposCubit: widget.reposCubit,
          ),
        ),
      );

  Future<List<RepoLocation>> importRepoDialog(
    BuildContext parentContext, {
    String? initialTokenValue,
  }) async {
    RepoImportResult? result;

    if (initialTokenValue != null) {
      final tokenResult =
          await parseShareToken(widget.reposCubit, initialTokenValue);
      switch (tokenResult) {
        case ShareTokenValid():
          result = RepoImportFromToken(tokenResult.value);
        case ShareTokenInvalid():
          showSnackBar(tokenResult.error.toString());
          return [];
      }
    } else {
      result = await Navigator.push<RepoImportResult>(
        context,
        MaterialPageRoute(
          builder: (context) => RepoImportPage(reposCubit: widget.reposCubit),
        ),
      );
    }

    switch (result) {
      case RepoImportFromToken(token: final token):
        final location = await Navigator.push<RepoLocation>(
          context,
          MaterialPageRoute(
            builder: (context) => RepoCreationPage(
              reposCubit: widget.reposCubit,
              token: token,
            ),
          ),
        );

        return location != null ? [location] : [];

      case RepoImportFromFiles():
        return result.locations;

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
            panicCounter: panicCounter,
            powerControl: widget.powerControl,
            reposCubit: widget.reposCubit,
            upgradeExists: upgradeExists,
            checkForDokan: checkForDokan,
          ),
        ),
      );

  Future<void> _showRepoSettings(
    BuildContext context, {
    required RepoCubit repoCubit,
  }) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) {
          return RepositorySettings(
            settings: widget.settings,
            repoCubit: repoCubit,
            reposCubit: widget.reposCubit,
          );
        },
      );
}
