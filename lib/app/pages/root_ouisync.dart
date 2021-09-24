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
import '../controls/bars/app_branding.dart';
import '../controls/bars/ouisync_bar.dart';
import '../controls/bars/repository_picker.dart';
import '../controls/bars/route_bar.dart';
import '../controls/controls.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pages.dart';

class RootOuiSync extends StatefulWidget {
  const RootOuiSync({
    required this.repository,
    required this.path,
    required this.title,
  });

  final Repository repository;
  final String path;
  final String title;
  
  @override
  State<StatefulWidget> createState() => _RootOuiSyncState(); 
}

class _RootOuiSyncState extends State<RootOuiSync>
  with TickerProviderStateMixin {
    
  late StreamSubscription _intentDataStreamSubscription;
  late final Subscription _repositorySubscription;

  List<BaseItem> _folderContents = <BaseItem>[];
  String _currentFolder = slash; // Initial value: /

  late AnimationController _actionsController;
  late AnimationController _syncController;
  
  late Color backgroundColor;
  late Color foregroundColor;

  @override
  void initState() {
    super.initState();

    handleIncomingShareIntent();
    initAnimationControllers();

    navigateToPath(
      type: Navigation.content,
      origin: slash,
      destination: slash,
      withProgress: true
    ); 

    getContents(path: slash, withProgress: true);
  }

  @override
  void dispose() {
    super.dispose();

    _repositorySubscription.cancel();
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
        return ReceiveSharingIntentPage(
          repository:  widget.repository,
          sharedFileInfo: sharedMedia,
          directoryBloc: BlocProvider.of<DirectoryBloc>(context),
          directoryBlocPath: widget.path,
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

  void subscribeToRepositoryNotifications(Repository repository) async {
    _repositorySubscription = repository.subscribe(() { 
      _syncController.repeat();

      getContents(
        path: _currentFolder,
        isSyncing: true
      );
    });
  }

  getContents({path, recursive = false, withProgress = false, isSyncing = false}) { 
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      GetContent(
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
      type: type,
      origin: origin,
      destination: destination,
      withProgress: withProgress
    )
  ); 

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).hintColor;
    foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: _getOuiSyncBar(),
      body: _getBody(),
      floatingActionButton: new FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showDirectoryActions(_currentFolder),
      ),
    );
  }

  _getOuiSyncBar() => OuiSyncBar(
    appBranding: AppBranding(appName: widget.title),
    defaultRepository: 'Default',
    centralWidget: RepositoryPicker(context: context, defaultRepository: 'Default'),
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

  Padding appBranding() { //AppBranding
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Center(
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w800
          ),),
      ),
    );
  }

  Row repositorySelector() { //RepositoryPicker
    return Row(
      children: [
        const Icon(
          Icons.layers_rounded,
          size: 30.0,
        ),
        SizedBox(width: 4.0),
        buildConstrainedText('Default', size: 20.0, softWrap: false, overflow: TextOverflow.fade),
        buildActionIcon(icon: Icons.keyboard_arrow_down_outlined, onTap: () async { await _showRepositorySelector('Default'); }),
      ],
    );
  }

  _getBody() => BlocConsumer<DirectoryBloc, DirectoryState>(
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

          BlocProvider.of<RouteBloc>(context)
          .add(
            UpdateRoute(
              path: state.destination,
              action: () { //Back button action, hence we invert the origin and destination values
                final from = state.destination;
                final backTo = extractParentFromPath(from);

                BlocProvider.of<DirectoryBloc>(context)
                .add(
                  NavigateTo(
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

  _noContents() => RefreshIndicator(
      onRefresh: refreshCurrent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              widget.path.isEmpty
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
              text: messageCreateAddNewObjectStyled,
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

  _contentsList() =>
  RefreshIndicator(
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
          _showFileDetails(item.name, item.path, fileSize);
        }
        : () => navigateToPath(
            type: Navigation.content,
            origin: _currentFolder,
            destination: item.path,
            withProgress: true
          );

        final listItem = ListItem (
          repository: widget.repository,
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
      file = await File.open(widget.repository, filePath);
      fileSize = await file.length;
    } catch (e) {
      print('Exception getting file $filePath size:\n${e.toString()}');
    } finally {
      file?.close();
    }

    return fileSize;
  }

  _popupMenu(item) => 
  Dialogs
  .filePopupMenu(
    context,
    BlocProvider. of<DirectoryBloc>(context),
    { 
      actionPreviewFile: item,
      actionShareFile: item,
      actionDeleteFile: item 
    }
  );

  Future<dynamic> _showFileDetails(name, path, size) => showModalBottomSheet(
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
        name: name,
        path: path,
        size: size
      );
    }
  );

  Future<dynamic> _showFolderDetails(name, path) =>
  showModalBottomSheet(
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


  Future<dynamic> _showRepositorySelector(current) => showModalBottomSheet(
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
      return RepositoryList(current: 'Default');
    }
  );

  Future<dynamic> _showDirectoryActions(parent) => showModalBottomSheet(
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
        folderAction: createFolderDialog,
        fileAction: () async { await addFile(); },
      );
    }
  );

  void createFolderDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: 'Create Folder',
          body: FolderCreation(
            context: context,
            bloc: BlocProvider.of<DirectoryBloc>(context),
            updateUI: () {},
            path: _currentFolder,
            formKey: formKey,
          ),
        );
      }
    );
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
          parentPath: _currentFolder,
          newFilePath: newFilePath,
          fileByteStream: fileByteStream
        )
      );

      Navigator.of(context).pop();
      getContents(path: _currentFolder, withProgress: true);
    }
  }

  void settingsAction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return Settings(
          selectedRepository: 'Default',
          repository: widget.repository,
        );
      })
    );
  }
}
