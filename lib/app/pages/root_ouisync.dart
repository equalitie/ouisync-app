import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/icon_style.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
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

    subscribeToRepositoryNotifications(widget.repository);

    loadRoot(BlocProvider.of<NavigationBloc>(context));    
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
    final _debouncer = Debouncer(milliseconds: debouncerMiliseconds);
    _repositorySubscription = repository.subscribe(() => _runSync(_debouncer));
  }

  void _runSync(Debouncer _debouncer) {
    print('Starting synchronization [${DateTime.now()}]');
    _syncController.repeat();
    
    _debouncer.run(() {          
      print('Syncing [${DateTime.now()}]');
    
      updateUI(withProgress: false);
      _syncController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).hintColor;
    foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: _getAppBar(widget.title),
      body: _getBody(),
      floatingActionButton: _getFloatingButton(),
    );
  }

  _getAppBar(destinationPath) => AppBar(
    title: Text(widget.title),
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(30.0),
      child: Container(
        child: _getRouteBar(),
      ),
    ),
  );

  _getRouteBar() => BlocBuilder<RouteBloc, RouteState>(
    builder: (context, state) {
      if (state is RouteLoadSuccess) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0, bottom: 5.0, right: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: state.route,
                    ),
                    Expanded(
                      flex: 0,
                      child: SpinningIcon(
                        controller: _syncController,
                        icon: const Icon(
                          Icons.sync_rounded,
                          size: 30.0,
                        ),
                        onPressed: () => {},
                      )
                    ),
                  ],
                )
              )
            ],
          )
        );
      }

      return Container(
        child: Text('...')
      );
    }
  );

  _getBody() => BlocConsumer(
    bloc: BlocProvider.of<NavigationBloc>(context),
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

                BlocProvider.of<NavigationBloc>(context)
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
    },
    builder: (context, state) => _body(context, state)
  );

  Widget _body(context, state) {
    if (state is NavigationInitial) {
      return Center(child: Text('Loading contents...'));
    }

    if (state is NavigationLoadInProgress) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is NavigationLoadSuccess) {
      if (state.contents.isEmpty) {
        return _noContents();
      }

      final contents = state.contents;
      contents.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));

      return _contentsList();
    }

    if (state is NavigationLoadFailure) {
      return Text(
        'Something went wrong!',
        style: TextStyle(color: Colors.red),
      );
    }

    return Center(child: Text('Ooops!'));
  }

  _noContents() => RefreshIndicator(
      onRefresh: () async => updateUI.call(),
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
    onRefresh: () async => updateUI.call(),
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
        : () {
          BlocProvider.of<NavigationBloc>(context)
          .add(
            NavigateTo(
              type: Navigation.content,
              origin: _currentFolder,
              destination: item.path,
              withProgress: true
            )
          );
        };

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
    { actionDeleteFile: item }
  );

  Future<void> updateFolderContents(items) async {
    if (items.isEmpty) {
      if (_folderContents.isNotEmpty) {
          setState(() {
            _folderContents.clear();
          }); 
      }
      return;
    }

    final contents = items as List<BaseItem>;
    contents.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));
    
    if (!DeepCollectionEquality.unordered().equals(contents, _folderContents)) {
        setState(() {
          _folderContents = contents;
        });
    }
  }

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
          widget.repository.move('/one', '/uno');
          updateUI(withProgress: true);
        },
        deleteAction: () async {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {

              return Dialogs.buildDeleteFolderAlertDialog(
                context,
                BlocProvider.of<DirectoryBloc>(context),
                updateUI,
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

  Widget _getFloatingButton() => Dialogs.floatingActionsButtonMenu(
    context,
    BlocProvider.of<DirectoryBloc>(context),
    updateUI,
    _actionsController,
    _currentFolder,
    folderActions,
    flagFolderActionsDialog,
    backgroundColor,
    foregroundColor
  );

  void updateUI({bool withProgress = true}) {
    final origin = extractParentFromPath(_currentFolder);
    final destination = _currentFolder;

    BlocProvider.of<NavigationBloc>(context)
    .add(
      NavigateTo(
        type: Navigation.content,
        origin: origin,
        destination: destination,
        withProgress: withProgress
      )
    );
  }

}
