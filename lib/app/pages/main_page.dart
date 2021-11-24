import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/icon_style.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../cubit/cubits.dart';
import '../custom_widgets/custom_widgets.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pages.dart';

typedef RepositoryCallback = void Function(Repository repository, String name);
typedef ShareRepositoryCallback = void Function();
typedef MoveEntryCallback = void Function(String origin, String path, EntryType type);
typedef MoveEntryBottomSheetControllerCallback = void Function(PersistentBottomSheetController? controller, String entryPath);

class MainPage extends StatefulWidget {
  const MainPage({
    required this.defaultRepository,
    required this.defaultRepositoryName,
    required this.title,
  });

  final Repository? defaultRepository;
  final String defaultRepositoryName;
  final String title;
  
  @override
  State<StatefulWidget> createState() => _MainPageState(); 
}

class _MainPageState extends State<MainPage>
  with TickerProviderStateMixin {

  Repository? _repository;
  Subscription? _repositorySubscription;

  late Widget _mainState = Container();
    
  late StreamSubscription _intentDataStreamSubscription;
  late final SynchronizationCubit _syncingCubit;

  String _repositoryName = '';

  String _currentFolder = Strings.rootPath; // Initial value: /
  List<BaseItem> _folderContents = <BaseItem>[];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentBottomSheetController? _persistentBottomSheetController;
  String _pathEntryToMove = '';

  @override
  void initState() {
    super.initState();

    _syncingCubit = BlocProvider.of<SynchronizationCubit>(context);

    handleIncomingShareIntent();
    initRepository();
  }

  @override
  void dispose() {
    super.dispose();

    _repositorySubscription!.cancel();
    _intentDataStreamSubscription.cancel();
  }

  void handleIncomingShareIntent() {
    // For sharing files coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
        print("Shared:" + (value.map((f)=> f.path).join(",")));  
        _processIntent(value);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing files coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      print("Shared:" + (value.map((f)=> f.path).join(",")));  
      _processIntent(value);
    });
  }

  Future<void> _processIntent(List<SharedMediaFile> sharedMedia) async {
    if (sharedMedia.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return AddSharedFilePage(
          repository:  _repository!,
          sharedFileInfo: sharedMedia,
          directoryBloc: BlocProvider.of<DirectoryBloc>(context),
          directoryBlocPath: _currentFolder,
        );
      })
    );
  }

  void initRepository() {
    switchMainState(widget.defaultRepository == null
    ? _noRepositories()
    : _repositoryContentBuilder());

    BlocProvider.of<RepositoriesCubit>(context)
    .selectRepository(
      widget.defaultRepository,
      widget.defaultRepositoryName
    );
  }

  switchMainState(state) => setState(() { _mainState = state; });

  getContents({path, recursive = false, withProgress = false, isSyncing = false}) { 
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      GetContent(
        repository: _repository!,
        path: path,
        recursive: recursive,
        withProgress: withProgress,
        isSyncing: isSyncing
      )
    );
  }

  navigateToPath({type, origin, destination, withProgress = false}) {
    print('navigateToPath destination: $destination');
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      NavigateTo(
        repository: _repository!,
        type: type,
        origin: origin,
        destination: destination,
        withProgress: withProgress
      )
    ); 
  }

  updateRoute(destination) {
    BlocProvider.of<RouteBloc>(context)
    .add(
      UpdateRoute(
        path: destination,
        action: () { //Back button action, hence we invert the origin and destination values
          final from = destination;
          final backTo = extractParentFromPath(from);

          BlocProvider.of<DirectoryBloc>(context)
          .add(
            NavigateTo(
              repository: _repository!,
              type: Navigation.content,
              origin: from,
              destination: backTo,
              withProgress: true
            )
          );
        }
      )
    );
  }

  Future<void> refreshCurrent() async =>
    getContents(path: _currentFolder, withProgress: true);

  void subscribeToRepositoryNotifications(repository) async {
    _repositorySubscription = repository.subscribe(() { 
      _syncingCubit.syncing();
      getContents(path: _currentFolder, isSyncing: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _getOuiSyncBar(),
      body: _mainState,
      floatingActionButton: _getFAB(context),
    );
  }

  _getOuiSyncBar() => OuiSyncBar(
    appBranding: AppBranding(appName: widget.title),
    centralWidget: Container(), //SearchBar(), |removed until implemented
    actions: [
      Padding(
        padding: EdgeInsets.only(right: 10.0),
        child: buildActionIcon(
          icon: Icons.settings_outlined,
          onTap: () => settingsAction(
            BlocProvider.of<RepositoriesCubit>(context),
            BlocProvider.of<SynchronizationCubit>(context)
          ),
          size: 35.0
        ),
      )
    ],
    bottom: NavigationBar(
      repositoriesCubit: BlocProvider.of<RepositoriesCubit>(context),
      synchronizationCubit: BlocProvider.of<SynchronizationCubit>(context),
      onRepositorySelect: switchRepository,
      shareRepositoryOnTap: shareRepository,
    ),
    mode: BarMode.full,
    toolbarHeight: 200.0,
    preferredSize: Size.fromHeight(200.0)
  );

  StatelessWidget _getFAB(BuildContext context) {
    return _repository != null
    ? new FloatingActionButton(
      child: const Icon(Icons.add_rounded),
      onPressed: () => _showDirectoryActions(
        context, 
        BlocProvider.of<DirectoryBloc>(context), 
        _repository!, 
        _currentFolder
      ),
    )
    : Container();
  }

  void switchRepository(repository, name) {
    if (_repositorySubscription != null) {
      _repositorySubscription!.cancel();
      print('Repository subscription ${_repositorySubscription!.handle} closed');
    }

    if (_repository != null) {
      _repository!.close();
      print('Repository ${_repository!.handle} closed');
    }

    NativeChannels.setRepository(repository);

    _repository = repository;
    _repositoryName = name;

    switchMainState(_repositoryContentBuilder());

    navigateToPath(
      type: Navigation.content,
      origin: Strings.rootPath,
      destination: Strings.rootPath,
      withProgress: true
    );

    subscribeToRepositoryNotifications(_repository);
  }

  void shareRepository() async {
    if (_repository == null) {
      return;
    }

    final token = await _repository!.createShareToken(name: _repositoryName);
    print('Token for sharing repository $_repositoryName: $token');
    
    await _showShareRepository(context, _repositoryName, token);
  }

  _repositoryContentBuilder() => BlocConsumer<DirectoryBloc, DirectoryState>(
    buildWhen: (context, state) {
      return !(state is SyncingInProgress);
    },
    builder: (context, state) {
      if (state is DirectoryInitial) {
        return Center(child: Text('Loading contents...'));
      }

      if (state is DirectoryLoadInProgress) {
        return Center(child: CircularProgressIndicator());
      }

      if (state is DirectoryLoadSuccess) {
        if (state.path == _currentFolder) {
          return _selectLayoutWidget(isContentsEmpty: state.contents.isEmpty);  
        }
        return _selectLayoutWidget(isContentsEmpty: _folderContents.isEmpty);
      }
      
      if (state is NavigationLoadSuccess) {
        return _selectLayoutWidget(isContentsEmpty: state.contents.isEmpty);
      }

      if (state is DirectoryLoadFailure) {
        return _errorState();
      }

      if (state is NavigationLoadFailure) {
        return _errorState();
      }

      return Center(child: Text('Ooops!'));
    },
    listener: (context, state) {
      if (state is NavigationLoadSuccess) {
        if (state.type == Navigation.content) {
          setState(() { 
            _currentFolder = state.destination;
            print('Current path updated: $_currentFolder');
          });

          updateFolderContents(state.contents);
          updateRoute(state.destination);

          return;
        }
      }

      if (state is SyncingInProgress) {
        _syncingCubit.syncing();
        return;
      }

      if (state is DirectoryLoadSuccess) {
        if (state.isSyncing) {  
          _syncingCubit.done();

          if (state.path == _currentFolder) {
            updateFolderContents(state.contents);    
          }

          return;
        }

        updateFolderContents(state.contents);
        return;
      }

      if (state is DirectoryLoadFailure) {
        if (state.isSyncing) {
          _syncingCubit.failed();
        }

        return;
      }
    }
  );

  _selectLayoutWidget({isContentsEmpty}) {
    if (isContentsEmpty) {
      return _noContents();
    }

    return _contentsList();
  }

  Future<void> updateFolderContents(newContent) async {
    if (newContent.isEmpty) {
      if (_folderContents.isNotEmpty) {
          setState(() {
            _folderContents.clear();
          }); 
      }
      return;
    }

    final orderedContent = newContent as List<BaseItem>;
    orderedContent.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));
    
    if (!DeepCollectionEquality.unordered().equals(orderedContent, _folderContents)) {
        setState(() {
          _folderContents = orderedContent;
        });
    }
  }

  _errorState() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Align(
        alignment: Alignment.center,
        child: Text(
          Strings.messageOhOh,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.red
          ),
        ),
      ),
      SizedBox(height: 20.0),
      Align(
        alignment: Alignment.center,
        child: StyledText(
          text: Strings.messageErrorState,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Colors.red
          ),
          styles: {
            'bold': TextStyle(fontWeight: FontWeight.bold),
            'arrow_down': IconStyle(Icons.south),
          },
        ),
      ),
      SizedBox(height: 20.0),
      ElevatedButton(
        onPressed: refreshCurrent,
        child: Text('Reload')
      ),
    ],
  );

  _noRepositories() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Align(
        alignment: Alignment.center,
        child: Text(
          Strings.messageNoRepos,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      SizedBox(height: 20.0),
      Align(
        alignment: Alignment.center,
        child: StyledText(
          text: Strings.messageCreateNewRepoStyled,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal
          ),
          styles: {
            'bold': TextStyle(fontWeight: FontWeight.bold),
            'arrow_down': IconStyle(Icons.south),
          },
        ),
      ),
      SizedBox(height: 20.0),
      ElevatedButton(
        onPressed: () => createRepoDialog(BlocProvider.of<RepositoriesCubit>(context)),
        child: Text('Create a Repository')
      ),
    ],
  );

  _noContents() => RefreshIndicator(
      onRefresh: refreshCurrent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              _currentFolder.isEmpty
              ? Strings.messageEmptyRepo
              : Strings.messageEmptyFolder,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Align(
            alignment: Alignment.center,
            child: StyledText(
              text: Strings.messageCreateAddNewItemStyled,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal
              ),
              styles: {
                'bold': TextStyle(fontWeight: FontWeight.bold),
                'arrow_down': IconStyle(Icons.south),
              },
            ),
          ),
        ],
      )
    );

  _contentsList() => RefreshIndicator(
    onRefresh: refreshCurrent,
    child: ListView.separated(
      padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
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
              title: 'Moving entry',
              message: 'This function is not availabe when moving an entry'
            );
            return;
          }

          final fileSize = await EntryInfo(_repository!).fileLength(item.path);
          _showFileDetails(BlocProvider.of<DirectoryBloc>(context), item.name, item.path, fileSize);
        }
        : () {
          if (_persistentBottomSheetController != null &&
          _pathEntryToMove == item.path) {
            return;
          }

          navigateToPath(
            type: Navigation.content,
            origin: _currentFolder,
            destination: item.path,
            withProgress: true
          );
        };

        final listItem = ListItem (
          repository: _repository!,
          itemData: item,
          mainAction: actionByType,
          secondaryAction: () => {},
          filePopupMenu: _popupMenu(item),
          folderDotsAction: () async {
            if (_persistentBottomSheetController != null) {
              await Dialogs.simpleAlertDialog(
                context: context,
                title: 'Moving entry',
                message: 'This function is not availabe when moving an entry'
              );
              return;
            }
            
            await _showFolderDetails(
              BlocProvider.of<DirectoryBloc>(context),
              removeParentFromPath(item.path),
              item.path
            );
          }
        );

        return listItem;
      }
    )
  );

  _popupMenu(item) => Dialogs
  .filePopupMenu(
    context,
    _repository!,
    BlocProvider. of<DirectoryBloc>(context),
    { 
      Strings.actionPreviewFile: item,
      Strings.actionShareFile: item,
      Strings.actionDeleteFile: item 
    }
  );

  Future<dynamic> _showShareRepository(context, repositoryName, token) => showModalBottomSheet(
    isScrollControlled: true,
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    ),
    builder: (context) {
      return ShareRepository(
        repositoryName: repositoryName,
        token: token,
      );
    }
  );

  Future<dynamic> _showFileDetails(bloc, name, path, size) => showModalBottomSheet(
    isScrollControlled: true,
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    ),
    builder: (context) {
      return FileDetail(
        context: context,
        bloc: bloc,
        repository: _repository!,
        name: name,
        path: path,
        parent: extractParentFromPath(path),
        size: size,
        scaffoldKey: _scaffoldKey,
        onBottomSheetOpen: retrieveBottomSheetController,
        onMoveEntry: moveEntry
      );
    }
  );

  Future<dynamic> _showFolderDetails(bloc, name, path) => showModalBottomSheet(
    isScrollControlled: true,
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    ),
    builder: (context) {
      return FolderDetail(
        context: context,
        bloc: bloc,
        repository: _repository!,
        name: name,
        path: path,
        parent: extractParentFromPath(path),
        scaffoldKey: _scaffoldKey,
        onBottomSheetOpen: retrieveBottomSheetController,
        onMoveEntry: moveEntry
      );
    }
  );

  void retrieveBottomSheetController(PersistentBottomSheetController? controller, String entryPath) {
    _persistentBottomSheetController = controller;
    _pathEntryToMove = entryPath;
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
        newDestinationPath: newDestinationPath,
        navigate: false
      )
    );
  }

  Future<dynamic> _showDirectoryActions(context, bloc, repository, parent) => showModalBottomSheet(
    isScrollControlled: true,
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
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
          title: 'Create Repository',
          body: RepositoryCreation(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((newRepository) {
      if (newRepository.isNotEmpty) { // If a folder is created, the new folder is returned path; otherwise, empty string.
        switchMainState(_repositoryContentBuilder());
      }
    });
  }

  void settingsAction(reposCubit, syncCubit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SettingsPage(
          repositoriesCubit: reposCubit,
          synchronizationCubit: syncCubit,
          onRepositorySelect: switchRepository,
          title: 'Settings',
          currentRepository: _repository,
          currentRepositoryName: _repositoryName,
        );
      })
    );
  }

}
