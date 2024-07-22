import 'dart:async';
import 'dart:io' as io;

import 'package:build_context_provider/build_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync_app/app/utils/share_token.dart';
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
import '../utils/click_counter.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
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

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, AppLogger {
  late final Cubits _cubits;
  late final SortListCubit _sortListCubit;

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

  RepoEntry? get _currentRepo => _cubits.repositories.currentRepo;

  @override
  void initState() {
    super.initState();

    final panicCounter = StateMonitorIntCubit(
      widget.reposCubit.rootStateMonitor.child(
        oui.MonitorId.expectUnique("Session"),
      ),
      "panic_counter",
    );

    final upgradeExists = UpgradeExistsCubit(
      widget.session.currentProtocolVersion,
      widget.settings,
    );

    _cubits = Cubits(
      repositories: widget.reposCubit,
      powerControl: widget.powerControl,
      panicCounter: panicCounter,
      upgradeExists: upgradeExists,
      windowManager: widget.windowManager,
      mount: MountCubit(widget.session),
    );

    final mountPoint = widget.settings.getMountPoint();
    if (mountPoint != null) {
      unawaited(_cubits.mount.mount(mountPoint));
    }

    _sortListCubit = SortListCubit.create(
        sortBy: SortBy.name,
        direction: SortDirection.asc,
        listType: ListType.repos);

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

    unawaited(_sortListCubit.close());
    unawaited(_cubits.mount.close());
    unawaited(_cubits.upgradeExists.close());
    unawaited(_cubits.panicCounter.close());

    super.dispose();
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
          loggy.app('The Dokan version installed is supported: ${result.name}');
        }
      case DokanResult.notFound:
        {
          //Install Dokan using the bundled MSI
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              unawaited(
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Fields.constrainedText(
                          S.current.titleDokanMissing,
                          style: context.theme.appTextStyle.titleMedium,
                          maxLines: 2,
                        )
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: context.theme.appTextStyle.bodyMedium,
                              children: [
                                TextSpan(
                                    text:
                                        '${S.current.messageInstallDokanForOuisyncP1} '),
                                Fields.linkTextSpan(
                                  context,
                                  S.current.messageDokan,
                                  _launchDokanGitHub,
                                ),
                                TextSpan(
                                    text:
                                        ' ${S.current.messageInstallDokanForOuisyncP2}')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text(S.current.actionSkip.toUpperCase()),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text(S.current.actionInstallDokan.toUpperCase()),
                        onPressed: () => Navigator.of(context).pop(true),
                      )
                    ],
                  ),
                ).then(
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
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              unawaited(
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Fields.constrainedText(
                          S.current.titleDokanInstallationFound,
                          style: context.theme.appTextStyle.titleMedium,
                          maxLines: 2,
                        )
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: context.theme.appTextStyle.bodyMedium,
                              children: [
                                TextSpan(
                                    text:
                                        '${S.current.messageDokanDifferentMayorP1} '),
                                Fields.linkTextSpan(
                                  context,
                                  S.current.messageDokan,
                                  _launchDokanGitHub,
                                ),
                                TextSpan(
                                    text:
                                        ' ${S.current.messageDokanDifferentMayorP2}')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text(S.current.actionSkip.toUpperCase()),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text(S.current.actionInstallDokan.toUpperCase()),
                        onPressed: () => Navigator.of(context).pop(true),
                      )
                    ],
                  ),
                ).then(
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
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => unawaited(
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog(
                  title: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Fields.constrainedText(
                        S.current.titleDokanInstallationFound,
                        style: context.theme.appTextStyle.titleMedium,
                        maxLines: 2,
                      )
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: context.theme.appTextStyle.bodyMedium,
                            children: [
                              TextSpan(
                                  text:
                                      '${S.current.messageDokanDifferentMayorP1} '),
                              Fields.linkTextSpan(
                                context,
                                S.current.messageDokan,
                                _launchDokanGitHub,
                              ),
                              TextSpan(
                                  text:
                                      ' ${S.current.messageDokanOlderVersionP2}')
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(S.current.actionCloseCapital),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(false),
                    )
                  ],
                ),
              ).then(
                (installDokan) async {
                  if (installDokan ?? false) {
                    unawaited(_installBundledDokan(
                        dokanCheck.runDokanMsiInstallation));
                  }
                },
              ),
            ),
          );
        }
    }
  }

  void _launchDokanGitHub(BuildContext context) async {
    final title = Text('Dokan');
    await Fields.openUrl(context, title, Constants.dokanUrl);
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

    await Dialogs.simpleAlertDialog(
      context: context,
      title: S.current.titleDokanInstallation,
      message: S.current.messageDokanInstallationFailed,
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
                onCreateRepoPressed: _createRepo,
                onImportRepoPressed: _importRepo,
              );
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
                children: [Expanded(child: buildMainWidget())],
              ),
              const ListenerThatRunsFunctionsWithBuildContext(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: _cubits.repositories
            .builder((repos) => _buildFAB(context, repos.currentRepo)),
        bottomSheet: modalBottomSheet(),
      );

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

    if (_cubits.repositories.showList) {
      if (_cubits.repositories.repos.isNotEmpty) {
        return FloatingActionButton(
          mini: true,
          focusNode: _fabFocus,
          heroTag: Constants.heroTagRepoListActions,
          child: icon,
          onPressed: () => _showRepoListActions(context),
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
            onPressed: () => _showDirectoryActions(context, current),
          ),
        ),
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
        onCreateRepoPressed: _createRepo,
        onImportRepoPressed: _importRepo,
      );
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

    return ValueListenableBuilder(
      valueListenable: _bottomSheetInfo,
      builder: (_, btInfo, __) => Container(
        padding: EdgeInsets.only(
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
            if (folder.content.isNotEmpty)
              SortContentsBar(
                sortListCubit: _sortListCubit,
                reposCubit: _cubits.repositories,
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
      try {
        if (!io.Platform.isWindows) {
          final url = Uri.parse('file:$mountPoint${entry.path}');
          previewOk = await launchUrl(url);
        } else {
          // Special non ASCII characters are encoded using Escape Encoding
          // https://datatracker.ietf.org/doc/html/rfc2396#section-2.4.1
          // which are not decoded back by the url_launcher plugin on Windows
          // before passing to the system for execution. Thus on Windows
          // we use the `launchUrlString` function instead of `launchUrl`.
          final path = '$mountPoint${entry.path}';
          previewOk = await launchUrlString(path);
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
      EntryAction.move,
      EntryAction.rename,
    ];

    return !readDisabledActions.contains(action);
  }

  Widget modalBottomSheet() =>
      BlocBuilder<EntryBottomSheetCubit, EntryBottomSheetState>(
        bloc: _cubits.repositories.bottomSheet,
        builder: (context, state) {
          Widget? sheet;

          if (state is MoveEntrySheetState) {
            sheet = _moveEntryState(
              repoCubit: state.repoCubit,
              navigationCubit: state.navigationCubit,
              entryPath: state.entryPath,
              entryType: state.entryType,
            );
          }

          if (state is SaveMediaSheetState) {
            sheet = _uploadFileState(
              reposCubit: state.reposCubit,
              paths: state.sharedMediaPaths,
            );
          }

          return sheet ?? SizedBox.shrink();
        },
      );

  Widget _moveEntryState({
    required RepoCubit repoCubit,
    required NavigationCubit navigationCubit,
    required String entryPath,
    required EntryType entryType,
  }) =>
      MoveEntryDialog(
        _cubits,
        originRepoCubit: repoCubit,
        entryPath: entryPath,
        onUpdateBottomSheet: updateBottomSheetInfo,
        onMoveEntry: () async => await moveEntry(
          repoCubit,
          entryPath,
          entryType,
        ),
        onCancel: _cubits.repositories.bottomSheet.hide,
      );

  Future<void> moveEntry(
    RepoCubit originRepoCubit,
    String entryPath,
    EntryType entryType,
  ) async {
    if (_currentRepo == null) return;

    final toRepoCubit =
        originRepoCubit.location.compareTo(_currentRepo!.location) != 0
            ? _currentRepo!.cubit
            : null;

    await MoveEntry(
      context,
      repoCubit: originRepoCubit,
      srcPath: entryPath,
      type: entryType,
    ).move(toRepoCubit: toRepoCubit);
  }

  Widget _uploadFileState({
    required ReposCubit reposCubit,
    required List<String> paths,
  }) =>
      SaveSharedMedia(
        reposCubit,
        sharedMediaPaths: paths,
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
    _bottomSheetInfo.value = newInfo;
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

  Future<void> handleReceivedMedia(List<SharedMediaFile> media) async {
    List<String> repos = [];
    List<String> files = [];
    List<String> tokens = [];

    for (final medium in media) {
      switch (medium.type) {
        case SharedMediaType.file
            when (_cubits.repositories.showList ||
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
      await _cubits.repositories.importRepoFromLocation(location);
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

    _cubits.repositories.bottomSheet.showSaveMedia(
      reposCubit: _cubits.repositories,
      paths: paths,
    );
  }

  Future<dynamic> _showDirectoryActions(
    BuildContext parentContext,
    OpenRepoEntry repo,
  ) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: parentContext,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) {
          return DirectoryActions(
            parentContext: parentContext,
            repoCubit: repo.cubit,
            bottomSheetCubit: _cubits.repositories.bottomSheet,
          );
        },
      );

  Future<dynamic> _showRepoListActions(BuildContext context) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) {
          return RepoListActions(
            context: context,
            reposCubit: _cubits.repositories,
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
    final repo = _cubits.repositories.get(location);
    await _cubits.repositories.setCurrent(repo);
  }

  Future<RepoLocation?> createRepoDialog(BuildContext parentContext) async =>
      Navigator.push<RepoLocation?>(
        context,
        MaterialPageRoute(
          builder: (context) => RepoCreationPage(
            reposCubit: _cubits.repositories,
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
          await parseShareToken(_cubits.repositories, initialTokenValue);
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
          builder: (context) =>
              RepoImportPage(reposCubit: _cubits.repositories),
        ),
      );
    }

    switch (result) {
      case RepoImportFromToken(token: final token):
        final location = await Navigator.push<RepoLocation>(
          context,
          MaterialPageRoute(
            builder: (context) => RepoCreationPage(
              reposCubit: _cubits.repositories,
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
