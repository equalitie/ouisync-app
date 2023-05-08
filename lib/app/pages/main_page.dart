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
import '../mixins/mixins.dart';
import '../models/models.dart';
import '../utils/click_counter.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/repository_progress.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef BottomSheetCallback = void Function(Widget? widget, String entryPath);

typedef MoveEntryCallback = void Function(
    String origin, String path, EntryType type);

typedef CheckForBiometricsFunction = Future<bool?> Function();

class MainPage extends StatefulWidget {
  const MainPage(
      {required this.session,
      required this.mediaReceiver,
      required this.settings});

  final Session session;
  final MediaReceiver mediaReceiver;
  final Settings settings;

  @override
  State<StatefulWidget> createState() => _MainPageState(session, settings);
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, RepositoryActionsMixin, OuiSyncAppLogger {
  final ReposCubit _repositories;
  final PowerControl _powerControl;
  final Future<NatDetection> _natDetection = NatDetection.init();

  String _pathEntryToMove = '';
  Widget? _bottomSheet;

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
    await (await _natDetection).close();
    await _repositories.close();
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
    return _repositories.builder((repos) {
      if (repos.showList) {
        return RepoListState(
            reposCubit: repos,
            bottomPaddingWithBottomSheet: _bottomPaddingWithBottomSheet,
            onCheckForBiometrics: _checkForBiometricsCallback,
            onNewRepositoryPressed: _addRepository,
            onImportRepositoryPressed: _importRepository,
            onGetAuthenticationMode: widget.settings.getAuthenticationMode,
            onTryGetSecurePassword: _tryGetSecurePassword);
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildOuiSyncBar(),
        body: WillPopScope(
            child: Column(
              children: <Widget>[
                _repositories.builder((repos) =>
                    RepositoryProgress(repos.currentRepo?.maybeCubit)),
                Expanded(child: buildMainWidget()),
              ],
            ),
            onWillPop: _onBackPressed),
        floatingActionButton: _repositories
            .builder((repos) => _buildFAB(context, repos.currentRepo)),
        bottomSheet: _bottomSheet);
  }

  Future<bool> _onBackPressed() async {
    final currentRepo = _currentRepo;

    if (currentRepo is OpenRepoEntry) {
      final currentFolder = currentRepo.cubit.state.currentFolder;
      if (!currentFolder.isRoot) {
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
        repoPicker: _buildRepositoriesBar(),
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
    final icon = const Icon(Icons.add_rounded);

    if (_repositories.showList && _repositories.repos.isNotEmpty) {
      return FloatingActionButton(
        heroTag: Constants.heroTagRepoListActions,
        child: icon,
        onPressed: () => _showRepoListActions(context),
      );
    }

    if (current is OpenRepoEntry &&
        current.cubit.state.canWrite &&
        !_repositories.showList) {
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
        return LockedRepositoryState(
            databaseId: current.databaseId,
            repositoryName: current.name,
            unlockRepositoryCallback: _unlockRepositoryCallback);
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
        Expanded(child: child),
      ],
    );
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
                    if (_bottomSheet != null && _pathEntryToMove == item.path) {
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
                reposCubit: _repositories,
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

    await _repositories.setCurrentByName(newRepoName);
    _repositories.pushRepoList(false);

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
                          cubit: _repositories,
                          isBiometricsAvailable: hasBiometrics)));
            }))));
  }

  Future<String?> addRepoWithTokenDialog(BuildContext parentContext,
      {String? initialTokenValue}) async {
    initialTokenValue ??= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return AddRepositoryPage(reposCubit: _repositories);
      }),
    );

    if (initialTokenValue == null) return null;

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
                          cubit: _repositories,
                          initialTokenValue: initialTokenValue,
                          isBiometricsAvailable: isBiometricsAvailable)));
            }))));
  }

  Future<void> _unlockRepositoryCallback(
      {required String databaseId, required String repositoryName}) async {
    final isBiometricsAvailable = await _checkForBiometricsCallback() ?? false;

    String? authenticationMode =
        widget.settings.getAuthenticationMode(repositoryName);

    /// Runs once per repository (if needed): before adding to the app the
    /// possibility to create a repository without a local password, any entry
    /// to the secure storage (biometric_storage) required biometric validation
    /// (authenticationRequired=true, by default).
    ///
    /// With the option of not having a local password, we now save the password,
    /// for both this option and biometrics, in the secure storage, and only in
    /// the latest case we require biometric validation, using the Dart package
    /// local_auth, instead of the biometric_storage built in validation.
    ///
    /// Any repo that doesn't have this setting is considered from a version
    /// before this implementation, and we need to determine the value for this
    /// setting right after the update, on the first unlocking.
    ///
    /// Trying to get the password from the secure storage using the built in
    /// biometric validation can tell us this:
    ///
    /// IF securePassword != null
    ///   The repo password exist and it was secured using biometrics. (version1)
    /// ELSE
    ///   The repo password doesn't exist and it was manually input by the user.
    ///
    /// (If the password is empty, something wrong happened in the previous
    /// version of the app saving its value and it is considered non existent
    /// in the secure storage, this is, not secured with biometrics).
    if (authenticationMode == null ||
        authenticationMode == Constants.authModeVersion1) {
      final securedPassword = await _getPasswordAndUnlock(
          context, databaseId, repositoryName, Constants.authModeVersion1);

      if (securedPassword == null) {
        return;
      }

      /// IF password.isEmpty => The password doesn't exist in the secure
      /// storage.
      authenticationMode = securedPassword.isEmpty
          ? Constants.authModeManual
          : Constants.authModeVersion1;

      await widget.settings
          .setAuthenticationMode(repositoryName, authenticationMode);

      if (authenticationMode == Constants.authModeVersion1) {
        final upgraded =
            await _upgradeBiometricEntryToVersion2(databaseId, securedPassword);

        if (upgraded == null) {
          loggy.app(
              'Upgrading repo $repositoryName to AUTH_MODE version2 failed.');

          return;
        }

        if (upgraded == false) {
          loggy.app(
              'Removing the old entry (version1) for $repositoryName in the '
              'secure storage failed, but the creating the new entry (version2) '
              'was successful.');
        }

        await widget.settings
            .setAuthenticationMode(repositoryName, Constants.authModeVersion2);

        return;
      }
    }

    if (authenticationMode == Constants.authModeManual) {
      final unlockResult = await _getManualPasswordAndUnlock(
          databaseId: databaseId,
          repositoryName: repositoryName,
          isBiometricsAvailable: isBiometricsAvailable);

      if (unlockResult == null) return;

      showSnackBar(context, message: unlockResult.message);

      return;
    }

    await _getPasswordAndUnlock(
        context, databaseId, repositoryName, authenticationMode);
  }

  Future<String?> _getPasswordAndUnlock(BuildContext context, String databaseId,
      String repositoryName, String authenticationMode) async {
    if (authenticationMode == Constants.authModeManual) {
      return null;
    }

    final securePassword = await _tryGetSecurePassword(
        context: context,
        databaseId: databaseId,
        authenticationMode: authenticationMode);

    if (securePassword == null) {
      /// There was an exception getting the value from the secure storage.
      return null;
    }

    if (securePassword.isEmpty) {
      return '';
    }

    await _unlockRepository(repositoryName, securePassword);
    return securePassword;
  }

  Future<String?> _tryGetSecurePassword(
      {required BuildContext context,
      required String databaseId,
      required String authenticationMode}) async {
    if (authenticationMode == Constants.authModeManual) {
      return null;
    }

    if (authenticationMode == Constants.authModeVersion2) {
      final auth = LocalAuthentication();

      final authorized = await auth.authenticate(
          localizedReason: S.current.messageAccessingSecureStorage);

      if (authorized == false) {
        return null;
      }
    }

    return _readSecureStorage(databaseId, authenticationMode);
  }

  Future<String?> _readSecureStorage(String databaseId, String authMode) async {
    final secureStorageResult = await SecureStorage.getRepositoryPassword(
        databaseId: databaseId, authMode: authMode);

    if (secureStorageResult.exception != null) {
      loggy.app(secureStorageResult.exception);

      return null;
    }

    return secureStorageResult.value ?? '';
  }

  Future<bool?> _upgradeBiometricEntryToVersion2(
      String databaseId, String password) async {
    final addTempResult = await SecureStorage.addRepositoryPassword(
        databaseId: databaseId,
        password: password,
        authMode: Constants.authModeVersion2);

    if (addTempResult.exception != null) {
      loggy.app(addTempResult.exception);

      return null;
    }

    final deleteOldResult = await SecureStorage.deleteRepositoryPassword(
        databaseId: databaseId,
        authMode: Constants.authModeVersion1,
        authenticationRequired: false);

    if (deleteOldResult.exception != null) {
      loggy.app(deleteOldResult.exception);

      return false;
    }

    return true;
  }

  Future<void> _unlockRepository(String repositoryName, String password) async {
    final accessMode = await _repositories.unlockRepository(repositoryName,
        password: password);

    final message = (accessMode != null && accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.name)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(context, message: message);
  }

  Future<UnlockRepositoryResult?> _getManualPasswordAndUnlock(
          {required String databaseId,
          required String repositoryName,
          required bool isBiometricsAvailable}) async =>
      showDialog<UnlockRepositoryResult?>(
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
                          isBiometricsAvailable: isBiometricsAvailable,
                          isPasswordValidation: false,
                          unlockRepositoryCallback:
                              _repositories.unlockRepository,
                          setAuthenticationModeCallback:
                              widget.settings.setAuthenticationMode),
                    ));
              }))));

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
            onTryGetSecurePassword: _tryGetSecurePassword,
            panicCounter: _panicCounter,
            natDetection: _natDetection,
          ),
        ),
      ),
    );
  }
}
