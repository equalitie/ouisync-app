import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/state_monitor.dart' as oui;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../mixins/mixins.dart';
import '../models/models.dart';
import '../utils/click_counter.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/repository_progress.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef BottomSheetCallback = void Function(Widget? widget, String entryPath);

typedef MoveEntryCallback = void Function(
    String origin, String path, EntryType type);

class MainPage extends StatefulWidget {
  const MainPage(
      {required this.session,
      required this.upgradeExists,
      required this.backgroundServiceManager,
      required this.mediaReceiver,
      required this.settings,
      required this.windowManager});

  final Session session;
  final UpgradeExistsCubit upgradeExists;
  final BackgroundServiceManager backgroundServiceManager;
  final MediaReceiver mediaReceiver;
  final Settings settings;
  final PlatformWindowManager windowManager;

  @override
  State<StatefulWidget> createState() => _MainPageState(session, upgradeExists,
      backgroundServiceManager, settings, windowManager);
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, AppLogger, RepositoryActionsMixin {
  final Cubits _cubits;

  String _pathEntryToMove = '';
  Widget? _bottomSheet;

  final double defaultBottomPadding = kFloatingActionButtonMargin +
      Dimensions.paddingBottomWithFloatingButtonExtra;
  ValueNotifier<double> _bottomPaddingWithBottomSheet =
      ValueNotifier<double>(0.0);

  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  _MainPageState._(this._cubits);

  factory _MainPageState(
      Session session,
      UpgradeExistsCubit upgradeExists,
      BackgroundServiceManager backgroundServiceManager,
      Settings settings,
      PlatformWindowManager windowManager) {
    final repositories = ReposCubit(
      session: session,
      settings: settings,
    );
    final powerControl = PowerControl(session, settings);
    final panicCounter = StateMonitorIntCubit(
        repositories.rootStateMonitor
            .child(oui.MonitorId.expectUnique("Session")),
        "panic_counter");

    return _MainPageState._(Cubits(repositories, powerControl, panicCounter,
        upgradeExists, backgroundServiceManager, windowManager));
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
      if (media is String) {
        loggy.app('mediaReceiver: String');
        unawaited(addRepoWithTokenDialog(context, initialTokenValue: media));
      }

      if (media is List<SharedMediaFile>) {
        loggy.app('mediaReceiver: List<ShareMediaFile>');
        handleShareIntentPayload(media);
      }

      if (media is io.File) {
        loggy.app('mediaReceiver: io.File');
        saveMedia(media.path);
      }
    });
  }

  @override
  void dispose() async {
    await _cubits.repositories.close();
    super.dispose();
  }

  Future<bool?> _checkForBiometricsCallback() async {
    if (!io.Platform.isAndroid &&
        !io.Platform.isIOS &&
        !io.Platform.isWindows) {
      return null;
    }

    final auth = LocalAuthentication();

    final isBiometricsAvailable = await auth.canCheckBiometrics;

    // The device doesn't have biometrics
    if (!isBiometricsAvailable) return null;

    final availableBiometrics = await auth.getAvailableBiometrics();

    // The device has biometrics capabilites, but not in use'.
    if (availableBiometrics.isEmpty) return false;

    return true;
  }

  void initMainPage() async {
    _bottomPaddingWithBottomSheet = ValueNotifier<double>(defaultBottomPadding);
  }

  void handleShareIntentPayload(List<SharedMediaFile> payload) {
    if (payload.isEmpty) {
      return;
    }

    _bottomPaddingWithBottomSheet.value =
        defaultBottomPadding + Dimensions.paddingBottomWithBottomSheetExtra;

    final bottomSheetSaveMedia = SaveSharedMedia(
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

  Widget buildMainWidget() {
    return _cubits.repositories.builder((repos) {
      if (repos.showList) {
        /// This needs to be structured better
        /// TODO: Add sorting to repo list
        // _sortListCubit?.sortBy(SortBy.name);

        // final sortBy = SortBy.name;
        // final sortDirection =
        //     _sortListCubit?.state.direction ?? SortDirection.asc;

        return RepoListState(
            reposCubit: repos,
            bottomPaddingWithBottomSheet: _bottomPaddingWithBottomSheet,
            onCheckForBiometrics: _checkForBiometricsCallback,
            onShowRepoSettings: _showRepoSettings,
            onNewRepositoryPressed: _addRepository,
            onImportRepositoryPressed: _importRepository,
            onGetAuthenticationMode: widget.settings.getAuthenticationMode);
      }

      final current = repos.currentRepo;

      if (repos.isLoading || current is LoadingRepoEntry) {
        // This one is mainly for when we're unlocking the repository,
        // because during that time the current repository is destroyed so we
        // can't show it's content.
        return const Center(child: CircularProgressIndicator());
      }

      if (current is OpenRepoEntry) {
        current.cubit.navigateTo(Strings.root);
        return _repositoryContentBuilder(current);
      }

      if (current is MissingRepoEntry) {
        return MissingRepositoryState(
            repositoryName: current.name,
            repositoryMetaInfo: current.metaInfo,
            errorMessage: current.error,
            errorDescription: current.errorDescription,
            onReloadRepository: null,
            onGetAuthenticationMode: widget.settings.getAuthenticationMode,
            onDelete: repos.deleteRepository);
      }

      if (current is ErrorRepoEntry) {
        // This is a general purpose error state.
        // errorDescription is required, but nullable.
        return ErrorState(
            errorMessage: current.error,
            errorDescription: current.errorDescription,
            onReload: null);
      }

      if (current == null) {
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
      body: WillPopScope(
          child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                Column(children: [Expanded(child: buildMainWidget())]),
                _cubits.repositories.builder((repos) =>
                    RepositoryProgress(repos.currentRepo?.maybeCubit))
              ]),
          onWillPop: _onBackPressed),
      floatingActionButton: _cubits.repositories
          .builder((repos) => _buildFAB(context, repos.currentRepo)),
      bottomSheet: _bottomSheet);

  Future<bool> _onBackPressed() async {
    final currentRepo = _currentRepo;

    if (currentRepo is OpenRepoEntry) {
      final currentFolder = currentRepo.cubit.state.currentFolder;
      if (!currentFolder.isRoot) {
        await currentRepo.cubit.navigateTo(currentFolder.parent);
        return false;
      }

      if (!_cubits.repositories.showList) {
        _cubits.repositories.pushRepoList(true);
        return false;
      }
    }

    int clickCount = exitClickCounter.registerClick();

    if (clickCount <= 1) {
      showSnackBar(context, message: S.current.messageExitOuiSync);
      // Don't pop => don't exit
    } else {
      exitClickCounter.reset();
      // We still don't want to do the pop because that would destroy the
      // current Isolate's execution context and we would lose track of
      // open OuiSync objects (i.e. repositories, files, directories,
      // network handles,...). This is bad because even though the current
      // execution context is deleted, the OuiSync Rust global variables
      // and threads stay alive. If the user at that point tried to open
      // the app again, this widget would try to reinitialize all those
      // variables without previously properly closing them.
      await MoveToBackground.moveTaskToBack();
    }

    return false;
  }

  _buildOuiSyncBar() => OuiSyncBar(
        reposCubit: _cubits.repositories,
        repoPicker: RepositoriesBar(_cubits),
        appSettingsButton: _buildAppSettingsIcon(),
        repoSettingsButton: _buildRepoSettingsIcon(),
      );

  Widget _buildAppSettingsIcon() {
    final button = Fields.actionIcon(const Icon(Icons.settings_outlined),
        onPressed: () async => await _showAppSettings(),
        size: Dimensions.sizeIconSmall);

    return multiBlocBuilder([
      _cubits.upgradeExists,
      _cubits.powerControl,
      _cubits.panicCounter,
      _cubits.backgroundServiceManager
    ], () {
      Color? color = _cubits.mainNotificationBadgeColor();

      if (color != null) {
        return Fields.addBadge(button, color: color);
      } else {
        return button;
      }
    });
  }

  Widget _buildRepoSettingsIcon() =>
      Fields.actionIcon(const Icon(Icons.more_vert_rounded),
          onPressed: () async {
        final cubit = _currentRepo?.maybeCubit;
        if (cubit == null) {
          return;
        }

        await _showRepoSettings(context, repoCubit: cubit);
      }, size: Dimensions.sizeIconSmall);

  Widget _buildFAB(BuildContext context, RepoEntry? current) {
    final icon = const Icon(Icons.add_rounded);

    if (_cubits.repositories.showList &&
        _cubits.repositories.repos.isNotEmpty) {
      return FloatingActionButton(
        heroTag: Constants.heroTagRepoListActions,
        child: icon,
        onPressed: () => _showRepoListActions(context),
      );
    }

    if (current is OpenRepoEntry &&
        current.cubit.state.canWrite &&
        !_cubits.repositories.showList) {
      return FloatingActionButton(
        heroTag: Constants.heroTagMainPageActions,
        child: icon,
        onPressed: () => _showDirectoryActions(context, current),
      );
    }

    return Container();
  }

  Widget _repositoryContentBuilder(OpenRepoEntry repo) =>
      BlocConsumer<RepoCubit, RepoState>(
        bloc: repo.cubit,
        builder: (context, state) => _selectLayoutWidget(),
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            showSnackBar(context, message: state.message);
          }
        },
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
        return LockedRepositoryState(context,
            databaseId: current.databaseId,
            repositoryName: current.name,
            checkForBiometricsCallback: _checkForBiometricsCallback,
            getAuthenticationModeCallback:
                widget.settings.getAuthenticationMode,
            setAuthenticationModeCallback:
                widget.settings.setAuthenticationMode,
            unlockRepositoryCallback: _cubits.repositories.unlockRepository);
      }

      return _contentBrowser(current.cubit);
    }

    return Center(child: Text(S.current.messageErrorUnhandledState));
  }

  Widget _contentBrowser(RepoCubit repo) {
    Widget child;
    Widget navigationBar;
    final folder = repo.state.currentFolder;

    if (folder.content.isEmpty) {
      child = repo.state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : NoContentsState(repository: repo, path: folder.path);
    } else {
      child = _contentsList(repo);
    }

    if (folder.isRoot) {
      navigationBar = const SizedBox.shrink();
    } else {
      navigationBar = FolderNavigationBar(repo);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        navigationBar,
        // TODO: A shadow would be nicer.
        const Divider(height: 3),
        SortContentsBar(
            sortListCubit: _sortListCubit, reposCubit: _cubits.repositories),
        Expanded(child: child),
      ],
    );
  }

  Future<void> _previewFile(
      RepoCubit repo, FileItem item, String authority) async {
    if (io.Platform.isAndroid) {
      await NativeChannels.previewOuiSyncFile(
        authority,
        item.path,
        item.size ?? 0,
        useDefaultApp: true,
      );
    } else if (io.Platform.isWindows) {
      final mountedDirectory = repo.mountedDirectory();
      if (mountedDirectory == null) {
        showSnackBar(context, message: S.current.messageRepositoryNotMounted);
        return;
      }
      var result = await io.Process.run(
          'cmd', ['/c', 'start', '', '$mountedDirectory${item.path}']);
      loggy.app(result.stdout);
    } else {
      // Only the above platforms are supported right now.
      showSnackBar(context, message: S.current.messageFilePreviewNotAvailable);
    }
  }

  Widget _contentsList(RepoCubit currentRepo) => ValueListenableBuilder(
      valueListenable: _bottomPaddingWithBottomSheet,
      builder: (context, value, child) => RefreshIndicator(
          onRefresh: () async => getContent(),
          child: ListView.separated(
              padding: EdgeInsets.only(bottom: value),
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.transparent),
              itemCount: currentRepo.state.currentFolder.content.length,
              itemBuilder: (context, index) {
                final item = currentRepo.state.currentFolder.content[index];
                Function actionByType;

                if (item is FileItem) {
                  actionByType = () async {
                    if (_bottomSheet != null) {
                      await Dialogs.simpleAlertDialog(
                          context: context,
                          title: S.current.titleMovingEntry,
                          message: S.current.messageMovingEntry);
                      return;
                    }

                    await _previewFile(
                        currentRepo, item, Constants.androidAppAuthority);
                  };
                } else if (item is FolderItem) {
                  actionByType = () {
                    if (_bottomSheet != null && _pathEntryToMove == item.path) {
                      return;
                    }

                    currentRepo.navigateTo(item.path);
                  };
                } else {
                  throw UnsupportedError('invalid item type: $item');
                }

                final listItem = ListItem(
                    key: ValueKey(item.name),
                    repository: currentRepo,
                    itemData: item,
                    mainAction: actionByType,
                    verticalDotsAction: () async {
                      if (_bottomSheet != null) {
                        await Dialogs.simpleAlertDialog(
                            context: context,
                            title: S.current.titleMovingEntry,
                            message: S.current.messageMovingEntry);

                        return;
                      }

                      item is FileItem
                          ? await _showFileDetails(
                              repoCubit: currentRepo, data: item)
                          : await _showFolderDetails(
                              repoCubit: currentRepo, data: item);
                    });

                return listItem;
              })));

  Future<dynamic> _showFileDetails({
    required RepoCubit repoCubit,
    required BaseItem data,
  }) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return FileDetail(
              context: context,
              cubit: repoCubit,
              data: data as FileItem,
              onUpdateBottomSheet: updateBottomSheet,
              onMoveEntry: (origin, path, type) =>
                  moveEntry(repoCubit, origin, path, type),
              isActionAvailableValidator: _isEntryActionAvailable,
            );
          });

  Future<dynamic> _showFolderDetails({
    required RepoCubit repoCubit,
    required BaseItem data,
  }) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return FolderDetail(
              context: context,
              cubit: repoCubit,
              data: data as FolderItem,
              onUpdateBottomSheet: updateBottomSheet,
              onMoveEntry: (origin, path, type) =>
                  moveEntry(repoCubit, origin, path, type),
              isActionAvailableValidator: _isEntryActionAvailable,
            );
          });

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

  void moveEntry(
      RepoCubit currentRepo, String origin, String path, EntryType type) async {
    final basename = getBasename(path);
    final destination = buildDestinationPath(
      currentRepo.state.currentFolder.path,
      basename,
    );

    _bottomSheet = null;

    await currentRepo.moveEntry(
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
                title: Fields.constrainedText(S.current.titleAddFile,
                    flex: 0,
                    style: context.theme.appTextStyle.titleMedium,
                    maxLines: 2),
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
    final fileName = getBasename(path);
    final length = (await file.stat()).size;
    final filePath = buildDestinationPath(
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

  Future<String?> _addRepository() async =>
      _addRepoAndNavigate(createRepoDialog(context));

  Future<String?> _importRepository() async =>
      _addRepoAndNavigate(addRepoWithTokenDialog(context));

  Future<String?> _addRepoAndNavigate(Future<String?> repoFunction) async {
    final newRepoName = await repoFunction;

    if (newRepoName == null || newRepoName.isEmpty) {
      return null;
    }

    await _cubits.repositories.setCurrentByName(newRepoName);
    _cubits.repositories.pushRepoList(false);

    return newRepoName;
  }

  Future<String?> createRepoDialog(BuildContext parentContext) async {
    final hasBiometrics = await Dialogs.executeFutureWithLoadingDialog(
            parentContext,
            f: _checkForBiometricsCallback()) ??
        false;
    return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                      title: S.current.titleCreateRepository,
                      body: RepositoryCreation(
                          context: context,
                          cubit: _cubits.repositories,
                          isBiometricsAvailable: hasBiometrics)));
            }))));
  }

  Future<String?> addRepoWithTokenDialog(BuildContext parentContext,
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
              title: Fields.constrainedText(S.current.titleAddRepository,
                  flex: 0,
                  style: context.theme.appTextStyle.titleMedium,
                  maxLines: 2),
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

    final isBiometricsAvailable = await Dialogs.executeFutureWithLoadingDialog(
            parentContext,
            f: _checkForBiometricsCallback()) ??
        false;

    return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                      title: S.current.titleAddRepository,
                      body: RepositoryCreation(
                          context: context,
                          cubit: _cubits.repositories,
                          initialTokenValue: initialTokenValue,
                          isBiometricsAvailable: isBiometricsAvailable)));
            }))));
  }

  void reloadRepository() => _cubits.repositories.init();

  Future<void> _showAppSettings() async {
    final isBiometricsAvailable = await Dialogs.executeFutureWithLoadingDialog(
            context,
            f: _checkForBiometricsCallback()) ??
        false;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _cubits.upgradeExists),
          ],
          child: SettingsPage(_cubits,
              isBiometricsAvailable: isBiometricsAvailable),
        ),
      ),
    );
  }

  Future<void> _showRepoSettings(BuildContext context,
          {required RepoCubit repoCubit}) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return RepositorySettings(
                context: context,
                cubit: repoCubit,
                checkForBiometrics: _checkForBiometricsCallback,
                getAuthenticationMode: widget.settings.getAuthenticationMode,
                renameRepository: _cubits.repositories.renameRepository,
                deleteRepository: _cubits.repositories.deleteRepository);
          });
}
