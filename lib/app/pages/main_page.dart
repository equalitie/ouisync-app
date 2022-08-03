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
import '../models/folder_state.dart';
import '../models/models.dart';
import '../utils/click_counter.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'pages.dart';
import '../widgets/repository_progress.dart';

typedef RepositoryCallback = Future<void> Function(RepoState? repository);
typedef BottomSheetControllerCallback = void Function(PersistentBottomSheetController? controller, String entryPath);
typedef MoveEntryCallback = void Function(String origin, String path, EntryType type);
typedef SaveFileCallback = Future<void> Function(String sourceFilePath);

class MainPage extends StatefulWidget {
  const MainPage({
    required this.session,
    required this.appStorageLocation,
    required this.repositoriesLocation,
    required this.defaultRepositoryName,
    required this.mediaReceiver,
  });

  final Session session;
  final String appStorageLocation;
  final String repositoriesLocation;
  final String defaultRepositoryName;
  final MediaReceiver mediaReceiver;

  @override
  State<StatefulWidget> createState() => _MainPageState(
    session,
    appStorageLocation,
    repositoriesLocation);
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, OuiSyncAppLogger
{
    ReposCubit _repositories;

    StreamSubscription<ConnectivityResult>? _connectivitySubscription;

    final _scaffoldKey = GlobalKey<ScaffoldState>();

    String _pathEntryToMove = '';
    PersistentBottomSheetController? _persistentBottomSheetController;

    Widget _mainWidget = const LoadingMainPageState();

    final double defaultBottomPadding = kFloatingActionButtonMargin + Dimensions.paddingBottomWithFloatingButtonExtra;
    ValueNotifier<double> _bottomPaddingWithBottomSheet = ValueNotifier<double>(0.0);

    final exitClickCounter = ClickCounter(timeoutMs: 3000);

    _MainPageState(Session session, String appStorageLocation, String repositoriesLocation) :
      _repositories = ReposCubit(session: session, appDir: appStorageLocation, repositoriesDir: repositoriesLocation);

    RepoCubit? get _currentRepo => _repositories.current.state;
    ReposState get _reposState => _repositories.state;
    RepositoryProgressCubit get _repoProgressCubit => BlocProvider.of<RepositoryProgressCubit>(context);
    UpgradeExistsCubit get _upgradeExistsCubit => BlocProvider.of<UpgradeExistsCubit>(context);

    @override
    void initState() {
      super.initState();

      widget.session.subscribeToNetworkEvents((event) {
        switch (event) {
          case NetworkEvent.peerSetChange: {
            BlocProvider.of<PeerSetCubit>(context).onPeerSetChanged(widget.session);
          }
          break;
          case NetworkEvent.protocolVersionMismatch: {
            final highest = widget.session.highest_seen_protocol_version;
            _upgradeExistsCubit.foundVersion(highest);
          }
          break;
        }
      });

      _reposState.setSubscriptionCallback((repo) {
        _repoProgressCubit.updateProgress(repo);
        getContent();
      });

      _initRepositories().then((_) { initMainPage(); });

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

      _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_connectivityChange);
  }

    @override
    void dispose() async {
      await _repositories.close();
      _connectivitySubscription?.cancel();

      super.dispose();
    }

    Future<void> _initRepositories() async {
      final initRepos = RepositoryHelper
      .localRepositoriesFiles(
        widget.repositoriesLocation,
        justNames: true
      ).map((repoName) async {
        final setCurrent = repoName == widget.defaultRepositoryName;
        await _repositories.openRepository(repoName, setCurrent: setCurrent);
      }).toList();

      await Future.wait(initRepos);
    }

    void _connectivityChange(ConnectivityResult result) {
      loggy.app('Connectivity event: ${result.name}');

      BlocProvider
      .of<ConnectivityCubit>(context)
      .connectivityEvent(result);
    }

    void initMainPage() async {
      _bottomPaddingWithBottomSheet = ValueNotifier<double>(defaultBottomPadding);
    }

    void handleShareIntentPayload(List<SharedMediaFile> payload) {
      if (payload.isEmpty) {
        return;
      }

      _bottomPaddingWithBottomSheet.value = defaultBottomPadding + Dimensions.paddingBottomWithBottomSheetExtra;

      _scaffoldKey.currentState?.showBottomSheet(
        (context) {
          return SaveSharedMedia(
            sharedMedia: payload,
            onBottomSheetOpen: retrieveBottomSheetController,
            onSaveFile: saveMedia
          );
        },
      );
    }

    switchMainWidget(newMainWidget) => setState(() { _mainWidget = newMainWidget; });

    getContent() {
      _currentRepo?.getContent();
    }

    Widget buildMainWidget() {
      return _repositories.current.builder((currentRepo) {
        if (currentRepo == null) {
          return NoRepositoriesState(
            onNewRepositoryPressed: createRepoDialog,
            onAddRepositoryPressed: addRepoWithTokenDialog
          );
        }

        currentRepo.navigateTo(Strings.root);
        return _repositoryContentBuilder(currentRepo);
      });
    }

    @override
    Widget build(BuildContext context) {
      final currentRepoCubit = _repositories.current;

      return Scaffold(
        key: _scaffoldKey,
        appBar: _buildOuiSyncBar(),
        body: WillPopScope(
          child: Column(
            children: <Widget>[
              currentRepoCubit.builder((RepoCubit? repo) => RepositoryProgress(repo?.state)),
              Expanded(child: buildMainWidget()),
            ]
          ),
          onWillPop: _onBackPressed
        ),
        floatingActionButton: currentRepoCubit.builder((repo) => _buildFAB(context, repo)),
      );
    }

    Future<bool> _onBackPressed() async {
      final currentRepo = _currentRepo;
      final currentFolder = currentRepo?.currentFolder;

      if (currentFolder == null || currentFolder.isRoot()) {
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

      if (currentRepo == null) {
        return false;
      }

      currentFolder.goUp();
      getContent();

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
      final button = Fields.actionIcon(
        const Icon(Icons.settings_outlined),
        onPressed: () async {
          bool dhtStatus = _currentRepo?.state.isDhtEnabled() ?? false;
          settingsAction(dhtStatus);
        },
        size: Dimensions.sizeIconSmall,
        color: Theme.of(context).colorScheme.surface
      );
      // TODO: Add a link to where one can download a new version (if any).
      return Container(child: Fields.addUpgradeBadge(button));
    }

    StatelessWidget _buildFAB(BuildContext context, RepoCubit? current) {
      if (current == null) {
        return Container();
      }

      if (!current.canWrite) {
        return Container();
      }

      return FloatingActionButton(
        heroTag: Constants.heroTagMainPageActions,
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(context, current),
      );
    }

    _repositoryContentBuilder(RepoCubit repo) => repo.consumer(
      (state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _selectLayoutWidget();
      },
      (state) {
        while (state.messages.isNotEmpty) {
          showSnackBar(context, content: Text(state.messages.removeAt(0)));
        }
      }
    );

    _selectLayoutWidget() {
      final current = _currentRepo;

      if (current == null) {
        return NoRepositoriesState(
          onNewRepositoryPressed: createRepoDialog,
          onAddRepositoryPressed: addRepoWithTokenDialog
        );
      }

      if (!current.canRead) {
        return LockedRepositoryState(
          repositoryName: current.state.name,
          onUnlockPressed: unlockRepositoryDialog,
        );
      }

      return _contentBrowser(current);
    }

    _contentBrowser(RepoCubit currentRepo) {
      late final child;
      late final navigationBar;
      final folder = currentRepo.currentFolder;

      if (folder.content.isEmpty) {
          child = NoContentsState(repository: folder.repo, path: folder.path);
      } else {
          child = _contentsList(currentRepo);
      }

      if (folder.isRoot()) {
        navigationBar = SizedBox.shrink();
      } else {
        navigationBar = FolderNavigationBar(currentRepo);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          navigationBar,
          // TODO: A shadow would be nicer.
          Divider(height: 3),
          Expanded(child: child),
        ],
      );
    }

    _contentsList(RepoCubit currentRepo) => ValueListenableBuilder(
      valueListenable: _bottomPaddingWithBottomSheet,
      builder: (context, value, child) => RefreshIndicator(
        onRefresh: () async => getContent(),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: value as double),
          separatorBuilder: (context, index) =>
            const Divider(
              height: 1,
              color: Colors.transparent),
          itemCount: currentRepo.currentFolder.content.length,
          itemBuilder: (context, index) {
            final item = currentRepo.currentFolder.content[index];
            final actionByType = item.type == ItemType.file
            ? () async {
              if (_persistentBottomSheetController != null) {
                await Dialogs.simpleAlertDialog(
                  context: context,
                  title: S.current.titleMovingEntry,
                  message: S.current.messageMovingEntry
                );
                return;
              }

              /// For now, only Android can preview files.
              if (!io.Platform.isAndroid) {
                showSnackBar(context, content: Text(S.current.messageFilePreviewNotAvailable));
                return;
              }

              await NativeChannels.previewOuiSyncFile(item.path, item.size, useDefaultApp: true); 
            }
            : () {
              if (_persistentBottomSheetController != null && _pathEntryToMove == item.path) {
                return;
              }

              currentRepo.navigateTo(item.path);
            };

            final listItem = ListItem (
              repository: currentRepo,
              itemData: item,
              mainAction: actionByType,
              folderDotsAction: () async {
                if (_persistentBottomSheetController != null) {
                  await Dialogs.simpleAlertDialog(
                    context: context,
                    title: S.current.titleMovingEntry,
                    message: S.current.messageMovingEntry
                  );

                  return;
                }

                item.type == ItemType.file
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
          }
        )
      )
    );

    Future<dynamic> _showShareRepository(RepoState repository)
        => showModalBottomSheet(
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
      }
    );

    Future<dynamic> _showFileDetails({
      required RepoCubit repoCubit,
      required GlobalKey<ScaffoldState> scaffoldKey,
      required BaseItem data
    }) => showModalBottomSheet(
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
          onMoveEntry: (origin, path, type) => moveEntry(repoCubit, origin, path, type),
        );
      }
    );

    Future<dynamic> _showFolderDetails({
      required RepoCubit repoCubit,
      required GlobalKey<ScaffoldState> scaffoldKey,
      required BaseItem data
    }) => showModalBottomSheet(
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
          onMoveEntry: (origin, path, type) => moveEntry(repoCubit, origin, path, type),
        );
      }
    );

  void retrieveBottomSheetController(PersistentBottomSheetController? controller, String entryPath) {
    _persistentBottomSheetController = controller;
    _pathEntryToMove = entryPath;
    _bottomPaddingWithBottomSheet.value = defaultBottomPadding;
  }

  void moveEntry(RepoCubit currentRepo, origin, path, type) async {
    final basename = getBasename(path);
    final destination = buildDestinationPath(currentRepo.currentFolder.path, basename);

    _persistentBottomSheetController!.close();
    _persistentBottomSheetController = null;

    currentRepo.moveEntry(
      source: path,
      destination: destination
    );
  }

  Future<void> saveMedia(String sourceFilePath) async {
    final currentRepo = _currentRepo;

    if (currentRepo == null) {
      showSnackBar(context, content: Text(S.current.messageNoRepo));
      return;
    }

    if (sourceFilePath == null) {
      showSnackBar(context, content: Text(S.current.mesageNoMediaPresent));
      return;
    }

    String? accessModeMessage = !currentRepo.canRead
      ? S.current.messageAddingFileToLockedRepository
      : !currentRepo.canWrite
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
              child: ListBody(children: [
                Text(accessModeMessage)
              ]),
            ),
            actions: [
              TextButton(
                child: Text(S.current.actionCloseCapital),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
      });

      return;
    }

    loggy.app('Media path: $sourceFilePath');
    saveFileToOuiSync(currentRepo, sourceFilePath);
  }

  void saveFileToOuiSync(RepoCubit currentRepo, String path) {
    final fileName = getBasename(path);
    final length = io.File(path).statSync().size;
    final filePath = buildDestinationPath(currentRepo.currentFolder.path, fileName);
    final fileByteStream = io.File(path).openRead();
        
    currentRepo.saveFile(
      newFilePath: filePath,
      fileName: fileName,
      length: length,
      fileByteStream: fileByteStream
    );
  }

  Future<dynamic> _showDirectoryActions(BuildContext context, RepoCubit cubit)
      => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) {
      return DirectoryActions(
        context: context,
        cubit: cubit,
      );
    }
  );

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
      }
    );
  }

  void addRepoWithTokenDialog({ String? initialTokenValue }) async {
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
      }
    );
  }

  void unlockRepositoryDialog(String repositoryName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.messageUnlockRepository,
          body: UnlockRepository(
            context: context,
            formKey: formKey,
            repositoryName:  repositoryName
          ),
        );
      }
    ).then((password) async {
      if (password.isNotEmpty) { // The password provided by the user.
        _repositories.unlockRepository(
          name: repositoryName,
          password: password
        );
      }
    });
  }

  void settingsAction(dhtStatus) {
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
            dhtStatus: dhtStatus,
          )
        );
      })
    );
  }
}
