import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../bloc/blocs.dart';
import '../cubit/cubits.dart';
import '../custom_widgets/custom_widgets.dart';
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

    RepositoriesService _repositoriesSession = RepositoriesService();

    List<SharedMediaFile> _intentPayload = <SharedMediaFile>[];

    String _currentFolder = Strings.rootPath; // Initial value: /
  
    List<BaseItem> _folderContents = <BaseItem>[];
    
    SynchronizationCubit? _syncingCubit;
    
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    String _pathEntryToMove = '';
    PersistentBottomSheetController? _persistentBottomSheetController;

    Widget _mainState = LoadingMainPageState();

    final double defaultBottomPadding = kFloatingActionButtonMargin + Dimensions.paddingBottomWithFloatingButtonExtra;
    ValueNotifier<double> _bottomPaddingWithBottomSheet = ValueNotifier<double>(0.0);

    @override
    void initState() {
      super.initState();
      
      _repositoriesSession
      .setSubscriptionCallback(_syncCurrentFolder);

      _initRepositories()
      .then((_) {
        initMainPage();
      });

      widget.intentStream
      .listen((listOfMedia) {
        _intentPayload = listOfMedia;
        handleShareIntentPayload(widget.defaultRepositoryName, _intentPayload);
      });
    }

    @override
    void dispose() {
      // TODO: dispose all repositories

      super.dispose();
    }

    Future<void> _initRepositories() async {
      final repositoriesCubit = BlocProvider
      .of<RepositoriesCubit>(context);

      final repositoriesInitTasks = RepositoryHelper
      .localRepositoriesFiles(
        widget.repositoriesLocation,
        justNames: true
      ).map((repositoryName) => 
        initializeRepository(repositoriesCubit, repositoryName as String)
      ).toList();

      final persistedRepositories = await Future
      .wait(repositoriesInitTasks);

      if (persistedRepositories.isEmpty) {
        return;
      }

      _repositoriesSession.repositories
      .addAll(persistedRepositories);

      _repositoriesSession
      .setCurrent(widget.defaultRepositoryName);  
    }

    Future<PersistedRepository> initializeRepository(
      RepositoriesCubit cubit,
      String repositoryName
    ) async {
      final initRepo = await cubit.initRepository(repositoryName);
      return PersistedRepository(repository: initRepo!, name: repositoryName);
    }

    void initMainPage() async {
      _syncingCubit = BlocProvider
      .of<SynchronizationCubit>(context);

      BlocProvider
      .of<RepositoriesCubit>(context)
      .selectRepository(
        _repositoriesSession.current?.repository,
        _repositoriesSession.current?.name ?? ''
      );
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
      String repositoryName,
      List<SharedMediaFile> payload
    ) {
      if (_intentPayload.isEmpty) {
        return;
      }

      if (!_repositoriesSession.hasCurrent) {
        Fluttertoast
        .showToast(msg: Strings.messageNoRepo, toastLength: Toast.LENGTH_LONG);

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
      bool recursive = false,
      bool withProgress = false,
      bool isSyncing = false
    }) { 
      BlocProvider
      .of<DirectoryBloc>(context)
      .add(GetContent(
        repository: repository,
        path: path,
        recursive: recursive,
        withProgress: withProgress,
        isSyncing: isSyncing
      ));
    }

    navigateToPath({
      required Repository repository,
      AccessMode? previousAccessMode,
      required Navigation type,
      required String origin,
      required String destination,
      bool withProgress = false
    }) {
      BlocProvider
      .of<DirectoryBloc>(context)
      .add(NavigateTo(
        repository: repository,
        previousAccesMode: previousAccessMode,
        type: type,
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
            type: Navigation.content,
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
      withProgress: true
    );

    void _syncCurrentFolder(String repositoryName) { 
      if (!_repositoriesSession.hasCurrent) {
        return;
      }

      if (_repositoriesSession.current!.name != repositoryName) {
        print('[Syncing $repositoryName in background] (Current: ${_repositoriesSession.current!.repository.handle})');
        return;
      }

      _syncingCubit?.syncing();
    
      getContents(
        repository: _repositoriesSession.current!.repository,
        path: _currentFolder,
        isSyncing: true
      );

      print('[Syncing $repositoryName (${_repositoriesSession.current!.repository.handle})] Current folder: $_currentFolder');
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
        floatingActionButton: _buildFAB(context,
        ),
      );
    }

    Future<bool> _onBackPressed() async {
      if (_currentFolder == Strings.rootPath) {
        final closeApp = await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(Strings.titleExitOuiSync),
            content: new Text(Strings.messageExitOuiSync),
            actions: <Widget>[
              TextButton(
                child: const Text(Strings.actionAcceptCapital),
                onPressed: () {
                  Navigator.of(context).pop(true);
                }
              ),
              TextButton(
                child: const Text(Strings.actionCancelCapital),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }
              )
            ],
          ),
        );

        return closeApp;
      }

      if (_repositoriesSession.hasCurrent) {
        final parent = extractParentFromPath(_currentFolder);

        BlocProvider
        .of<DirectoryBloc>(context)
        .add(NavigateTo(
          repository: _repositoriesSession.current!.repository,
          type: Navigation.content,
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
            bool dhtStatus = await _repositoriesSession.current?.repository.isDhtEnabled() ?? false;
            
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
      return _repositoriesSession.hasCurrent
      ? new FloatingActionButton(
        heroTag: Constants.heroTagMainPageActions,
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(
          context, 
          bloc: BlocProvider.of<DirectoryBloc>(context), 
          repository: _repositoriesSession.current!.repository, 
          parent: _currentFolder
        ),
      )
      : Container();
    }

    void switchRepository(Repository? repository, String name, AccessMode? previousAccessMode) {
      NativeChannels.setRepository(repository); 

      if (repository == null) {
        switchMainState(newState:
          _noRepositoriesState()
        );
        return;
      }

      _repositoriesSession.put(name, repository, isCurrent: true);
    
      print('Repositories in memory: ${_repositoriesSession.repositories}');
      print('Current repository: ${_repositoriesSession.current}');

      switchMainState(newState: _repositoryContentBuilder());

      navigateToPath(
        repository: _repositoriesSession.current!.repository,
        previousAccessMode: previousAccessMode,
        type: Navigation.content,
        origin: Strings.rootPath,
        destination: Strings.rootPath,
        withProgress: true
      );
    }

    void shareRepository() async {
      if (!_repositoriesSession.hasCurrent) {
        return;
      }
      
      await _showShareRepository(context,
        repository: _repositoriesSession.current!.repository,
        repositoryName: _repositoriesSession.current!.name
      );
    }

    _repositoryContentBuilder() => BlocConsumer<DirectoryBloc, DirectoryState>(
      buildWhen: (context, state) {
        return !(state is SyncingInProgress ||
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
              persistedRepo: _repositoriesSession.current!,
              path: _currentFolder,
              isContentsEmpty: state.contents.isEmpty
            );  
          }
          return _selectLayoutWidget(
            persistedRepo: _repositoriesSession.current!,
            path: _currentFolder,
            isContentsEmpty: _folderContents.isEmpty
          );
        }
        
        if (state is NavigationLoadSuccess) {
          return _selectLayoutWidget(
            persistedRepo: _repositoriesSession.current!,
            path: _currentFolder,
            isContentsEmpty: state.contents.isEmpty
          );
        }

        if (state is NavigationLoadBlind) {
          return _selectLayoutWidget(
            persistedRepo: _repositoriesSession.current!,
            path: '',
            isContentsEmpty: true,
            isBlind: true
          ); 
        }

        if (state is DirectoryLoadFailure) {
          return _errorState(
            message: Strings.messageErrorState,
            actionReload: () => refreshCurrent(
              repository: _repositoriesSession.current!.repository,
              path: _currentFolder
            )
          );
        }

        if (state is NavigationLoadFailure) {
          return _errorState(
            message: Strings.messageErrorState,
            actionReload: () => refreshCurrent(
              repository: _repositoriesSession.current!.repository,
              path: _currentFolder
            )
          );
        }

        return _errorState(
          message: Strings.messageErrorLoadingContents,
          actionReload: () => refreshCurrent(
            repository: _repositoriesSession.current!.repository,
            path: _currentFolder
          )
        );
      },
      listener: (context, state) {
        if (state is NavigationLoadSuccess) {
          if (state.type == Navigation.content) {
            
            print('Current path updated: $_currentFolder, ${state.contents.length} entries');

            updateCurrentFolder(path: state.destination);
            updateFolderContents(newContent: state.contents);
            updateRoute(
              repository: _repositoriesSession.current!.repository,
              destination: state.destination
            );

            return;
          }
        }

        if (state is SyncingInProgress) {
          _syncingCubit?.syncing();
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
                    onPressed: () => 
                    Navigator.of(context).pop(),
                  )
                ],
              );
            }); 
          }
        }

        if (state is CreateFileDone) {
          Fluttertoast.showToast(msg:
            Strings
            .messageNewFile
            .replaceAll(
              Strings.replacementName,
              state.path
            )
          );
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

        if (state is WriteToFileInProgress) {
          Fluttertoast.showToast(msg:
            Strings
            .messageWritingFile
            .replaceAll(
              Strings.replacementName,
              state.fileName
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

        if (state is DirectoryLoadSuccess) {
          if (state.isSyncing) {  
            _syncingCubit?.done();

            if (state.path == _currentFolder) {
              updateFolderContents(newContent: state.contents as List<BaseItem>);    
            }

            return;
          }

          updateFolderContents(newContent: state.contents as List<BaseItem>);
          return;
        }

        if (state is DirectoryLoadFailure) {
          if (state.isSyncing) {
            _syncingCubit?.failed();
          }

          return;
        }
      }
    );

    _selectLayoutWidget({
      required PersistedRepository persistedRepo,
      required String path,
      required bool isContentsEmpty,
      bool isBlind = false
    }) {
      if (isBlind) {
        return LockedRepositoryState(
          repositoryName: persistedRepo.name,
          onUnlockPressed: unlockRepositoryDialog,
        );
      }
      
      if (isContentsEmpty) {
        return _noContents(
          repository: persistedRepo.repository,
          path: path
        );
      }

      return _contentsList(
        repository: persistedRepo.repository,
        path: path
      );
    }

    Future<void> updateFolderContents({required List<BaseItem> newContent}) async {
      if (newContent.isEmpty) {
        if (_folderContents.isNotEmpty) {
          setState(() { _folderContents.clear(); }); 
        }
        return;
      }

      final orderedContent = newContent;
      orderedContent.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));
      
      if (!DeepCollectionEquality.unordered().equals(orderedContent, _folderContents)) {
        setState(() {_folderContents  = orderedContent; });
      }
    }

    _errorState({
      required String message,
      required void Function()? actionReload
    }) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Fields.inPageMainMessage(
            Strings.messageOhOh,
            color: Colors.red,
            tags: {
              Constants.inlineTextColor: InlineTextStyles.color(Colors.black),
              Constants.inlineTextSize: InlineTextStyles.size(),
              Constants.inlineTextBold: InlineTextStyles.bold
            }
          )
        ),
        SizedBox(height: 10.0),
        Align(
          alignment: Alignment.center,
          child: Fields.inPageSecondaryMessage(
            message,
            tags: {
              Constants.inlineTextSize: InlineTextStyles.size(),
              Constants.inlineTextBold: InlineTextStyles.bold,
              Constants.inlineTextIcon: InlineTextStyles.icon(Icons.south)
            }
          )
        ),
        SizedBox(height: 20.0),
        Fields.inPageButton(
          onPressed: actionReload,
          text: Strings.actionReloadContents,
          autofocus: true
        )
      ],
    );

    _noRepositoriesState() => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Fields.inPageMainMessage(Strings.messageNoRepos),
        ),
        SizedBox(height: 10.0),
        Align(
          alignment: Alignment.center,
          child: Fields.inPageSecondaryMessage(
            Strings.messageCreateNewRepo,
            tags: { Constants.inlineTextBold: InlineTextStyles.bold }
          )
        ),
        SizedBox(height: 30.0),
        Fields.inPageButton(
          onPressed: () => createRepoDialog(BlocProvider.of<RepositoriesCubit>(context)),
          text: Strings.actionCreateRepository,
          size: Dimensions.sizeInPageButtonLong,
          autofocus: true
        ),
        SizedBox(height: 20.0),
        Fields.inPageButton(
          onPressed: () => addRepoWithTokenDialog(BlocProvider.of<RepositoriesCubit>(context)),
          text: Strings.actionAddRepositoryWithToken,
          size: Dimensions.sizeInPageButtonLong,
        ),
      ],
    );

    _noContents({
      required Repository repository,
      required String path
    }) => RefreshIndicator(
      onRefresh: () => refreshCurrent(repository: repository, path: path),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(
              path.isEmpty
              ? Strings.messageEmptyRepo
              : Strings.messageEmptyFolder,
            ),
          ),
          SizedBox(height: 10.0),
          Align(
            alignment: Alignment.center,
            child: Fields.inPageSecondaryMessage(
              Strings.messageCreateAddNewItem,
              tags: {
                Constants.inlineTextBold: InlineTextStyles.bold,
                Constants.inlineTextIcon: InlineTextStyles.icon(
                  Icons.add_circle,
                  size: Dimensions.sizeIconBig,
                  color: Theme.of(context).primaryColor
                )
              }
            ),
          ),
        ],
      )
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
            final actionByType = item.itemType == ItemType.file
            ? () async {
              if (_persistentBottomSheetController != null) {
                await Dialogs.simpleAlertDialog(
                  context: context,
                  title: Strings.titleMovingEntry,
                  message: Strings.messageMovingEntry
                );
                return;
              }

              final fileSize = await EntryInfo(repository).fileLength(item.path);
              _showFileDetails(
                repository: repository,
                directoryBloc: BlocProvider.of<DirectoryBloc>(context),
                scaffoldKey: _scaffoldKey,
                name: item.name,
                path: item.path,
                size: fileSize
              );
            }
            : () {
              if (_persistentBottomSheetController != null &&
              _pathEntryToMove == item.path) {
                return;
              }

              navigateToPath(
                repository: repository,
                type: Navigation.content,
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
              }
            );

            return listItem;
          }
        )
      )
    );

    _popupMenu({
      required Repository repository,
      required BaseItem data
    }) => Dialogs
    .filePopupMenu(
      context,
      repository,
      BlocProvider. of<DirectoryBloc>(context),
      { 
        Strings.actionPreviewFile: data,
        Strings.actionShareFile: data,
        Strings.actionDeleteFile: data 
      }
    );

    Future<dynamic> _showShareRepository(context,
    {
      required Repository repository,
      required String repositoryName
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
        return ShareRepository(
          repository: repository,
          repositoryName: repositoryName
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
        repository: _repositoriesSession.current!.repository,
        origin: origin,
        destination: _currentFolder,
        entryPath: path,
        newDestinationPath: newDestinationPath
      )
    );
  }

  void saveSharedMedia() async {
    if (!_repositoriesSession.hasCurrent) {
      Fluttertoast.showToast(msg: Strings.messageNoRepo);
      return;
    }

    SharedMediaFile? mediaInfo = _intentPayload.firstOrNull;
    if (mediaInfo == null) {
      Fluttertoast.showToast(msg: Strings.mesageNoMediaPresent);
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
        repository: _repositoriesSession.current!.repository,
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
    ).then((newRepository) {
      // if (newRepository.isNotEmpty) { // If a repository is created, the new repository name is returned; otherwise, empty string.
      //   switchMainState(newState: _repositoryContentBuilder());
      // }
    });
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
        final name = _repositoriesSession.current?.name;
        _repositoriesSession.remove(name!);

        BlocProvider.of<RepositoriesCubit>(context)
        .unlockRepository(
          name: repositoryName,
          password: password
        );
      }
    });
  }

  void settingsAction(reposCubit, dhtStatus) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SettingsPage(
          repositoriesCubit: reposCubit,
          onRepositorySelect: switchRepository,
          onShareRepository: shareRepository,
          title: Strings.titleSettings,
          dhtStatus: dhtStatus,
        );
      })
    );
  }

}
