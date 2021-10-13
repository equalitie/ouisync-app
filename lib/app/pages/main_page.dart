import 'dart:async';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/icon_style.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../cubit/cubits.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pages.dart';

typedef RepositoryCallback = void Function(Repository repository, String name);

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
  String _repositoryName = '';
  Subscription? _repositorySubscription;

  Widget? _mainState;
    
  late StreamSubscription _intentDataStreamSubscription;

  List<BaseItem> _folderContents = <BaseItem>[];
  String _currentFolder = slash; // Initial value: /

  late AnimationController _actionsController;
  late AnimationController _syncController;
  
  // late Color backgroundColor;
  // late Color foregroundColor;

  @override
  void initState() {
    super.initState();

    handleIncomingShareIntent();
    initAnimationControllers();

    initRepository();
  }

  @override
  void dispose() {
    super.dispose();

    _repositorySubscription!.cancel();
    _intentDataStreamSubscription.cancel();
    
    _actionsController.dispose();
    _syncController.dispose();
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

  initAnimationControllers() {
    _actionsController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
    );

    _syncController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: syncAnimationDuration)
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

  navigateToPath({type, origin, destination, withProgress = false}) =>
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

  void subscribeToRepositoryNotifications(repository) async {
    _repositorySubscription = repository.subscribe(() { 
      getContents(path: slash, isSyncing: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getOuiSyncBar(),
      body: _mainState,
      floatingActionButton: new FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(BlocProvider.of<DirectoryBloc>(context), _currentFolder),
      ),
    );
  }

  _getOuiSyncBar() => OuiSyncBar(
    appBranding: AppBranding(appName: widget.title),
    centralWidget: RepositoryPicker(
      cubit: BlocProvider.of<RepositoriesCubit>(context),
      onRepositorySelect: (repository, name) {
        if (_repositorySubscription != null) {
          _repositorySubscription!.cancel();
        }

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
      },
    ),
    actions: [
      Padding(
        padding: EdgeInsets.only(right: 10.0),
        child: buildActionIcon(icon: Icons.settings_outlined, onTap: settingsAction, size: 35.0),
      )
    ],
    bottom: RouteBar(animationController: _syncController),
    mode: BarMode.full,
    toolbarHeight: 150.0,
    preferredSize: Size.fromHeight(150.0)
  );

  _repositoryContentBuilder() => BlocConsumer<DirectoryBloc, DirectoryState>(
    builder: (context, state) {
      if (state is DirectoryInitial) {
        return Center(child: Text('Loading contents...'));
      }

      if (state is SyncingInProgress) {
        return loadContents(_folderContents);
      }

      if (state is DirectoryLoadInProgress) {
        return Center(child: CircularProgressIndicator());
      }

      if (state is DirectoryLoadSuccess) {
        return loadContents(state.contents);
      }
      
      if (state is NavigationLoadSuccess) {
        return loadContents(state.contents);
      }

      if (state is DirectoryLoadFailure) {
        return Text(
          'Something went wrong!',
          style: TextStyle(color: Colors.red),
        );
      }

      if (state is NavigationLoadFailure) {
        return Text(
          'Something went wrong in navigation',
          style: TextStyle(color: Colors.red),
        );
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
        }
      }

      if (state is SyncingInProgress) {
        _syncController.repeat();
      }

      if (state is DirectoryLoadSuccess) {
        updateFolderContents(state.contents);

        if (state.isSyncing) {  
          _syncController.stop();  
        }
      }

      if (state is DirectoryLoadFailure) {
        if (state.isSyncing) {
          _syncController.stop();  
        }
      }
    }
  );

  loadContents(contents) {
    if (contents.isEmpty) {
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

  void updateRoute(destination) {
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
      ElevatedButton(
        onPressed: () {
          
        },
        child: Text('Link a Lockbox')
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
              removeParentFromPath(item.path),
              item.path
            )
        );

        return listItem;
      }
    )
  );

  Future<void> refreshCurrent() async =>
    getContents(path: _currentFolder, withProgress: true);

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
      );
    }
  );

  Future<dynamic> _showFolderDetails(name, path) => showModalBottomSheet(
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
        name: name,
        path: path,
        renameAction: () {
          // ignore: todo
          // TODO: Check if available in the library and implement
        },
        deleteAction: () async {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              final parent = extractParentFromPath(_currentFolder);

              return Dialogs.buildDeleteFolderAlertDialog(
                context,
                BlocProvider.of<DirectoryBloc>(context),
                getContents(path: parent, withProgress: true),
                extractParentFromPath(path),
                path,
              );
            },
          );

          if (result ?? false) {
            Navigator.of(context).pop(false);
          }
        },
      );
    }
  );

  Future<dynamic> _showDirectoryActions(bloc, parent) => showModalBottomSheet(
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
        parent: parent,
        folderAction: () => createFolderDialog(bloc),
        fileAction: () async { await addFile(); },
      );
    }
  );

  void createFolderDialog(bloc) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: 'Create Folder',
          body: FolderCreation(
            context: context,
            bloc: bloc,
            repository: _repository!,
            path: _currentFolder,
            formKey: formKey,
          ),
        );
      }
    ).then((newFolder) => {
      if (newFolder.isNotEmpty) { // If a folder is created, the new folder is returned path; otherwise, empty string.
        Navigator.of(this.context).pop() 
      }
    });
  }

  Future<void> addFile() async {
    final result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.any,
      withReadStream: true
    );

    if(result != null) {
      final newFilePath = _currentFolder == '/'
      ? '/${result.files.single.name}'
      : '$_currentFolder/${result.files.single.name}';
      
      final fileByteStream = result.files.single.readStream!;
      BlocProvider.of<DirectoryBloc>(context)
      .add(
        CreateFile(
          repository: _repository!,
          parentPath: _currentFolder,
          newFilePath: newFilePath,
          fileByteStream: fileByteStream
        )
      );

      Navigator.of(context).pop();
      getContents(path: _currentFolder, withProgress: true);
    }
  }

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
          selectedRepository: 'Default',
          repository: _repository!,
        );
      })
    );
  }
}
