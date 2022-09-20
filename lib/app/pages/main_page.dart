import 'dart:async';
import 'dart:io' as io;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../utils/click_counter.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'pages.dart';
import '../widgets/repository_progress.dart';

typedef BottomSheetControllerCallback = void Function(
    PersistentBottomSheetController? controller, String entryPath);

class MainPage extends StatefulWidget {
  const MainPage({
    required this.session,
    required this.repositoriesLocation,
    required this.mediaReceiver,
    required this.settings,
  });

  final Session session;
  final String repositoriesLocation;
  final MediaReceiver mediaReceiver;
  final Settings settings;

  @override
  State<StatefulWidget> createState() =>
      _MainPageState(session, repositoriesLocation, settings);
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, OuiSyncAppLogger {
  final ReposCubit _repositories;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _pathEntryToMove = '';
  PersistentBottomSheetController? _persistentBottomSheetController;

  final double defaultBottomPadding = kFloatingActionButtonMargin +
      Dimensions.paddingBottomWithFloatingButtonExtra;
  ValueNotifier<double> _bottomPaddingWithBottomSheet =
      ValueNotifier<double>(0.0);

  final exitClickCounter = ClickCounter(timeoutMs: 3000);
  late final StateMonitorIntValue _panicCounter;

  _MainPageState(
      Session session, String repositoriesLocation, Settings settings)
      : _repositories = ReposCubit(
            session: session,
            repositoriesDir: repositoriesLocation,
            settings: settings) {
    _panicCounter = _repositories
        .rootStateMonitor()
        .child("Session")
        .intValue("panic_counter");
  }

  RepoEntry? get _currentRepo => _repositories.currentRepo;
  UpgradeExistsCubit get _upgradeExistsCubit =>
      BlocProvider.of<UpgradeExistsCubit>(context);

  @override
  void initState() {
    super.initState();

    widget.session.subscribeToNetworkEvents((event) {
      switch (event) {
        case NetworkEvent.peerSetChange:
          {
            BlocProvider.of<PeerSetCubit>(context)
                .onPeerSetChanged(widget.session);
          }
          break;
        case NetworkEvent.protocolVersionMismatch:
          {
            final highest = widget.session.highestSeenProtocolVersion;
            _upgradeExistsCubit.foundVersion(highest);
          }
          break;
      }
    });

    _repositories.init().then((_) {
      initMainPage();
    });

    /// The MediaReceiver uses the MediaReceiverMobile (_mediaIntentSubscription, _textIntentSubscription),
    /// or the MediaReceiverWindows (DropTarget), depending on the platform.
    widget.mediaReceiver.controller.stream.listen((media) {
      if (media is String) {
        loggy.app('mediaReceiver: String');
        addRepoWithTokenDialog(initialTokenValue: media);
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

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_connectivityChange);
  }

  @override
  void dispose() async {
    await _repositories.close();
    _connectivitySubscription?.cancel();

    super.dispose();
  }

  void _connectivityChange(ConnectivityResult result) {
    loggy.app('Connectivity event: ${result.name}');

    BlocProvider.of<ConnectivityCubit>(context).connectivityEvent(result);
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
      (context) {
        return SaveSharedMedia(
            sharedMedia: payload,
            onBottomSheetOpen: retrieveBottomSheetController,
            onSaveFile: saveMedia);
      },
    );
  }

  getContent() {
    final current = _currentRepo;
    if (current is OpenRepoEntry) {
      current.cubit.getContent();
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

      if (current == null) {
        return NoRepositoriesState(
            onNewRepositoryPressed: createRepoDialog,
            onAddRepositoryPressed: addRepoWithTokenDialog);
      }

      return Center(child: Text("Error: unhandled state"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildOuiSyncBar(),
      body: WillPopScope(
          child: Column(children: <Widget>[
            _repositories.builder(
                (repos) => RepositoryProgress(repos.currentRepo?.maybeCubit)),
            Expanded(child: buildMainWidget()),
          ]),
          onWillPop: _onBackPressed),
      floatingActionButton: _repositories
          .builder((repos) => _buildFAB(context, repos.currentRepo)),
    );
  }

  Future<bool> _onBackPressed() async {
    final currentRepo = _currentRepo;

    if (currentRepo is! OpenRepoEntry) {
      return false;
    }

    final currentFolder = currentRepo.cubit.currentFolder;

    if (currentFolder.isRoot()) {
      int clickCount = exitClickCounter.registerClick();

      if (clickCount <= 1) {
        showSnackBar(context, content: Text(S.current.messageExitOuiSync));

        // Don't pop => don't exit
        return false;
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
        MoveToBackground.moveTaskToBack();
        return false;
      }
    }

    currentRepo.cubit.navigateTo(currentFolder.parent);

    return false;
  }

  _buildOuiSyncBar() => OuiSyncBar(
        repoList: _buildRepositoriesBar(),
        settingsButton: _buildSettingsIcon(),
      );

  RepositoriesBar _buildRepositoriesBar() {
    return RepositoriesBar(
      reposCubit: _repositories,
      shareRepositoryOnTap: _showShareRepository,
    );
  }

  Widget _buildSettingsIcon() {
    final button = Fields.actionIcon(const Icon(Icons.settings_outlined),
        onPressed: showSettings,
        size: Dimensions.sizeIconSmall,
        color: Theme.of(context).colorScheme.surface);
    return BlocBuilder<UpgradeExistsCubit, bool>(
        builder: (context, updateExists) {
      return _panicCounter.builder((context, panicCount) {
        return _repositories.powerControl.builder((powerControl) {
          Color? color;

          if (updateExists || ((panicCount ?? 0) > 0)) {
            color = Constants.errorColor;
          } else if (!powerControl.isNetworkEnabled()) {
            color = Constants.warningColor;
          }

          if (color != null) {
            return Fields.addBadge(button, color: color);
          } else {
            return button;
          }
        });
      });
    });
  }

  StatelessWidget _buildFAB(BuildContext context, RepoEntry? current) {
    if (current is! OpenRepoEntry) {
      return Container();
    }

    if (!current.cubit.canWrite) {
      return Container();
    }

    return FloatingActionButton(
      heroTag: Constants.heroTagMainPageActions,
      child: const Icon(Icons.add_rounded),
      onPressed: () => _showDirectoryActions(context, current),
    );
  }

  _repositoryContentBuilder(OpenRepoEntry repo) => repo.cubit.consumer((repo) {
        return _selectLayoutWidget();
      }, (repo) {
        while (repo.messages.isNotEmpty) {
          showSnackBar(context, content: Text(repo.messages.removeAt(0)));
        }
      });

  _selectLayoutWidget() {
    final current = _currentRepo;

    if (current == null || current is LoadingRepoEntry) {
      return NoRepositoriesState(
          onNewRepositoryPressed: createRepoDialog,
          onAddRepositoryPressed: addRepoWithTokenDialog);
    }

    if (current is OpenRepoEntry) {
      if (!current.cubit.canRead) {
        return LockedRepositoryState(
          repositoryName: current.name,
          onUnlockPressed: unlockRepositoryDialog,
        );
      }

      return _contentBrowser(current.cubit);
    }

    return Center(child: Text("Error: Unhandled state"));
  }

  _contentBrowser(RepoCubit repo) {
    Widget child;
    Widget navigationBar;
    final folder = repo.currentFolder;

    if (folder.content.isEmpty) {
      child = NoContentsState(repository: folder.repo, path: folder.path);
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
                          content:
                              Text(S.current.messageFilePreviewNotAvailable));
                      return;
                    }

                    await NativeChannels.previewOuiSyncFile(
                        item.path, item.size,
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

  Future<dynamic> _showShareRepository(RepoCubit repository) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            final accessModes = repository.accessMode == AccessMode.write
                ? [AccessMode.blind, AccessMode.read, AccessMode.write]
                : repository.accessMode == AccessMode.read
                    ? [AccessMode.blind, AccessMode.read]
                    : [AccessMode.blind];

            return ShareRepository(
              repository: repository,
              availableAccessModes: accessModes,
            );
          });

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

    currentRepo.moveEntry(
      source: path,
      destination: destination,
    );
  }

  Future<void> saveMedia(String sourceFilePath) async {
    final currentRepo = _currentRepo;

    if (currentRepo is! OpenRepoEntry) {
      showSnackBar(
        context,
        content: Text(
          S.current.messageNoRepo,
        ),
      );
      return;
    }

    String? accessModeMessage = !currentRepo.cubit.canRead
        ? S.current.messageAddingFileToLockedRepository
        : !currentRepo.cubit.canWrite
            ? S.current.messageAddingFileToReadRepository
            : null;

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
                ),
              ],
            );
          });

      return;
    }

    loggy.app('Media path: $sourceFilePath');
    await saveFileToOuiSync(currentRepo.cubit, sourceFilePath);
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

  void createRepoDialog() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.titleCreateRepository,
            body: RepositoryCreation(
              context: context,
              cubit: _repositories,
              formKey: formKey,
            ),
          );
        });
  }

  void addRepoWithTokenDialog({String? initialTokenValue}) async {
    initialTokenValue ??= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return AddRepositoryPage(reposCubit: _repositories);
      }),
    );

    if (initialTokenValue == null) return;

    final tokenValidationError =
        _repositories.validateTokenLink(initialTokenValue);
    if (tokenValidationError != null) {
      showDialog(
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

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.titleAddRepository,
            body: AddRepositoryWithToken(
              context: context,
              cubit: _repositories,
              formKey: formKey,
              initialTokenValue: initialTokenValue,
            ),
          );
        });
  }

  void unlockRepositoryDialog(String repositoryName) async {
    await Dialogs.unlockRepositoryDialog(
      context,
      _repositories,
      repositoryName,
    );
  }

  void showSettings() {
    final connectivityCubit = BlocProvider.of<ConnectivityCubit>(context);
    final peerSetCubit = BlocProvider.of<PeerSetCubit>(context);
    final reposCubit = _repositories;
    final upgradeExistsCubit = _upgradeExistsCubit;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: connectivityCubit),
            BlocProvider.value(value: peerSetCubit),
            BlocProvider.value(value: upgradeExistsCubit),
          ],
          child: SettingsPage(
            reposCubit: reposCubit,
            onShareRepository: _showShareRepository,
            panicCounter: _panicCounter,
          ),
        );
      }),
    );
  }
}
