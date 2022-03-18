import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:move_to_background/move_to_background.dart';

import '../bloc/blocs.dart';
import '../cubit/cubits.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'pages.dart';

typedef RepositoryCallback = void Function(Repository? repository, String name, AccessMode? previousAccessMode);
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
  with TickerProviderStateMixin {

    RepositoriesService _repositoriesService = RepositoriesService();

    StreamSubscription<ConnectivityResult>? _connectivitySubscription;
    List<SharedMediaFile> _intentPayload = <SharedMediaFile>[];

    String _currentFolder = Strings.rootPath; // Initial value: /
  
    List<BaseItem> _folderContents = <BaseItem>[];
    
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    String _pathEntryToMove = '';
    PersistentBottomSheetController? _persistentBottomSheetController;

    Widget _mainState = LoadingMainPageState();

    final double defaultBottomPadding = kFloatingActionButtonMargin + Dimensions.paddingBottomWithFloatingButtonExtra;
    ValueNotifier<double> _bottomPaddingWithBottomSheet = ValueNotifier<double>(0.0);

    // A timestamp (ms since epoch) when was the last time the user hit the
    // back button from the directory root. If the user hits it twice within
    // exitBackButtonTimeoutMs duration, then the app will exit.
    int lastExitAttempt = 0;
    final int exitBackButtonTimeoutMs = 3000;

    @override
    void initState() {
      super.initState();
      
      _repositoriesService.setSubscriptionCallback(_syncCurrentFolder);

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
    void dispose() {
      _repositoriesService.close();
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
        _repositoriesService.put(
            repoName,
            repo!,
            setCurrent: (repoName == widget.defaultRepositoryName));
      }).toList();

      await Future.wait(initRepos);
    }

    void _connectivityChange(ConnectivityResult result) {
      print('Connectivity event: ${result.name}');
      
      BlocProvider
      .of<ConnectivityCubit>(context)
      .connectivityEvent(result);
    }

    void initMainPage() async {
      _bottomPaddingWithBottomSheet = ValueNotifier<double>(defaultBottomPadding);
      
      BlocProvider
      .of<RepositoriesCubit>(context)
      .selectRepository(_repositoriesService.current);
    }

    Future<void> unlockRepository(String repositoryName, String password) async {
      BlocProvider
      .of<RepositoriesCubit>(context)
      .openRepository(
        name: repositoryName,
        password: password
      );
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

    switchMainState({newState}) => setState(() { _mainState = newState; });

    updateCurrentFolder({required String path}) => setState(() { _currentFolder = path; });

    getContents({
      required Repository repository,
      required String path,
    }) { 
      BlocProvider
      .of<DirectoryBloc>(context)
      .add(GetContent(
        repository: repository,
        path: path,
      ));
    }

    navigateToPath({
      required Repository repository,
      AccessMode? previousAccessMode,
      required String origin,
      required String destination,
      bool withProgress = false
    }) {
      BlocProvider
      .of<DirectoryBloc>(context)
      .add(NavigateTo(
        repository: repository,
        previousAccessMode: previousAccessMode,
        origin: origin,
        destination: destination,
        withProgress: withProgress
      )); 
    }

    updateRoute({
      required Repository repository,
      required String destination
    }) {
      BlocProvider
      .of<RouteBloc>(context)
      .add(UpdateRoute(
        path: destination,
        action: () { //Back button action, hence we invert the origin and destination values
          final from = destination;
          final backTo = extractParentFromPath(from);

          BlocProvider
          .of<DirectoryBloc>(context)
          .add(NavigateTo(
            repository: repository,
            origin: from,
            destination: backTo,
            withProgress: true
          ));
        }
      ));
    }

    Future<void> refreshCurrent({
      required Repository repository,
      required String path
    }) async => getContents(
      repository: repository,
      path: path,
    );

    void _syncCurrentFolder(String repositoryName) { 
      if (!_repositoriesService.hasCurrent) {
        return;
      }

      if (_repositoriesService.current!.name != repositoryName) {
        return;
      }

      if (_repositoriesService.current!.repo.accessMode != AccessMode.blind) {
        getContents(
          repository: _repositoriesService.current!.repo,
          path: _currentFolder,
        ); 
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: _buildOuiSyncBar(),
        body: WillPopScope(
          child: _mainState,
          onWillPop: _onBackPressed
        ),
        floatingActionButton: _buildFAB(context),
      );
    }

    Future<bool> _onBackPressed() async {
      if (_currentFolder == Strings.rootPath) {
        // If the user clicks twice the back button within
        // exitBackButtonTimeoutMs timeout, then exit the app.
        int now = DateTime.now().millisecondsSinceEpoch;

        if (now - lastExitAttempt > exitBackButtonTimeoutMs) {
          lastExitAttempt = now;
          Fluttertoast.showToast(
            msg: Strings.messageExitOuiSync,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);

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

      if (_repositoriesService.hasCurrent) {
        final parent = extractParentFromPath(_currentFolder);

        BlocProvider
        .of<DirectoryBloc>(context)
        .add(NavigateTo(
          repository: _repositoriesService.current!.repo,
          origin: _currentFolder,
          destination: parent,
          withProgress: true
        ));
      }

      return false;
    }

    _buildOuiSyncBar() => OuiSyncBar(
      leadingAppBranding: null,
      titleCentralWidget: _buildRepositoriesBar(),
      actionList: _buildActionList(),
      bottomWidget: FolderNavigationBar(),
      bottomPreferredSize: Size.fromHeight(120.0),
      toolbarHeight: 90.0,
    );

    RepositoriesBar _buildRepositoriesBar() {
      return RepositoriesBar(
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
            bool dhtStatus = await _repositoriesService.current?.repo.isDhtEnabled() ?? false;

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
      if (!_repositoriesService.hasCurrent) {
        return Container();
      }

      if ([AccessMode.blind, AccessMode.read]
      .contains(_repositoriesService.current!.repo.accessMode)
      ) {
        return Container();
      }

      return new FloatingActionButton(
        heroTag: Constants.heroTagMainPageActions,
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(
          context, 
          bloc: BlocProvider.of<DirectoryBloc>(context), 
          repository: _repositoriesService.current!.repo, 
          parent: _currentFolder
        ),
      );
    }

    void switchRepository(Repository? repository, String name, AccessMode? previousAccessMode) {
      NativeChannels.setRepository(repository); 

      if (repository == null) {
        switchMainState(
          newState:NoRepositoriesState(
            repositoriesCubit: BlocProvider.of<RepositoriesCubit>(context),
            onNewRepositoryPressed: createRepoDialog,
            onAddRepositoryPressed: addRepoWithTokenDialog
          )
        );
        return;
      }

      _repositoriesService.put(name, repository, setCurrent: true);
    
      switchMainState(newState: _repositoryContentBuilder());

      navigateToPath(
        repository: _repositoriesService.current!.repo,
        previousAccessMode: previousAccessMode,
        origin: Strings.rootPath,
        destination: Strings.rootPath,
        withProgress: true
      );
    }

    void shareRepository() async {
      if (!_repositoriesService.hasCurrent) {
        return;
      }
      
      await _showShareRepository(context, _repositoriesService.current!);
    }

    _repositoryContentBuilder() => BlocConsumer<DirectoryBloc, DirectoryState>(
      buildWhen: (context, state) {
        return !(
        state is CreateFileDone ||
        state is CreateFileFailure ||
        state is WriteToFileInProgress ||
        state is WriteToFileDone ||
        state is WriteToFileFailure);
      },
      builder: (context, state) {
        if (state is DirectoryInitial) {
          return Center(
            child: Fields.inPageSecondaryMessage(Strings.messageLoadingContents)
          );
        }

        if (state is DirectoryLoadInProgress) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is DirectoryLoadSuccess) {
          if (state.path == _currentFolder) {
            return _selectLayoutWidget(
              repo: _repositoriesService.current!,
              path: _currentFolder,
              isContentsEmpty: state.contents.isEmpty
            );  
          }
          return _selectLayoutWidget(
            repo: _repositoriesService.current!,
            path: _currentFolder,
            isContentsEmpty: _folderContents.isEmpty
          );
        }
        
        if (state is NavigationLoadSuccess) {
          return _selectLayoutWidget(
            repo: _repositoriesService.current!,
            path: _currentFolder,
            isContentsEmpty: state.contents.isEmpty
          );
        }

        if (state is NavigationLoadBlind) {
          return _selectLayoutWidget(
            repo: _repositoriesService.current!,
            path: '',
            isContentsEmpty: true,
            isBlind: true
          ); 
        }

        if (state is DirectoryLoadFailure) {
          if (state.error == Strings.errorEntryNotFound) {
            final parent = extractParentFromPath(_currentFolder);
            return _contentsList(
              repository: _repositoriesService.current!.repo,
              path: parent,
            );
          }

          return _errorState(
            message: Strings.messageErrorState,
            actionReload: () => refreshCurrent(
              repository: _repositoriesService.current!.repo,
              path: _currentFolder
            )
          );
        }

        if (state is NavigationLoadFailure) {
          return _errorState(
            message: Strings.messageErrorState,
            actionReload: () => refreshCurrent(
              repository: _repositoriesService.current!.repo,
              path: _currentFolder
            )
          );
        }

        return _errorState(
          message: Strings.messageErrorLoadingContents,
          actionReload: () => refreshCurrent(
            repository: _repositoriesService.current!.repo,
            path: _currentFolder
          )
        );
      },
      listener: (context, state) {
        if (state is DirectoryLoadFailure) {
          final destination = extractParentFromPath(_currentFolder);
          final parent = extractParentFromPath(destination);

          final errorMessage = Strings.messageErrorCurrentPathMissing
          .replaceAll(Strings.replacementPath, destination);

          print(errorMessage);
          Fluttertoast.showToast(msg: errorMessage);

          updateCurrentFolder(path: destination);
          navigateToPath(
            repository: _repositoriesService.current!.repo,
            origin: parent,
            destination: destination,
            withProgress: true
          );
        }

        if (state is DirectoryLoadSuccess) {
          updateFolderContents(newContent: state.contents);
          return;
        }

        if (state is NavigationLoadSuccess) {
          print('Current path updated: $_currentFolder, ${state.contents.length} entries');

          updateCurrentFolder(path: state.destination);
          updateFolderContents(newContent: state.contents);
          updateRoute(
            repository: _repositoriesService.current!.repo,
            destination: state.destination
          );

          return;
        }

        if (state is NavigationLoadBlind) {
          if (state.previousAccessMode == AccessMode.blind) {
            showDialog<bool>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (context) {
                return AlertDialog(
                  title: Text('Unlock repository'),
                  content: SingleChildScrollView(
                    child: ListBody(children: [
                      Text('Unlocking the repository failed'
                        '\n\n'
                        'Check the password and try again'
                      )
                    ]),
                  ),
                  actions: [
                    TextButton(
                      child: const Text(Strings.actionCloseCapital),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              });
          }
        }

        if (state is CreateFileFailure) {
          print('Error creating new file ${state.filePath}: ${state.error}');

          Fluttertoast.showToast(msg:
            Strings
            .messageNewFileError
            .replaceAll(
              Strings.replacementName,
              state.filePath
            )
          );
        }

        if (state is WriteToFileDone) {
          Fluttertoast.showToast(msg:
            Strings
            .messageWritingFileDone
            .replaceAll(
              Strings.replacementName,
              state.filePath
            ) 
          );
        }

        if (state is WriteToFileFailure) {
          print('Writing to file ${state.fileName} failed (${state.filePath}): ${state.error}');

          Fluttertoast.showToast(msg:
            Strings
            .messageWritingFileError
            .replaceAll(
              Strings.replacementName,
              state.filePath
            )
          );
        }
      }
    );

    _selectLayoutWidget({
      required NamedRepo repo,
      required String path,
      required bool isContentsEmpty,
      bool isBlind = false
    }) {
      if (isBlind) {
        return LockedRepositoryState(
          repositoryName: repo.name,
          onUnlockPressed: unlockRepositoryDialog,
        );
      }
      
      if (isContentsEmpty) {
        return NoContentsState(
          repository: _repositoriesService.current!.repo,
          path: _currentFolder,
          onRefresh: refreshCurrent,
        );
      }

      return _contentsList(
        repository: repo.repo,
        path: path
      );
    }

    void updateFolderContents({required List<BaseItem> newContent}) {
      if (newContent.isEmpty) {
        if (_folderContents.isNotEmpty) {
          setState(() { _folderContents.clear(); }); 
        }
        return;
      }

      final orderedContent = newContent;
      orderedContent.sort((a, b) => a.type.index.compareTo(b.type.index));
      
      if (!DeepCollectionEquality.unordered().equals(orderedContent, _folderContents)) {
        setState(() { _folderContents = orderedContent; });
      }
    }

    _errorState({
      required String message,
      required void Function()? actionReload
    }) => ErrorState(
      message: message,
      onReload: actionReload
    );

    _contentsList({
      required Repository repository,
      required String path
    }) => ValueListenableBuilder(
      valueListenable: _bottomPaddingWithBottomSheet,
      builder: (context, value, child) => RefreshIndicator(
        onRefresh: () => refreshCurrent(repository: repository, path: path),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: value as double),
          separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.transparent
          ),
          itemCount: _folderContents.length,
          itemBuilder: (context, index) {
            final item = _folderContents[index];
            final actionByType = item.type == ItemType.file
            ? () async {
              if (_persistentBottomSheetController != null) {
                await Dialogs.simpleAlertDialog(
                  context: context,
                  title: Strings.titleMovingEntry,
                  message: Strings.messageMovingEntry
                );
                return;
              }

              _showFileDetails(
                repository: repository,
                directoryBloc: BlocProvider.of<DirectoryBloc>(context),
                scaffoldKey: _scaffoldKey,
                name: item.name,
                path: item.path,
                size: item.size
              );
            }
            : () {
              if (_persistentBottomSheetController != null &&
              _pathEntryToMove == item.path) {
                return;
              }

              navigateToPath(
                repository: repository,
                origin: path,
                destination: item.path,
                withProgress: true
              );
            };

            final listItem = ListItem (
              repository: repository,
              itemData: item,
              mainAction: actionByType,
              secondaryAction: () => {},
              filePopupMenu: _popupMenu(repository: repository, data: item),
              folderDotsAction: () async {
                if (_persistentBottomSheetController != null) {
                  await Dialogs
                  .simpleAlertDialog(
                    context: context,
                    title: Strings.titleMovingEntry,
                    message: Strings.messageMovingEntry
                  );

                  return;
                }
                
                await _showFolderDetails(
                  repository: repository,
                  directoryBloc: BlocProvider.of<DirectoryBloc>(context),
                  scaffoldKey: _scaffoldKey,
                  name: removeParentFromPath(item.path),
                  path: item.path
                );
              },
            );

            return listItem;
          }
        )
      )
    );

    _popupMenu({
      required Repository repository,
      required BaseItem data
    }) { 
      final availableActions = repository.accessMode == AccessMode.write
      ? {
        Strings.actionPreviewFile: data,
        Strings.actionShareFile: data,
        Strings.actionDeleteFile: data 
      } : { 
        Strings.actionPreviewFile: data,
        Strings.actionShareFile: data, 
      };

      return Dialogs
      .filePopupMenu(
        context,
        repository,
        BlocProvider. of<DirectoryBloc>(context),
        availableActions
      );
    }

    Future<dynamic> _showShareRepository(context, NamedRepo named)
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
        final accessModes = named.repo.accessMode == AccessMode.write
        ? [AccessMode.blind, AccessMode.read, AccessMode.write]
        : named.repo.accessMode == AccessMode.read
        ? [AccessMode.blind, AccessMode.read]
        : [AccessMode.blind];
  
        return ShareRepository(
          repository: named.repo,
          repositoryName: named.name,
          availableAccessModes: accessModes,
        );
      }
    );

    Future<dynamic> _showFileDetails({
      required Repository repository,
      required DirectoryBloc directoryBloc,
      required GlobalKey<ScaffoldState> scaffoldKey,
      required String name,
      required String path,
      required int size
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
          repository: repository,
          name: name,
          path: path,
          parent: extractParentFromPath(path),
          size: size,
          scaffoldKey: scaffoldKey,
          onBottomSheetOpen: retrieveBottomSheetController,
          onMoveEntry: moveEntry
        );
      }
    );

    Future<dynamic> _showFolderDetails({
      required Repository repository,
      required DirectoryBloc directoryBloc,
      required GlobalKey<ScaffoldState> scaffoldKey,
      required String name,
      required String path
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
          repository: repository,
          name: name,
          path: path,
          parent: extractParentFromPath(path),
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
    final entryName = removeParentFromPath(path);
    final newDestinationPath = _currentFolder == Strings.rootPath
    ? '/$entryName'
    : '$_currentFolder/$entryName';

    _persistentBottomSheetController!.close();
    _persistentBottomSheetController = null;

    BlocProvider.of<DirectoryBloc>(context)
    .add(
      MoveEntry(
        repository: _repositoriesService.current!.repo,
        origin: origin,
        destination: _currentFolder,
        entryPath: path,
        newDestinationPath: newDestinationPath
      )
    );
  }

  void saveSharedMedia() async {
    if (!_repositoriesService.hasCurrent) {
      Fluttertoast.showToast(msg: Strings.messageNoRepo);
      return;
    }

    SharedMediaFile? mediaInfo = _intentPayload.firstOrNull;
    if (mediaInfo == null) {
      Fluttertoast.showToast(msg: Strings.mesageNoMediaPresent);
      return;
    }

    String? accessModeMessage = _repositoriesService.current!.repo.accessMode == AccessMode.blind
    ? Strings.messageAddingFileToLockedRepository
    : _repositoriesService.current!.repo.accessMode == AccessMode.read
    ? Strings.messageAddingFileToReadRepository
    : null;

    if (accessModeMessage != null) {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return AlertDialog(
            title: Text(Strings.titleAddShareFilePage),
            content: SingleChildScrollView(
              child: ListBody(children: [
                Text(accessModeMessage)
              ]),
            ),
            actions: [
              TextButton(
                child: const Text(Strings.actionCloseCapital),
                onPressed: () => 
                Navigator.of(context).pop(),
              )
            ],
          );
      });

      return;
    }

    final fileName = getPathFromFileName(_intentPayload.first.path);
    final length = io.File(_intentPayload.first.path).statSync().size;
    final filePath = _currentFolder == Strings.rootPath
    ? '/$fileName'
    : '$_currentFolder/$fileName';
    final fileByteStream = io.File(_intentPayload.first.path).openRead();
        
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      SaveFile(
        repository: _repositoriesService.current!.repo,
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
    required Repository repository,
    required String parent
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
        repository: repository,
        parent: parent,
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
          title: Strings.titleCreateRepository,
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
          title: Strings.titleAddRepository,
          body: AddRepositoryWithToken(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((addedRepository) {
      if (addedRepository.isNotEmpty) { // If a repository is created, the new repository name is returned; otherwise, empty string.
        switchMainState(newState: _repositoryContentBuilder());
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
          title: Strings.messageUnlockRepository,
          body: UnlockRepository(
            context: context,
            formKey: formKey,
            repositoryName:  repositoryName
          ),
        );
      }
    ).then((password) {
      if (password.isNotEmpty) { // The password provided by the user.
        final name = _repositoriesService.current!.name;
        _repositoriesService.remove(name);

        BlocProvider.of<RepositoriesCubit>(context)
        .unlockRepository(
          name: repositoryName,
          password: password
        );
      }
    });
  }

  void settingsAction(reposCubit, dhtStatus) {
    final connectivityCubit = BlocProvider
    .of<ConnectivityCubit>(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BlocProvider.value(
          value: connectivityCubit,
          child: SettingsPage(
            repositoriesCubit: reposCubit,
            onRepositorySelect: switchRepository,
            onShareRepository: shareRepository,
            title: Strings.titleSettings,
            dhtStatus: dhtStatus,
          )
        );
      })
    );
  }

}
