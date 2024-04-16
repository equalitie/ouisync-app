import 'dart:async';
import 'dart:io' as io;

import 'package:build_context_provider/build_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/state_monitor.dart' as oui;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as system_path;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../utils/click_counter.dart';
import '../utils/platform/platform.dart';
import '../utils/path.dart' as repo_path;
import '../utils/utils.dart';
import '../widgets/repository_progress.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef BottomSheetCallback = void Function(Widget? widget, String entryPath);

typedef MoveEntryCallback = Future<bool> Function(
    String origin, String path, EntryType type);

typedef PreviewFileCallback = Future<void> Function(
    RepoCubit repo, FileEntry entry, bool useDefaultApp);

class MainPage extends StatefulWidget {
  const MainPage({
    required this.windowManager,
    required this.session,
    required this.nativeChannels,
    required this.settings,
    required this.mediaReceiver,
    required this.upgradeExists,
    required this.navigation,
    required this.packageInfo,
  });

  final PlatformWindowManager windowManager;
  final Session session;
  final NativeChannels nativeChannels;
  final Settings settings;
  final MediaReceiver mediaReceiver;
  final UpgradeExistsCubit upgradeExists;
  final NavigationCubit navigation;
  final PackageInfo packageInfo;

  @override
  State<StatefulWidget> createState() => _MainPageState(
        windowManager: windowManager,
        session: session,
        nativeChannels: nativeChannels,
        settings: settings,
        upgradeExists: upgradeExists,
        navigation: navigation,
      );
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, AppLogger {
  final Cubits _cubits;

  String _pathEntryToMove = '';
  Widget? _bottomSheet;

  final double defaultBottomPadding = kFloatingActionButtonMargin +
      Dimensions.paddingBottomWithFloatingButtonExtra;
  ValueNotifier<double> _bottomPaddingWithBottomSheet =
      ValueNotifier<double>(0.0);

  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  final FocusNode _appSettingsIconFocus =
      FocusNode(debugLabel: 'app_settings_icon_focus');

  final FocusNode _fabFocus = FocusNode(debugLabel: 'fab_focus');

  _MainPageState._(this._cubits);

  factory _MainPageState({
    required PlatformWindowManager windowManager,
    required Session session,
    required NativeChannels nativeChannels,
    required Settings settings,
    required UpgradeExistsCubit upgradeExists,
    required NavigationCubit navigation,
  }) {
    final repositories = ReposCubit(
      session: session,
      nativeChannels: nativeChannels,
      settings: settings,
      navigation: navigation,
    );
    final powerControl = PowerControl(session, settings);
    final panicCounter = StateMonitorIntCubit(
      repositories.rootStateMonitor
          .child(oui.MonitorId.expectUnique("Session")),
      "panic_counter",
    );

    final mount = MountCubit(session);
    final mountPoint = settings.getMountPoint();
    if (mountPoint != null) {
      unawaited(mount.mount(mountPoint));
    }

    return _MainPageState._(Cubits(
      repositories: repositories,
      powerControl: powerControl,
      panicCounter: panicCounter,
      upgradeExists: upgradeExists,
      windowManager: windowManager,
      mount: mount,
      navigation: navigation,
    ));
  }

  RepoEntry? get _currentRepo => _cubits.repositories.currentRepo;

  late final SortListCubit _sortListCubit;

  @override
  void initState() {
    _sortListCubit = SortListCubit.create(
        sortBy: SortBy.name,
        direction: SortDirection.asc,
        listType: ListType.repos);

    super.initState();

    widget.session.networkEvents.listen((event) async {
      switch (event) {
        case NetworkEvent.peerSetChange:
          break;
        case NetworkEvent.protocolVersionMismatch:
          {
            final highest = await widget.session.highestSeenProtocolVersion;
            await _cubits.upgradeExists.foundVersion(highest);
          }
          break;
      }
    });

    unawaited(_cubits.repositories.init().then((_) {
      initMainPage();
    }));

    unawaited(_cubits.powerControl.init());

    /// The MediaReceiver uses the MediaReceiverMobile (_mediaIntentSubscription, _textIntentSubscription),
    /// or the MediaReceiverWindows (DropTarget), depending on the platform.
    widget.mediaReceiver.controller.stream.listen((media) {
      // Media is a String when it is a share token.
      if (media is String) {
        loggy.app('mediaReceiver: String');
        unawaited(addRepoWithTokenDialog(context, initialTokenValue: media));
      }

      // Check if the user tries to import/load a repository to Ouisync.
      // On desktops this is drag-and-drop into the repository list, on mobile
      // it's sharing from another application.
      if (_cubits.repositories.showList || !PlatformValues.isDesktopDevice) {
        var files = <String>[];

        if (media is io.File) {
          files.add(media.path);
        } else if (media is List<SharedMediaFile>) {
          for (final file in media) {
            files.add(file.path);
          }
        }

        files = files
            .where((path) =>
                system_path.extension(path) == RepoLocation.defaultExtension)
            .toList();

        if (files.isNotEmpty) {
          unawaited(() async {
            for (final file in files) {
              final location = RepoLocation.fromDbPath(file);
              await _cubits.repositories.importRepoFromLocation(location);
            }
          }());
          return;
        }
      }

      // Media is a list of SharedMediaFile when on mobile some application
      // shares a file with Ouisync.
      if (media is List<SharedMediaFile>) {
        loggy.app('mediaReceiver: List<ShareMediaFile>');
        handleShareIntentPayload(media, _cubits.repositories);
      }

      // Media is io.File when on desktops the user drags and drops a file to
      // Ouisync.
      if (media is io.File) {
        loggy.app('mediaReceiver: io.File');
        saveMedia(media.path);
      }
    });

    if (io.Platform.isWindows) {
      checkForDokan();
    }
  }

  @override
  void dispose() async {
    await _cubits.repositories.close();

    _appSettingsIconFocus.dispose();
    _fabFocus.dispose();

    super.dispose();
  }

  void initMainPage() async {
    _bottomPaddingWithBottomSheet = ValueNotifier<double>(defaultBottomPadding);
  }

  void handleShareIntentPayload(
      List<SharedMediaFile> payload, ReposCubit repos) {
    if (payload.isEmpty) {
      return;
    }

    _bottomPaddingWithBottomSheet.value =
        defaultBottomPadding + Dimensions.paddingBottomWithBottomSheetExtra;

    final bottomSheetSaveMedia = SaveSharedMedia(repos,
        sharedMedia: payload,
        onUpdateBottomSheet: updateBottomSheet,
        onSaveFile: saveMedia,
        validationFunction: canSaveMedia);

    setState(() => _bottomSheet = bottomSheetSaveMedia);
  }

  getContent() {
    final current = _currentRepo;
    if (current is OpenRepoEntry) {
      current.cubit.refresh();
    }
  }

  void checkForDokan() {
    final dokanCheck = DokanCheck(
      requiredMayor: Constants.dokanMayorRequired,
      minimumRequiredVersion: Constants.dokanMinimunVersion,
    );

    final dokanCheckResult = dokanCheck.checkDokanInstallation();
    final result = dokanCheckResult.result;

    if (result == null) return;

    switch (result) {
      case DokanResult.sameVersion:
      case DokanResult.newerVersionMayor:
        {
          // No install required
          loggy.app(
            'The Dokan version installed is supported: ${result.name}',
          );
        }
      case DokanResult.notFound:
        {
          //Install Dokan using the bundled MSI
          final dokanNotFoundMessage =
              'Ouisync uses Dokan for mounting unlocked repositories as drives, '
              'which later can be found in the File Explorer.\n\n'
              'We can try to install it for you';

          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              unawaited(
                Dialogs.simpleAlertDialog(
                    context: context,
                    title: 'Dokan ${Constants.dokanMinimunVersion} missing',
                    message: dokanNotFoundMessage,
                    actions: [
                      TextButton(
                          child: Text('SKIP INSTALLATION'),
                          onPressed: () => Navigator.of(context).pop(false)),
                      TextButton(
                          child: Text(
                              'INSTALL DOKAN ${Constants.dokanMinimunVersion}'),
                          onPressed: () => Navigator.of(context).pop(true))
                    ]).then(
                  (installDokan) async {
                    if (installDokan ?? false) {
                      unawaited(_installBundledDokan(
                          dokanCheck.runDokanMsiInstallation));
                    }
                  },
                ),
              );
            },
          );
        }
      case DokanResult.differentMayor:
        {
          final dokanDifferentMayorMessage =
              'Ouisync uses Dokan for mounting unlocked repositories as drives, '
              'which later can be found in the File Explorer.\n\n'
              'We found a different mayor version of Dokan thant the version '
              'required for Ouisync, but we can try to install it for you';

          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              unawaited(
                Dialogs.simpleAlertDialog(
                    context: context,
                    title: 'Dokan ${Constants.dokanMayorRequired} missing',
                    message: dokanDifferentMayorMessage,
                    actions: [
                      TextButton(
                          child: Text('SKIP INSTALLATION'),
                          onPressed: () => Navigator.of(context).pop(false)),
                      TextButton(
                          child: Text(
                              'INSTALL DOKAN ${Constants.dokanMinimunVersion}'),
                          onPressed: () => Navigator.of(context).pop(true))
                    ]).then(
                  (installDokan) async {
                    if (installDokan ?? false) {
                      unawaited(_installBundledDokan(
                          dokanCheck.runDokanMsiInstallation));
                    }
                  },
                ),
              );
            },
          );
        }
      case DokanResult.olderVersionMayor:
        {
          final dokanOlderVersionMessage =
              'A previous version of Dokan is already installed.\n\n'
              'Please uninstall the existing version '
              '${Constants.dokanMayorRequired} of Dokan, reboot the system and '
              'run Ouisync again';

          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              unawaited(
                Dialogs.simpleAlertDialog(
                  context: context,
                  title: 'Dokan ${Constants.dokanMayorRequired} found',
                  message: dokanOlderVersionMessage,
                ),
              );
            },
          );
        }
    }
  }

  Future<void> _installBundledDokan(
      Future<bool?> Function() runDokanMsiInstallation) async {
    final installationResult = await runDokanMsiInstallation();

    if (installationResult == null) {
      return;
    }

    if (installationResult) {
      final mountPoint = _cubits.repositories.settings.getMountPoint();
      if (mountPoint != null) {
        unawaited(_cubits.mount.mount(mountPoint));
      }

      return;
    }

    final message = 'The Dokan installation failed';
    await Dialogs.simpleAlertDialog(
      context: context,
      title: 'Dokan check',
      message: message,
    );
  }

  Widget buildMainWidget() {
    return _cubits.repositories.builder((repos) {
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

        /// Usiing the "back" arrow causes the app settings icon (gear) to get
        /// the focus, even if we explicitly ask for it to losse it.
        /// So for now we request focus for the FAB, then unfocused it.
        _fabFocus.requestFocus();
        _fabFocus.unfocus();

        return RepoListState(
          reposCubit: repos,
          bottomPaddingWithBottomSheet: _bottomPaddingWithBottomSheet,
          onShowRepoSettings: _showRepoSettings,
          onNewRepositoryPressed: _addRepository,
          onImportRepositoryPressed: _importRepository,
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

        return _repositoryContentBuilder(currentRepo);
      }

      if (currentRepo is MissingRepoEntry) {
        return MissingRepositoryState(
            repositoryLocation: currentRepo.location,
            errorMessage: currentRepo.error,
            errorDescription: currentRepo.errorDescription,
            onReloadRepository: null,
            reposCubit: repos);
      }

      if (currentRepo is ErrorRepoEntry) {
        // This is a general purpose error state.
        // errorDescription is required, but nullable.
        return ErrorState(
          errorMessage: currentRepo.error,
          errorDescription: currentRepo.errorDescription,
          onReload: () => repos.setCurrent(null),
        );
      }

      if (currentRepo == null) {
        return repos.repos.isNotEmpty
            ? SizedBox.shrink()
            : NoRepositoriesState(
                onNewRepositoryPressed: _addRepository,
                onImportRepositoryPressed: _importRepository);
      }

      return Center(child: Text(S.current.messageErrorUnhandledState));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildOuiSyncBar(),
      body: PopScope(
        // Don't pop => don't exit
        //
        // We don't want to do the pop because that would destroy the current Isolate's execution
        // context and we would lose track of open OuiSync objects (i.e. repositories, files,
        // directories, network handles,...). This is bad because even though the current execution
        // context is deleted, the OuiSync Rust global variables and threads stay alive. If the
        // user at that point tried to open the app again, this widget would try to reinitialize
        // all those variables without previously properly closing them.
        canPop: false,
        onPopInvoked: _onBackPressed,
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            Column(
              children: [
                Expanded(child: buildMainWidget()),
              ],
            ),
            _cubits.repositories.builder(
              (repos) => RepositoryProgress(repos.currentRepo?.cubit),
            ),
            const ListenerThatRunsFunctionsWithBuildContext(),
          ],
        ),
      ),
      floatingActionButton: _cubits.repositories
          .builder((repos) => _buildFAB(context, repos.currentRepo)),
      bottomSheet: _bottomSheet);

  Future<void> _onBackPressed(bool didPop) async {
    final currentRepo = _currentRepo;

    if (currentRepo != null) {
      if (currentRepo is OpenRepoEntry) {
        final currentFolder = currentRepo.cubit.state.currentFolder;
        if (!currentFolder.isRoot) {
          await currentRepo.cubit.navigateTo(currentFolder.parent);
          return;
        }
      }

      _cubits.repositories.showRepoList();
      return;
    }

    int clickCount = exitClickCounter.registerClick();

    if (clickCount <= 1) {
      showSnackBar(S.current.messageExitOuiSync);
    } else {
      exitClickCounter.reset();
      await MoveToBackground.moveTaskToBack();
    }
  }

  _buildOuiSyncBar() => OuiSyncBar(
        reposCubit: _cubits.repositories,
        repoPicker: RepositoriesBar(_cubits),
        appSettingsButton: _buildAppSettingsIcon(),
        searchButton: _buildSearchIcon(),
        repoSettingsButton: _buildRepoSettingsIcon(),
      );

  Widget _buildAppSettingsIcon() {
    final button = Fields.actionIcon(const Icon(Icons.settings_outlined),
        onPressed: _showAppSettings, size: Dimensions.sizeIconSmall);

    return multiBlocBuilder([
      _cubits.upgradeExists,
      _cubits.powerControl,
      _cubits.panicCounter,
      _cubits.mount,
    ], () {
      Color? color = _cubits.mainNotificationBadgeColor();

      if (color != null) {
        return Fields.addBadge(button,
            color: color, moveDownwards: 5, moveRight: 3);
      } else {
        return button;
      }
    });
  }

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

    if (_cubits.repositories.showList &&
        _cubits.repositories.repos.isNotEmpty) {
      return FloatingActionButton(
        focusNode: _fabFocus,
        heroTag: Constants.heroTagRepoListActions,
        child: icon,
        onPressed: () => _showRepoListActions(context),
      );
    }

    if (current is OpenRepoEntry &&
        current.cubit.state.canWrite &&
        !_cubits.repositories.showList) {
      return FloatingActionButton(
        focusNode: _fabFocus,
        heroTag: Constants.heroTagMainPageActions,
        child: icon,
        onPressed: () => _showDirectoryActions(context, current),
      );
    }

    return Container();
  }

  Widget _repositoryContentBuilder(OpenRepoEntry repo) =>
      BlocBuilder<RepoCubit, RepoState>(
        bloc: repo.cubit,
        builder: (context, state) => _selectLayoutWidget(),
      );

  Widget _selectLayoutWidget() {
    final current = _currentRepo;

    if (current == null || current is LoadingRepoEntry) {
      return NoRepositoriesState(
          onNewRepositoryPressed: _addRepository,
          onImportRepositoryPressed: _importRepository);
    }

    if (current is OpenRepoEntry) {
      if (!current.cubit.state.canRead) {
        return LockedRepositoryState(
          parentContext: context,
          repoCubit: current.cubit,
          masterKey: widget.settings.masterKey,
          passwordHasher: PasswordHasher(widget.session),
        );
      }

      _appSettingsIconFocus.unfocus();
      return _contentBrowser(current.cubit);
    }

    return Center(child: Text(S.current.messageErrorUnhandledState));
  }

  Widget _contentBrowser(RepoCubit repo) {
    Widget child;
    final folder = repo.state.currentFolder;

    if (folder.content.isEmpty) {
      if (repo.state.isLoading) {
        child = const Center(child: CircularProgressIndicator());
      } else {
        _fabFocus.requestFocus();
        child = NoContentsState(repository: repo, path: folder.path);
      }
    } else {
      child = _contentsList(repo);
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // TODO: A shadow would be nicer.
          const Divider(height: 1),
          if (folder.content.isNotEmpty)
            SortContentsBar(
              sortListCubit: _sortListCubit,
              reposCubit: _cubits.repositories,
            ),
          Expanded(child: child),
        ],
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
      final mountedDirectory = repo.mountedDirectory();
      if (mountedDirectory == null) {
        showSnackBar(S.current.messageRepositoryNotMounted);
        return;
      }

      bool previewOk = false;
      try {
        final url = Uri.parse('file:$mountedDirectory${entry.path}');
        previewOk = await launchUrl(url);
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
          context,
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

  Widget _contentsList(RepoCubit currentRepoCubit) => ValueListenableBuilder(
        valueListenable: _bottomPaddingWithBottomSheet,
        builder: (context, value, child) => RefreshIndicator(
          onRefresh: () async => getContent(),
          child: ListView.separated(
            padding: EdgeInsets.only(bottom: value),
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Colors.transparent,
            ),
            itemCount: currentRepoCubit.state.currentFolder.content.length,
            itemBuilder: (context, index) {
              final entry = currentRepoCubit.state.currentFolder.content[index];
              final key = ValueKey(entry.name);

              return switch (entry) {
                FileEntry entry => FileListItem(
                    key: key,
                    entry: entry,
                    repoCubit: currentRepoCubit,
                    mainAction: () async {
                      if (_bottomSheet != null) {
                        await _showMovingEntryAlertDialog(context);
                        return;
                      }

                      await _previewFile(currentRepoCubit, entry, true);
                    },
                    verticalDotsAction: () async {
                      if (_bottomSheet != null) {
                        await _showMovingEntryAlertDialog(context);
                        return;
                      }

                      await _showFileDetails(currentRepoCubit, entry);
                    }),
                DirectoryEntry entry => DirectoryListItem(
                    key: key,
                    entry: entry,
                    mainAction: () {
                      if (_bottomSheet != null &&
                          _pathEntryToMove == entry.path) {
                        return;
                      }

                      currentRepoCubit.navigateTo(entry.path);
                    },
                    verticalDotsAction: () async {
                      if (_bottomSheet != null) {
                        await _showMovingEntryAlertDialog(context);
                        return;
                      }

                      await _showFolderDetails(currentRepoCubit, entry);
                    },
                  ),
              };
            },
          ),
        ),
      );

  Future<void> _showMovingEntryAlertDialog(BuildContext context) =>
      Dialogs.simpleAlertDialog(
        context: context,
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
          repo: repoCubit,
          navigation: widget.navigation,
          entry: entry,
          onUpdateBottomSheet: updateBottomSheet,
          onPreviewFile: (cubit, data, useDefaultApp) =>
              _previewFile(cubit, data, useDefaultApp),
          onMoveEntry: (origin, path, type) =>
              moveEntry(repoCubit, origin, path, type),
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
                repo: repoCubit,
                navigation: widget.navigation,
                entry: entry,
                onUpdateBottomSheet: updateBottomSheet,
                onMoveEntry: (origin, path, type) =>
                    moveEntry(repoCubit, origin, path, type),
                isActionAvailableValidator: _isEntryActionAvailable,
              ));

  void updateBottomSheet(Widget? widget, String entryPath) {
    _pathEntryToMove = entryPath;
    _bottomPaddingWithBottomSheet.value = defaultBottomPadding;

    setState(() => _bottomSheet = widget);
  }

  bool _isEntryActionAvailable(
    AccessMode accessMode,
    EntryAction action,
  ) {
    if (accessMode == AccessMode.write) return true;

    final readDisabledActions = [
      EntryAction.delete,
      EntryAction.move,
      EntryAction.rename,
    ];

    return !readDisabledActions.contains(action);
  }

  Future<bool> moveEntry(
    RepoCubit currentRepo,
    String origin,
    String path,
    EntryType type,
  ) async {
    final basename = repo_path.basename(path);
    final destination = repo_path.join(
      currentRepo.state.currentFolder.path,
      basename,
    );

    _bottomSheet = null;

    return currentRepo.moveEntry(
      source: path,
      destination: destination,
    );
  }

  Future<void> saveMedia(String sourceFilePath) async {
    final currentRepo = _currentRepo;

    if (currentRepo is! OpenRepoEntry) {
      return;
    }

    loggy.app('Media path: $sourceFilePath');
    await saveFileToOuiSync(currentRepo.cubit, sourceFilePath);
  }

  Future<bool> canSaveMedia() async {
    final currentRepo = _currentRepo;
    if (currentRepo is! OpenRepoEntry) {
      await Dialogs.simpleAlertDialog(
          context: context,
          title: S.current.titleAddFile,
          message: S.current.messageNoRepo);

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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.current.actionCloseCapital))
                ]);
          });

      return false;
    }

    return true;
  }

  Future<void> saveFileToOuiSync(
    RepoCubit currentRepo,
    String path,
  ) async {
    final file = io.File(path);
    final fileName = repo_path.basename(path);
    final length = (await file.stat()).size;
    final filePath = repo_path.join(
      currentRepo.state.currentFolder.path,
      fileName,
    );
    final fileByteStream = file.openRead();

    await currentRepo.saveFile(
      filePath: filePath,
      length: length,
      fileByteStream: fileByteStream,
    );
  }

  Future<dynamic> _showDirectoryActions(
    BuildContext context,
    OpenRepoEntry repo,
  ) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return DirectoryActions(
              context: context,
              cubit: repo.cubit,
            );
          });

  Future<dynamic> _showRepoListActions(BuildContext context) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return RepoListActions(
                context: context,
                reposCubit: _cubits.repositories,
                onNewRepositoryPressed: _addRepository,
                onImportRepositoryPressed: _importRepository);
          });

  Future<RepoLocation?> _addRepository() async =>
      _addRepoAndNavigate(await createRepoDialog(context));

  Future<RepoLocation?> _importRepository() async =>
      _addRepoAndNavigate(await addRepoWithTokenDialog(context));

  Future<RepoLocation?> _addRepoAndNavigate(
    RepoLocation? newRepoLocation,
  ) async {
    if (newRepoLocation == null || newRepoLocation.name.isEmpty) {
      return null;
    }

    final repo = _cubits.repositories.get(newRepoLocation);
    await _cubits.repositories.setCurrent(repo);

    return newRepoLocation;
  }

  Future<RepoLocation?> createRepoDialog(BuildContext parentContext) async =>
      showDialog<RepoLocation>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ScaffoldMessenger(
          child: Builder(
            builder: ((context) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: ActionsDialog(
                  title: S.current.titleCreateRepository,
                  body: RepositoryCreation(
                    reposCubit: _cubits.repositories,
                  ),
                ),
              );
            }),
          ),
        ),
      );

  Future<RepoLocation?> addRepoWithTokenDialog(BuildContext parentContext,
      {String? initialTokenValue}) async {
    initialTokenValue ??= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return AddRepositoryPage(reposCubit: _cubits.repositories);
      }),
    );

    if (initialTokenValue == null) return null;

    final tokenValidationError =
        await _cubits.repositories.validateTokenLink(initialTokenValue);
    if (tokenValidationError != null) {
      await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Flex(direction: Axis.horizontal, children: [
                Fields.constrainedText(S.current.titleAddRepository,
                    style: context.theme.appTextStyle.titleMedium, maxLines: 2)
              ]),
              content: Text(tokenValidationError,
                  style: context.theme.appTextStyle.bodyMedium),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.current.actionOK))
              ],
            );
          });

      return null;
    }

    return showDialog<RepoLocation>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ScaffoldMessenger(
        child: Builder(
          builder: ((context) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: ActionsDialog(
                title: S.current.titleAddRepository,
                body: RepositoryCreation(
                  reposCubit: _cubits.repositories,
                  initialTokenValue: initialTokenValue,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void reloadRepository() => _cubits.repositories.init();

  Future<void> _showAppSettings() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsPage(
            widget.session,
            _cubits,
            checkForDokan,
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
            context: context,
            settings: widget.settings,
            repoCubit: repoCubit,
            reposCubit: _cubits.repositories,
          );
        },
      );
}
