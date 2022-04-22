import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../generated/l10n.dart';
import '../bloc/blocs.dart';
import '../cubit/cubits.dart';
import '../models/models.dart';
import '../models/main_state.dart';
import '../models/folder_state.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../utils/actions.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

typedef RepositoryCallback = Future<void> Function(RepoState? repository, AccessMode? previousAccessMode);
typedef ShareRepositoryCallback = void Function();
typedef BottomSheetControllerCallback = void Function(PersistentBottomSheetController? controller, String entryPath);
typedef MoveEntryCallback = void Function(String origin, String path, EntryType type);
typedef SaveFileCallback = void Function();

class MainPage extends StatefulWidget {
  const MainPage({
    required this.session,
    required this.repositoriesLocation,
    required this.defaultRepositoryName,
    required this.intentStream
  });

  final Session session;
  final String repositoriesLocation;
  final String defaultRepositoryName;
  final Stream<List<SharedMediaFile>> intentStream;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
  with TickerProviderStateMixin, OuiSyncAppLogger {

    MainState _mainState = MainState();

    StreamSubscription<ConnectivityResult>? _connectivitySubscription;
    List<SharedMediaFile> _intentPayload = <SharedMediaFile>[];

    final _scaffoldKey = GlobalKey<ScaffoldState>();

    String _pathEntryToMove = '';
    PersistentBottomSheetController? _persistentBottomSheetController;

    Widget _mainWidget = LoadingMainPageState();

    final double defaultBottomPadding = kFloatingActionButtonMargin + Dimensions.paddingBottomWithFloatingButtonExtra;
    ValueNotifier<double> _bottomPaddingWithBottomSheet = ValueNotifier<double>(0.0);

    // A timestamp (ms since epoch) when was the last time the user hit the
    // back button from the directory root. If the user hits it twice within
    // exitBackButtonTimeoutMs duration, then the app will exit.
    int lastExitAttempt = 0;
    final int exitBackButtonTimeoutMs = 3000;

    FolderState? get currentFolder => _mainState.currentFolder;

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
            // TODO
          }
          break;
        }
      });

      _mainState.setSubscriptionCallback(getContent);

      _initRepositories()
      .then((_) {
        initMainPage();
      });

      widget.intentStream
      .listen((listOfMedia) {
        _intentPayload = listOfMedia;
        handleShareIntentPayload(_intentPayload);
      });

      _connectivitySubscription = Connectivity()
      .onConnectivityChanged
      .listen(_connectivityChange);
    }

    @override
    void dispose() async {
      await _mainState.close();
      _connectivitySubscription?.cancel();
      super.dispose();
    }

    Future<void> _initRepositories() async {
      final repositoriesCubit = BlocProvider
      .of<RepositoriesCubit>(context);

      final initRepos = RepositoryHelper
      .localRepositoriesFiles(
        widget.repositoriesLocation,
        justNames: true
      ).map((repoName) async {
        final repo = await repositoriesCubit.initRepository(repoName);
        await _mainState.put(
          repo!,
          setCurrent: (repoName == widget.defaultRepositoryName)
        );
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

      BlocProvider
      .of<RepositoriesCubit>(context)
      .selectRepository(_mainState.current);
    }

    void handleShareIntentPayload(
      List<SharedMediaFile> payload
    ) {
      if (_intentPayload.isEmpty) {
        return;
      }

      _bottomPaddingWithBottomSheet.value = defaultBottomPadding + Dimensions.paddingBottomWithBottomSheetExtra;
      _showSaveSharedMedia(sharedMedia: _intentPayload);
    }

    switchMainWidget(newMainWidget) => setState(() { _mainWidget = newMainWidget; });

    getContent(RepoState repository) {
      BlocProvider
      .of<DirectoryBloc>(context)
      .add(GetContent(repository: repository));
    }

    navigateToPath({
      required RepoState repository,
      required String destination,
      bool withProgress = false
    }) {
      final currentRepo = _mainState.current;

      if (currentRepo == null) {
        return;
      }

      final currentFolder = currentRepo.currentFolder;

      if (currentFolder.path != destination) {
        setState(() {
          currentFolder.path = destination;
        });
      }

      getContent(currentRepo);
    }

    PreferredSizeWidget _buildNavigationBar() {
      final currentRepo = _mainState.current;

      if (currentRepo == null || currentRepo.accessMode == AccessMode.blind) {
        return FolderNavigationBar(null, () {});
      }

      return FolderNavigationBar(currentRepo.currentFolder.path, () {
        setState(() {
          currentRepo.currentFolder.goUp();
        });
        getContent(currentRepo);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: _buildOuiSyncBar(),
        body: WillPopScope(
          child: DropTarget(
            onDragDone: (detail) {
              loggy.app('onDropDone: ${detail.files.first.path}');
              
              final xFile = detail.files.firstOrNull;
              if (xFile != null) {
                final file = io.File(xFile.path);
                saveMedia(droppedMediaFile: file);
              }
            },
            onDragEntered: (detail) {
              loggy.app('onDropEntered: ${detail.localPosition}');
            },
            onDragExited: (detail) {
              loggy.app('onDropExited: ${detail.localPosition}');
            },
            child: _mainWidget
          ),
          onWillPop: _onBackPressed
        ),
        floatingActionButton: _buildFAB(context),
      );
    }

    Future<bool> _onBackPressed() async {
      final currentRepo = _mainState.current;

      if (currentRepo == null) {
        return false;
      }

      final currentFolder = currentRepo.currentFolder;

      if (currentFolder.isRoot()) {
        // If the user clicks twice the back button within
        // exitBackButtonTimeoutMs timeout, then exit the app.
        int now = DateTime.now().millisecondsSinceEpoch;

        if (now - lastExitAttempt > exitBackButtonTimeoutMs) {
          lastExitAttempt = now;
          showSnackBar(context, content: Text(S.current.messageExitOuiSync));

          // Don't pop => don't exit
          return false;
        } else {
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

      currentFolder.goUp();
      getContent(currentRepo);

      return false;
    }

    _buildOuiSyncBar() => OuiSyncBar(
      repoList: _buildRepositoriesBar(),
      actionList: _buildActionList(),
      bottomWidget: _buildNavigationBar(),
    );

    RepositoriesBar _buildRepositoriesBar() {
      return RepositoriesBar(
        mainState: _mainState,
        repositoriesCubit: BlocProvider.of<RepositoriesCubit>(context),
        onRepositorySelect: switchRepository,
        shareRepositoryOnTap: shareRepository,
      );
    }

    List<Widget> _buildActionList() => [
      Container(
        child: Fields.actionIcon(
          const Icon(Icons.settings_outlined),
          onPressed: () async {
            bool dhtStatus = await _mainState.current?.repo.isDhtEnabled() ?? false;

            settingsAction(
              BlocProvider.of<RepositoriesCubit>(context),
              dhtStatus
            );
          },
          size: Dimensions.sizeIconSmall,
          color: Theme.of(context).colorScheme.surface
        ),
      )
    ];

    StatelessWidget _buildFAB(BuildContext context,) {
      final current = _mainState.current;

      if (current == null) {
        return Container();
      }

      if ([AccessMode.blind, AccessMode.read].contains(current.accessMode)) {
        return Container();
      }

      return new FloatingActionButton(
        heroTag: Constants.heroTagMainPageActions,
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(
          context,
          bloc: BlocProvider.of<DirectoryBloc>(context),
          folder: currentFolder!
        ),
      );
    }

    Future<void> switchRepository(RepoState? repository, AccessMode? previousAccessMode) async {
      NativeChannels.setRepository(repository?.repo);

      if (repository == null) {
        switchMainWidget(
          NoRepositoriesState(
            repositoriesCubit: BlocProvider.of<RepositoriesCubit>(context),
            onNewRepositoryPressed: createRepoDialog,
            onAddRepositoryPressed: addRepoWithTokenDialog
          )
        );
        return;
      }

      await _mainState.put(repository, setCurrent: true);

      switchMainWidget(_repositoryContentBuilder());

      navigateToPath(
        repository: _mainState.current!,
        destination: Strings.root,
        withProgress: true
      );
    }

    void shareRepository() async {
      final current = _mainState.current;

      if (current == null) {
        return;
      }

      await _showShareRepository(context, current);
    }

    _repositoryContentBuilder() => BlocConsumer<DirectoryBloc, DirectoryState>(
      buildWhen: (context, state) {
        return !(
        state is CreateFileDone ||
        state is CreateFileFailure ||
        state is WriteToFileInProgress ||
        state is WriteToFileDone ||
        state is WriteToFileCanceled ||
        state is WriteToFileFailure);
      },
      builder: (context, state) {
        if (state is DirectoryInitial) {
          return Center(
            child: Fields.inPageSecondaryMessage(S.current.messageLoadingContents)
          );
        }

        if (state is DirectoryLoadInProgress) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is DirectoryLoadSuccess) {
          return _selectLayoutWidget();
        }

        if (state is DirectoryLoadFailure) {
          return _selectLayoutWidget();
        }

        return _errorState(
          message: S.current.messageErrorLoadingContents,
          actionReload: () => getContent(_mainState.current!)
        );
      },
      listener: (context, state) {
        if (state is DirectoryLoadFailure) {
          final destination = getParentSection(currentFolder!.path);
          final parent = getParentSection(destination);

          final errorMessage = S.current.messageErrorCurrentPathMissing(destination);
          loggy.app(errorMessage);
          showSnackBar(context, content: Text(errorMessage));

          navigateToPath(
            repository: _mainState.current!,
            destination: destination,
            withProgress: true
          );
        }

        if (state is CreateFileFailure) {
          showSnackBar(context, content: Text(S.current.messageNewFileError(state.path)));
        }

        if (state is WriteToFileDone) {
          showSnackBar(context, content: Text(S.current.messageWritingFileDone(state.path)));
        }

        if (state is WriteToFileCanceled) {
          showSnackBar(context, content: Text(S.current.messageWritingFileCanceled(state.path)));
        }

        if (state is WriteToFileFailure) {
          showSnackBar(context, content: Text(S.current.messageWritingFileError(state.path)));
        }
      }
    );

    _selectLayoutWidget() {
      final current = _mainState.current;

      if (current == null) {
        return NoRepositoriesState(
          repositoriesCubit: BlocProvider.of<RepositoriesCubit>(context),
          onNewRepositoryPressed: createRepoDialog,
          onAddRepositoryPressed: addRepoWithTokenDialog
        );
      }

      if (current.accessMode == AccessMode.blind) {
        return LockedRepositoryState(
          repositoryName: current.name,
          onUnlockPressed: unlockRepositoryDialog,
        );
      }

      if (currentFolder!.content.isEmpty) {
        return NoContentsState(
          repository: current,
          path: currentFolder!.path
        );
      }

      return _contentsList(
        repository: current,
        path: currentFolder!.path
      );
    }

    _errorState({
      required String message,
      required void Function()? actionReload
    }) => ErrorState(
      message: message,
      onReload: actionReload
    );

    _contentsList({
      required RepoState repository,
      required String path
    }) => ValueListenableBuilder(
      valueListenable: _bottomPaddingWithBottomSheet,
      builder: (context, value, child) => RefreshIndicator(
        onRefresh: () => getContent(repository),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: value as double),
          separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.transparent
          ),
          itemCount: currentFolder!.content.length,
          itemBuilder: (context, index) {
            final item = currentFolder!.content[index];
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

              _showFileDetails(
                repo: repository,
                directoryBloc: BlocProvider.of<DirectoryBloc>(context),
                scaffoldKey: _scaffoldKey,
                data: item
              );
            }
            : () {
              if (_persistentBottomSheetController != null && _pathEntryToMove == item.path) {
                return;
              }

              navigateToPath(
                repository: repository,
                destination: item.path,
                withProgress: true
              );
            };

            final listItem = ListItem (
              itemData: item,
              mainAction: actionByType,
              filePopupMenu: _popupMenu(repository: repository, data: item),
              folderDotsAction: () async {
                if (_persistentBottomSheetController != null) {
                  await Dialogs
                  .simpleAlertDialog(
                    context: context,
                    title: S.current.titleMovingEntry,
                    message: S.current.messageMovingEntry
                  );

                  return;
                }

                await _showFolderDetails(
                  repo: repository,
                  directoryBloc: BlocProvider.of<DirectoryBloc>(context),
                  scaffoldKey: _scaffoldKey,
                  data: item
                );
              },
            );

            return listItem;
          }
        )
      )
    );

    _popupMenu({
      required RepoState repository,
      required BaseItem data
    }) {
      final availableActions = repository.accessMode == AccessMode.write
      ? {
        S.current.actionPreviewFile: data,
        S.current.actionShareFile: data,
        S.current.actionDeleteFile: data
      } : {
        S.current.actionPreviewFile: data,
        S.current.actionShareFile: data,
      };

      return Dialogs
      .filePopupMenu(
        context,
        repository.repo,
        BlocProvider.of<DirectoryBloc>(context),
        availableActions
      );
    }

    Future<dynamic> _showShareRepository(context, RepoState repo_state)
        => showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusSmall),
          topRight: Radius.circular(Dimensions.radiusSmall),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
      builder: (context) {
        final accessModes = repo_state.accessMode == AccessMode.write
          ? [AccessMode.blind, AccessMode.read, AccessMode.write]
          : repo_state.accessMode == AccessMode.read
            ? [AccessMode.blind, AccessMode.read]
            : [AccessMode.blind];

        return ShareRepository(
          repository: repo_state.repo,
          repositoryName: repo_state.name,
          availableAccessModes: accessModes,
        );
      }
    );

    Future<dynamic> _showFileDetails({
      required RepoState repo,
      required DirectoryBloc directoryBloc,
      required GlobalKey<ScaffoldState> scaffoldKey,
      required BaseItem data
    }) => showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusSmall),
          topRight: Radius.circular(Dimensions.radiusSmall),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
      builder: (context) {
        return FileDetail(
          context: context,
          bloc: directoryBloc,
          repository: repo,
          data: data as FileItem,
          scaffoldKey: scaffoldKey,
          onBottomSheetOpen: retrieveBottomSheetController,
          onMoveEntry: moveEntry
        );
      }
    );

    Future<dynamic> _showFolderDetails({
      required RepoState repo,
      required DirectoryBloc directoryBloc,
      required GlobalKey<ScaffoldState> scaffoldKey,
      required BaseItem data
    }) => showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusSmall),
          topRight: Radius.circular(Dimensions.radiusSmall),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
      builder: (context) {
        return FolderDetail(
          context: context,
          bloc: directoryBloc,
          repository: repo,
          data: data as FolderItem,
          scaffoldKey: scaffoldKey,
          onBottomSheetOpen: retrieveBottomSheetController,
          onMoveEntry: moveEntry
        );
      }
    );

  PersistentBottomSheetController? _showSaveSharedMedia({
    required List<SharedMediaFile> sharedMedia
  }) => _scaffoldKey.currentState?.showBottomSheet(
    (context) {
      return SaveSharedMedia(
        sharedMedia: sharedMedia,
        onBottomSheetOpen: retrieveBottomSheetController,
        onSaveFile: saveSharedMedia
      );
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    )
  );

  void retrieveBottomSheetController(PersistentBottomSheetController? controller, String entryPath) {
    _persistentBottomSheetController = controller;
    _pathEntryToMove = entryPath;
    _bottomPaddingWithBottomSheet.value = defaultBottomPadding;
  }

  void moveEntry(origin, path, type) async {
    final entryName = getBasename(path);
    final newDestinationPath = buildDestinationPath(currentFolder!.path, entryName);

    _persistentBottomSheetController!.close();
    _persistentBottomSheetController = null;

    BlocProvider.of<DirectoryBloc>(context)
    .add(
      MoveEntry(
        repository: _mainState.current!,
        origin: origin,
        destination: currentFolder!.path,
        entryPath: path,
        newDestinationPath: newDestinationPath
      )
    );
  }

  Future<void> saveMedia({ SharedMediaFile? mobileSharedMediaFile, io.File? droppedMediaFile }) async {
    final currentRepo = _mainState.current;

    if (currentRepo == null) {
      showSnackBar(context, content: Text(S.current.messageNoRepo));
      return;
    }

    if (mobileSharedMediaFile == null &&
    droppedMediaFile == null) {
      showSnackBar(context, content: Text(S.current.mesageNoMediaPresent));
      return;
    }

    String? accessModeMessage = currentRepo.accessMode == AccessMode.blind
      ? S.current.messageAddingFileToLockedRepository
      : currentRepo.accessMode == AccessMode.read
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
                onPressed: () => 
                Navigator.of(context).pop(),
              )
            ],
          );
      });

      return;
    }

    final String? path = mobileSharedMediaFile?.path ?? droppedMediaFile?.path;
    if (path == null) {
      return;
    }

    loggy.app('Media path: $path');
    saveFileToOuiSync(path);
  }

  void saveFileToOuiSync(String path) {
    final fileName = getBasename(path);
    final length = io.File(path).statSync().size;
    final filePath = buildDestinationPath(currentFolder!.path, fileName);
    final fileByteStream = io.File(path).openRead();
        
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      SaveFile(
        repository: _mainState.current!,
        newFilePath: filePath,
        fileName: fileName,
        length: length,
        fileByteStream: fileByteStream
      )
    );

    Navigator.of(context).pop();
  }

  void saveSharedMedia() async {
    final current = _mainState.current;

    if (current == null) {
      showSnackBar(context, content: Text(S.current.messageNoRepo));
      return;
    }

    SharedMediaFile? mediaInfo = _intentPayload.firstOrNull;
    if (mediaInfo == null) {
      showSnackBar(context, content: Text(S.current.mesageNoMediaPresent));
      return;
    }

    String? accessModeMessage = current.accessMode == AccessMode.blind
      ? S.current.messageAddingFileToLockedRepository
      : current.accessMode == AccessMode.read
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

    final fileName = getBasename(_intentPayload.first.path);
    final length = io.File(_intentPayload.first.path).statSync().size;
    final filePath = buildDestinationPath(currentFolder!.path, fileName);

    final fileByteStream = io.File(_intentPayload.first.path).openRead();

    BlocProvider.of<DirectoryBloc>(context)
    .add(
      SaveFile(
        repository: current,
        newFilePath: filePath,
        fileName: fileName,
        length: length,
        fileByteStream: fileByteStream
      )
    );

    Navigator.of(context).pop();
  }

  Future<dynamic> _showDirectoryActions(BuildContext context,{
    required DirectoryBloc bloc,
    required FolderState folder
  }) => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.radiusSmall),
        topRight: Radius.circular(Dimensions.radiusSmall),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    ),
    builder: (context) {
      return DirectoryActions(
        context: context,
        bloc: bloc,
        parent: folder,
      );
    }
  );

  void createRepoDialog(cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleCreateRepository,
          body: RepositoryCreation(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    );
  }

  void addRepoWithTokenDialog(cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleAddRepository,
          body: AddRepositoryWithToken(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((addedRepository) {
      if (addedRepository.isNotEmpty) { // If a repository is created, the new repository name is returned; otherwise, empty string.
        switchMainWidget(_repositoryContentBuilder());
      }
    });
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
        final name = _mainState.current!.name;
        await _mainState.remove(name);

        BlocProvider.of<RepositoriesCubit>(context)
        .unlockRepository(
          name: repositoryName,
          password: password
        );
      }
    });
  }

  void settingsAction(reposCubit, dhtStatus) {
    final connectivityCubit = BlocProvider.of<ConnectivityCubit>(context);
    final peerSetCubit = BlocProvider.of<PeerSetCubit>(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: connectivityCubit),
            BlocProvider.value(value: peerSetCubit),
          ],
          child: SettingsPage(
            mainState: _mainState,
            repositoriesCubit: reposCubit,
            onRepositorySelect: switchRepository,
            onShareRepository: shareRepository,
            title: S.current.titleSettings,
            dhtStatus: dhtStatus,
          )
        );
      })
    );
  }
}
