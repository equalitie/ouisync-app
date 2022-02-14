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

typedef RepositoryCallback = void Function(Repository? repository, String name);
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

    Repository? _repository;
    Subscription? _repositorySubscription;

    String _repositoryName = '';
    String _currentFolder = Strings.rootPath; // Initial value: /
  
    List<BaseItem> _folderContents = <BaseItem>[];
    
    SynchronizationCubit? _syncingCubit;
    
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    String _pathEntryToMove = '';
    PersistentBottomSheetController? _persistentBottomSheetController;

    Widget _mainState = Container();

    final double defaultBottomPadding = kFloatingActionButtonMargin + Dimensions.paddingBottomWithFloatingButtonExtra;
    late ValueNotifier<double> _bottomPaddingWithBottomSheet;

    @override
    void initState() {
      super.initState();
      
      initMainPage();

      widget.intentStream
      .listen((listOfMedia) {
        _intentPayload = listOfMedia;
        handleShareIntentPayload(widget.defaultRepositoryName, _intentPayload);
      });
    }

    @override
    void dispose() {
      _repositorySubscription?.cancel();
      _repository?.close();
  
      super.dispose();
    }

    void initMainPage() async {
      _bottomPaddingWithBottomSheet = ValueNotifier<double>(defaultBottomPadding);
      
      _syncingCubit = BlocProvider
      .of<SynchronizationCubit>(context);

      initMainPageLayout(widget.defaultRepositoryName);
    }

    void initMainPageLayout(String repositoryName) {
      switchMainState(newState:
        repositoryName.isEmpty
        ? _noRepositoriesState()
        : LockedRepositoryState(
          repositoryName: repositoryName,
          onUnlockPressed: unlockRepositoryDialog
        )
      );

      _repositoryName = repositoryName;

      BlocProvider
      .of<RepositoriesCubit>(context)
      .selectRepository(
        _repository,
        _repositoryName
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

      if (repositoryName.isEmpty) {
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
      required Navigation type,
      required String origin,
      required String destination,
      bool withProgress = false
    }) {
      BlocProvider
      .of<DirectoryBloc>(context)
      .add(NavigateTo(
        repository: repository,
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

    void subscribeToRepositoryNotifications({
      required Repository repository
    }) {
      _repositorySubscription = repository
      .subscribe(syncCurrentFolder);
    }

    void syncCurrentFolder() { 
      _syncingCubit?.syncing();
    
      getContents(
        repository: _repository!,
        path: _currentFolder,
        isSyncing: true
      );

      print('[Syncing] Current folder: $_currentFolder');
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: _buildOuiSyncBar(repository: _repository),
        body: _mainState,
        floatingActionButton: _buildFAB(context,
          repository: _repository,
          path: _currentFolder
        ),
      );
    }

    _buildOuiSyncBar({required Repository? repository}) => OuiSyncBar(
      leadingAppBranding: null,
      titleCentralWidget: _buildRepositoriesBar(),
      actionList: _buildActionList(repository),
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

    List<Widget> _buildActionList(Repository? repository) => [
      Container(
        child: Fields.actionIcon(
          const Icon(Icons.settings_outlined),
          onPressed: () async {
            bool dhtStatus = await repository?.isDhtEnabled() ?? false;
            
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

    StatelessWidget _buildFAB(BuildContext context,
    {
      required Repository? repository,
      required String path
    }) {
      return repository != null
      ? new FloatingActionButton(
        heroTag: Constants.heroTagMainPageActions,
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(
          context, 
          BlocProvider.of<DirectoryBloc>(context), 
          repository, 
          path
        ),
      )
      : Container();
    }

    void switchRepository(Repository? repository, String name) {
      if (_repositorySubscription != null) {
        _repositorySubscription!.cancel();
        _repositorySubscription = null;

        print('Repository subscription closed');
      }

      _repository = repository;
      _repositoryName = name;

      NativeChannels.setRepository(_repository);  

      if (_repository == null) {
        initMainPageLayout(_repositoryName);

        return;
      }

      print('Saving repository: $_repositoryName');
      _repositoriesSession.put(_repositoryName, _repository!);
      print('Repositories in memory: ${_repositoriesSession.repositories.keys}');

      switchMainState(newState: _repositoryContentBuilder());

      navigateToPath(
        repository: _repository!,
        type: Navigation.content,
        origin: Strings.rootPath,
        destination: Strings.rootPath,
        withProgress: true
      );

      subscribeToRepositoryNotifications(
        repository: _repository!,
      );
    }

    void shareRepository() async {
      if (_repository == null) {
        return;
      }
      
      await _showShareRepository(context, repository: _repository!, repositoryName: _repositoryName);
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
              repository: _repository!,
              path: _currentFolder,
              isContentsEmpty: state.contents.isEmpty
            );  
          }
          return _selectLayoutWidget(
            repository: _repository!,
            path: _currentFolder,
            isContentsEmpty: _folderContents.isEmpty
          );
        }
        
        if (state is NavigationLoadSuccess) {
          return _selectLayoutWidget(
            repository: _repository!,
            path: _currentFolder,
            isContentsEmpty: state.contents.isEmpty
          );
        }

        if (state is DirectoryLoadFailure) {
          return _errorState(
            message: Strings.messageErrorState,
            actionReload: () => refreshCurrent(repository: _repository!, path: _currentFolder)
          );
        }

        if (state is NavigationLoadFailure) {
          return _errorState(
            message: Strings.messageErrorState,
            actionReload: () => refreshCurrent(repository: _repository!, path: _currentFolder)
          );
        }

        return _errorState(
          message: Strings.messageErrorLoadingContents,
          actionReload: () => refreshCurrent(repository: _repository!, path: _currentFolder)
        );
      },
      listener: (context, state) {
        if (state is NavigationLoadSuccess) {
          if (state.type == Navigation.content) {
            
            print('Current path updated: $_currentFolder, ${state.contents.length} entries');

            updateCurrentFolder(path: state.destination);
            updateFolderContents(newContent: state.contents);
            updateRoute(
              repository: _repository!,
              destination: state.destination
            );

            return;
          }
        }

        if (state is SyncingInProgress) {
          _syncingCubit?.syncing();
          return;
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
      required Repository repository,
      required String path,
      required bool isContentsEmpty
    }) {
      if (isContentsEmpty) {
        return _noContents(repository: repository, path: path);
      }

      return _contentsList(repository: repository, path: path);
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
                  size: 34.0,
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
        repository: _repository!,
        origin: origin,
        destination: _currentFolder,
        entryPath: path,
        newDestinationPath: newDestinationPath
      )
    );
  }

  void saveSharedMedia() async {
    if (_repository == null) {
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
        repository: _repository!,
        newFilePath: filePath,
        fileName: fileName,
        length: length,
        fileByteStream: fileByteStream
      )
    );

    Navigator.of(context).pop();
  }

  Future<dynamic> _showDirectoryActions(context, bloc, repository, parent) => showModalBottomSheet(
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
      if (newRepository.isNotEmpty) { // If a repository is created, the new repository name is returned; otherwise, empty string.
        switchMainState(newState: _repositoryContentBuilder());
      }
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
        BlocProvider.of<RepositoriesCubit>(context)
        .openRepository(
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
          title: Strings.titleSettings,
          currentRepository: _repository,
          currentRepositoryName: _repositoryName,
          dhtStatus: dhtStatus,
        );
      })
    );
  }

}
