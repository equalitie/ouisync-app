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
typedef RetrieveBottomSheetControllerCallback = void Function(PersistentBottomSheetController? controller);

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

  Widget? _mainState;
    
  late StreamSubscription _intentDataStreamSubscription;
  late final SynchronizationCubit _syncingCubit;

  String _repositoryName = '';

  String _currentFolder = slash; // Initial value: /
  List<BaseItem> _folderContents = <BaseItem>[];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _persistentBottomSheetController;

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
        child: buildActionIcon(icon: Icons.settings_outlined, onTap: settingsAction, size: 35.0),
      )
    ],
    bottom: NavigationBar(
      cubitRepositories: BlocProvider.of<RepositoriesCubit>(context),
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
      origin: slash,
      destination: slash,
      withProgress: true
    );

    subscribeToRepositoryNotifications(_repository);
  }

  void shareRepository() {
    if (_repository == null) {
      print('No repository selected');
      return;  
    }

    print('Share repository $_repository tapped');
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
          messageOhOh,
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
          text: messageErrorState,
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
          messageNoRepos,
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
          text: messageCreateNewRepoStyled,
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
        child: Text('Create a Lockbox')
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
              ? messageEmptyRepo
              : messageEmptyFolder,
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
              text: messageCreateAddNewItemStyled,
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
          final fileSize = await _fileSize(item.path);
          _showFileDetails(BlocProvider.of<DirectoryBloc>(context), item.name, item.path, fileSize);
        }
        : () => navigateToPath(
            type: Navigation.content,
            origin: _currentFolder,
            destination: item.path,
            withProgress: true
          );

        final listItem = ListItem (
          repository: _repository!,
          itemData: item,
          mainAction: actionByType,
          secondaryAction: () => {},
          filePopupMenu: _popupMenu(item),
          folderDotsAction: () async =>
            await _showFolderDetails(
              BlocProvider.of<DirectoryBloc>(context),
              removeParentFromPath(item.path),
              item.path
            )
        );

        return listItem;
      }
    )
  );

  Future<int> _fileSize(String filePath) async {
    int fileSize = 0;
    File? file;

    try {
      file = await File.open(_repository!, filePath);
      fileSize = await file.length;
    } catch (e) {
      print('Exception getting file $filePath size:\n${e.toString()}');
    } finally {
      file?.close();
    }

    return fileSize;
  }

  _popupMenu(item) => Dialogs
  .filePopupMenu(
    context,
    _repository!,
    BlocProvider. of<DirectoryBloc>(context),
    { 
      actionPreviewFile: item,
      actionShareFile: item,
      actionDeleteFile: item 
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

  void retrieveBottomSheetController(PersistentBottomSheetController? controller) {
    _persistentBottomSheetController = controller;
  }

  void moveEntry(origin, path, type) async {
    final alertTitle = 'Moving ${type == EntryType.directory ? 'folder' : 'file'}';

    if (origin == _currentFolder) {
      await Dialogs.simpleAlertDialog(
        context: context,
        title: alertTitle,
        message: 'The destination can\'t be the same as the origin'
      );
      return;
    }

    final entryName = removeParentFromPath(path);
    final newDestinationPath = _currentFolder == slash
    ? '/$entryName'
    : '$_currentFolder/$entryName';

    final List<Widget> alertBody = _getMoveEntryBody(
      name: entryName,
      origin: origin,
      destination: _currentFolder,
      type: type);

    final List<Widget> alertActions = _getMoveEntryActions(context);

    final result = await Dialogs.alertDialogWithActions(
      context: context,
      title: alertTitle,
      body: alertBody,
      actions: alertActions
    );
    if (result ?? false) {
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
  }

  List<Widget> _getMoveEntryBody({name, origin, destination, type}) => [
    Text(
      name,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold
      ),
    ),
    const SizedBox(height: 10.0,),
    Text(
      'From: $origin',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold
      ),
    ),
    const SizedBox(height: 5.0,),
    Text(
      'To: $destination',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold
      ),
    ),
    const SizedBox(height: 30.0,),
    Text('Are you sure you want to move this ${type == EntryType.directory ? 'folder' : 'file'} here?')
  ];

  List<Widget> _getMoveEntryActions(context) => [
    TextButton(
      child: const Text('ACCEPT'),
      onPressed: () => Navigator.of(context).pop(true),
    ),
    TextButton(
      child: const Text('CANCEL'),
      onPressed: () => Navigator.of(context).pop(false),
    ),
  ];


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
          title: 'Create Lockbox',
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

  void settingsAction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SettingsPage(
          selectedRepository: _repositoryName,
          repository: _repository!,
        );
      })
    );
  }
}
