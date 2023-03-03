import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/state_monitor.dart' as oui;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../flavors.dart';
import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../utils/click_counter.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/repository_progress.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef BottomSheetControllerCallback = void Function(
    PersistentBottomSheetController? controller, String entryPath);

typedef CheckForBiometricsFunction = Future<bool?> Function();

typedef SecureRepoWithBiometricsFunction = Function(
    {required String repositoryName, required bool value});

class MainPage extends StatefulWidget {
  const MainPage({
    required this.session,
    required this.mediaReceiver,
    required this.settings,
  });

  final Session session;
  final MediaReceiver mediaReceiver;
  final Settings settings;

  @override
  State<StatefulWidget> createState() => _MainPageState(session, settings);
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, OuiSyncAppLogger {
  final ReposCubit _repositories;
  final PowerControl _powerControl;
  final Future<NatDetection> _natDetection = NatDetection.init();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _pathEntryToMove = '';
  PersistentBottomSheetController? _persistentBottomSheetController;

  final double defaultBottomPadding = kFloatingActionButtonMargin +
      Dimensions.paddingBottomWithFloatingButtonExtra;
  ValueNotifier<double> _bottomPaddingWithBottomSheet =
      ValueNotifier<double>(0.0);

  final exitClickCounter = ClickCounter(timeoutMs: 3000);
  final StateMonitorIntCubit _panicCounter;

  _MainPageState._(this._repositories, this._powerControl, this._panicCounter);

  factory _MainPageState(Session session, Settings settings) {
    final repositories = ReposCubit(
      session: session,
      settings: settings,
    );
    final powerControl = PowerControl(session, settings);
    final panicCounter = StateMonitorIntCubit(
        repositories.rootStateMonitor
            .child(oui.MonitorId.expectUnique("Session")),
        "panic_counter");

    return _MainPageState._(repositories, powerControl, panicCounter);
  }

  RepoEntry? get _currentRepo => _repositories.currentRepo;
  UpgradeExistsCubit get _upgradeExistsCubit =>
      BlocProvider.of<UpgradeExistsCubit>(context);

  @override
  void initState() {
    super.initState();

    widget.session.networkEvents.listen((event) async {
      switch (event) {
        case NetworkEvent.peerSetChange:
          break;
        case NetworkEvent.protocolVersionMismatch:
          {
            final highest = await widget.session.highestSeenProtocolVersion;
            await _upgradeExistsCubit.foundVersion(highest);
          }
          break;
      }
    });

    unawaited(_repositories.init().then((_) {
      initMainPage();
    }));

    unawaited(_powerControl.init());

    /// The MediaReceiver uses the MediaReceiverMobile (_mediaIntentSubscription, _textIntentSubscription),
    /// or the MediaReceiverWindows (DropTarget), depending on the platform.
    widget.mediaReceiver.controller.stream.listen((media) {
      if (media is String) {
        loggy.app('mediaReceiver: String');
        unawaited(addRepoWithTokenDialog(initialTokenValue: media));
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
    await (await _natDetection).close();
    await _repositories.close();
    super.dispose();
  }

  Future<bool?> _checkForBiometricsCallback() async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) return null;

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

    _scaffoldKey.currentState?.showBottomSheet(
      enableDrag: false,
      (context) {
        return SaveSharedMedia(
            sharedMedia: payload,
            onBottomSheetOpen: retrieveBottomSheetController,
            onSaveFile: saveMedia,
            validationFunction: canSaveMedia);
      },
    );
  }

  getContent() {
    final current = _currentRepo;
    if (current is OpenRepoEntry) {
      current.cubit.refresh();
    }
  }

  Widget buildMainWidget() {
    return _repositories.builder((repos) {
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
            errorMessage: current.error,
            errorDescription: current.errorDescription,
            onReloadRepository: null,
            onDeleteRepository: () => deleteRepository(current.metaInfo));
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
                onNewRepositoryPressed: createRepoDialog,
                onAddRepositoryPressed: addRepoWithTokenDialog);
      }

      return Center(child: Text(S.current.messageErrorUnhandledState));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildOuiSyncBar(),
      body: WillPopScope(
          child: Column(
            children: <Widget>[
              _repositories.builder(
                  (repos) => RepositoryProgress(repos.currentRepo?.maybeCubit)),
              Expanded(child: buildMainWidget()),
            ],
          ),
          onWillPop: _onBackPressed),
      floatingActionButton: _repositories
          .builder((repos) => _buildFAB(context, repos.currentRepo)),
    );
  }

  Future<bool> _onBackPressed() async {
    final currentRepo = _currentRepo;

    if (currentRepo is OpenRepoEntry) {
      final currentFolder = currentRepo.cubit.currentFolder;
      if (!currentFolder.isRoot()) {
        await currentRepo.cubit.navigateTo(currentFolder.parent);
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
        repoList: _buildRepositoriesBar(),
        settingsButton: _buildSettingsIcon(),
      );

  RepositoriesBar _buildRepositoriesBar() => RepositoriesBar(
      reposCubit: _repositories,
      checkForBiometricsCallback: _checkForBiometricsCallback,
      shareRepositoryOnTap: _showShareRepository,
      unlockRepositoryOnTap: _unlockRepositoryCallback);

  Widget _buildSettingsIcon() {
    final button = Fields.actionIcon(const Icon(Icons.settings_outlined),
        onPressed: () async => await showSettings(),
        size: Dimensions.sizeIconSmall,
        color: Theme.of(context).colorScheme.surface);

    return BlocBuilder<UpgradeExistsCubit, bool>(
      builder: (context, updateExists) =>
          BlocBuilder<PowerControl, PowerControlState>(
        bloc: _powerControl,
        builder: (context, powerControlState) =>
            BlocBuilder<StateMonitorIntCubit, int?>(
                bloc: _panicCounter,
                builder: (context, panicCount) {
                  Color? color;

                  if (updateExists || ((panicCount ?? 0) > 0)) {
                    color = Constants.errorColor;
                  } else if (!(powerControlState.isNetworkEnabled ?? true)) {
                    color = Constants.warningColor;
                  }

                  if (color != null) {
                    return Fields.addBadge(button, color: color);
                  } else {
                    return button;
                  }
                }),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, RepoEntry? current) {
    if (current is! OpenRepoEntry) {
      return Container();
    }

    if (!current.cubit.state.canWrite) {
      return Container();
    }

    return FloatingActionButton(
      heroTag: Constants.heroTagMainPageActions,
      child: const Icon(Icons.add_rounded),
      onPressed: () => _showDirectoryActions(context, current),
    );
  }

  _repositoryContentBuilder(OpenRepoEntry repo) =>
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
          onNewRepositoryPressed: createRepoDialog,
          onAddRepositoryPressed: addRepoWithTokenDialog);
    }

    if (current is OpenRepoEntry) {
      if (!current.cubit.state.canRead) {
        return LockedRepositoryState(
            databaseId: current.databaseId,
            repositoryName: current.name,
            unlockRepositoryCallback: _unlockRepositoryCallback);
      }

      return _contentBrowser(current.cubit);
    }

    return Center(child: Text(S.current.messageErrorUnhandledState));
  }

  _contentBrowser(RepoCubit repo) {
    Widget child;
    Widget navigationBar;
    final folder = repo.currentFolder;

    if (folder.content.isEmpty) {
      child = repo.state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : NoContentsState(repository: folder.repo, path: folder.path);
    } else {
      child = _contentsList(repo);
    }

    if (folder.isRoot()) {
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
        Expanded(child: child),
      ],
    );
  }

  _contentsList(RepoCubit currentRepo) => ValueListenableBuilder(
      valueListenable: _bottomPaddingWithBottomSheet,
      builder: (context, value, child) => RefreshIndicator(
          onRefresh: () async => getContent(),
          child: ListView.separated(
              padding: EdgeInsets.only(bottom: value),
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.transparent),
              itemCount: currentRepo.currentFolder.content.length,
              itemBuilder: (context, index) {
                final item = currentRepo.currentFolder.content[index];
                Function actionByType;

                if (item is FileItem) {
                  actionByType = () async {
                    if (_persistentBottomSheetController != null) {
                      await Dialogs.simpleAlertDialog(
                          context: context,
                          title: S.current.titleMovingEntry,
                          message: S.current.messageMovingEntry);
                      return;
                    }

                    /// For now, only Android can preview files.
                    if (!io.Platform.isAndroid) {
                      showSnackBar(context,
                          message: S.current.messageFilePreviewNotAvailable);
                      return;
                    }

                    await NativeChannels.previewOuiSyncFile(
                        F.authority, item.path, item.size,
                        useDefaultApp: true);
                  };
                } else if (item is FolderItem) {
                  actionByType = () {
                    if (_persistentBottomSheetController != null &&
                        _pathEntryToMove == item.path) {
                      return;
                    }

                    currentRepo.navigateTo(item.path);
                  };
                } else {
                  throw UnsupportedError('invalid item type: $item');
                }

                final listItem = ListItem(
                  repository: currentRepo,
                  itemData: item,
                  mainAction: actionByType,
                  folderDotsAction: () async {
                    if (_persistentBottomSheetController != null) {
                      await Dialogs.simpleAlertDialog(
                          context: context,
                          title: S.current.titleMovingEntry,
                          message: S.current.messageMovingEntry);

                      return;
                    }

                    item is FileItem
                        ? await _showFileDetails(
                            repoCubit: currentRepo,
                            scaffoldKey: _scaffoldKey,
                            data: item)
                        : await _showFolderDetails(
                            repoCubit: currentRepo,
                            scaffoldKey: _scaffoldKey,
                            data: item);
                  },
                );

                return listItem;
              })));

  // This is an empiric value that works for high resolutions, but
  // not quite good for lower resolutions (still does, but adds extra
  // space at the top, which doesn't look good).

  // TODO: Find a better solution
  Future<dynamic> _showShareRepository(RepoCubit repository) {
    final accessMode = repository.state.accessMode;
    final accessModes = accessMode == AccessMode.write
        ? [AccessMode.blind, AccessMode.read, AccessMode.write]
        : accessMode == AccessMode.read
            ? [AccessMode.blind, AccessMode.read]
            : [AccessMode.blind];

    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: Dimensions.borderBottomSheetTop,
      constraints: BoxConstraints(maxHeight: 390.0),
      builder: (_) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShareRepository(
            repository: repository,
            availableAccessModes: accessModes,
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showFileDetails({
    required RepoCubit repoCubit,
    required GlobalKey<ScaffoldState> scaffoldKey,
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
              scaffoldKey: scaffoldKey,
              onBottomSheetOpen: retrieveBottomSheetController,
              onMoveEntry: (
                origin,
                path,
                type,
              ) =>
                  moveEntry(
                repoCubit,
                origin,
                path,
                type,
              ),
              isActionAvailableValidator: _isEntryActionAvailable,
            );
          });

  Future<dynamic> _showFolderDetails({
    required RepoCubit repoCubit,
    required GlobalKey<ScaffoldState> scaffoldKey,
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
              scaffoldKey: scaffoldKey,
              onBottomSheetOpen: retrieveBottomSheetController,
              onMoveEntry: (
                origin,
                path,
                type,
              ) =>
                  moveEntry(
                repoCubit,
                origin,
                path,
                type,
              ),
              isActionAvailableValidator: _isEntryActionAvailable,
            );
          });

  void retrieveBottomSheetController(
    PersistentBottomSheetController? controller,
    String entryPath,
  ) {
    _persistentBottomSheetController = controller;
    _pathEntryToMove = entryPath;
    _bottomPaddingWithBottomSheet.value = defaultBottomPadding;
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
    RepoCubit currentRepo,
    origin,
    path,
    type,
  ) async {
    final basename = getBasename(path);
    final destination = buildDestinationPath(
      currentRepo.currentFolder.path,
      basename,
    );

    _persistentBottomSheetController!.close();
    _persistentBottomSheetController = null;

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
              title: Text(S.current.titleAddFile),
              content: SingleChildScrollView(
                child: ListBody(children: [Text(accessModeMessage)]),
              ),
              actions: [
                TextButton(
                  child: Text(S.current.actionCloseCapital),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
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
      currentRepo.currentFolder.path,
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

  Future<void> createRepoDialog() async {
    final hasBiometrics = await Dialogs.executeFutureWithLoadingDialog(context,
            f: _checkForBiometricsCallback()) ??
        false;
    await showDialog(
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
                          cubit: _repositories,
                          isBiometricsAvailable: hasBiometrics)));
            }))));
  }

  Future<void> addRepoWithTokenDialog({String? initialTokenValue}) async {
    initialTokenValue ??= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return AddRepositoryPage(reposCubit: _repositories);
      }),
    );

    if (initialTokenValue == null) return;

    final tokenValidationError =
        await _repositories.validateTokenLink(initialTokenValue);
    if (tokenValidationError != null) {
      await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.current.titleAddRepository),
              content: Text(tokenValidationError),
              actions: <Widget>[
                TextButton(
                  child: Text(S.current.actionOK),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });

      return;
    }

    final isBiometricsAvailable = await Dialogs.executeFutureWithLoadingDialog(
            context,
            f: _checkForBiometricsCallback()) ??
        false;
    await showDialog(
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
                          cubit: _repositories,
                          initialTokenValue: initialTokenValue,
                          isBiometricsAvailable: isBiometricsAvailable)));
            }))));
  }

  Future<void> _unlockRepositoryCallback(
      {required String databaseId, required String repositoryName}) async {
    final databaseId = widget.settings.getDatabaseId(repositoryName);

    final requestPassword =
        widget.settings.getRequestPassword(repositoryName) ?? false;

    if (requestPassword) {
      // Unlock manually
      await _getRepositoryPasswordDialog(
          databaseId: databaseId, repositoryName: repositoryName);

      return;
    }

    final authenticateWithBiometrics =
        widget.settings.getAuthenticationRequired(repositoryName) ?? false;

    SecureStorageResult secureStorageResult =
        await Dialogs.executeFutureWithLoadingDialog<SecureStorageResult>(
            context,
            f: SecureStorage.getRepositoryPassword(
                databaseId: databaseId,
                authenticationRequired: authenticateWithBiometrics));

    if (secureStorageResult.exception != null) {
      loggy.app(secureStorageResult.exception);
      return;
    }

    final password = secureStorageResult.value ?? '';
    if (password.isEmpty) {
      /// TODO: Show a message when unlocking using biometrics fails (?)
      return;
    }

    // Unlock using biometrics
    await Dialogs.executeFutureWithLoadingDialog(context,
        f: _unlockRepository(
            repositoryName: repositoryName, password: password));
  }

  Future<void> _getRepositoryPasswordDialog(
      {required String databaseId, required String repositoryName}) async {
    final hasBiometrics = await _checkForBiometricsCallback() ?? false;

    final unlockRepoResponse = await showDialog<UnlockRepositoryResult?>(
        context: context,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                    title: S.current.messageUnlockRepository,
                    body: UnlockRepository(
                        context: context,
                        databaseId: databaseId,
                        repositoryName: repositoryName,
                        isBiometricsAvailable: hasBiometrics,
                        isPasswordValidation: false,
                        unlockRepositoryCallback: _unlockRepository,
                        onSecureRepositoryWithBiometricsCallback:
                            _secureRepositoryWithBiometrics),
                  ));
            }))));

    if (unlockRepoResponse == null) return;

    showSnackBar(context, message: unlockRepoResponse.message);
  }

  Future<AccessMode?> _unlockRepository(
          {required String repositoryName, required String password}) async =>
      _repositories.unlockRepository(repositoryName, password: password);

  void _secureRepositoryWithBiometrics(
      {required String repositoryName, required bool value}) {
    widget.settings.setAuthenticationRequired(repositoryName, value);
    widget.settings.setRequestPassword(repositoryName, !value);
  }

  void deleteRepository(RepoMetaInfo repoInfo) =>
      _repositories.deleteRepository(repoInfo);

  void reloadRepository() => _repositories.init();

  Future<void> showSettings() async {
    final reposCubit = _repositories;
    final upgradeExistsCubit = _upgradeExistsCubit;

    final isBiometricsAvailable = await Dialogs.executeFutureWithLoadingDialog(
            context,
            f: _checkForBiometricsCallback()) ??
        false;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: upgradeExistsCubit),
          ],
          child: SettingsPage(
            settings: widget.settings,
            reposCubit: reposCubit,
            isBiometricsAvailable: isBiometricsAvailable,
            powerControl: _powerControl,
            onShareRepository: _showShareRepository,
            panicCounter: _panicCounter,
            natDetection: _natDetection,
          ),
        ),
      ),
    );
  }
}
