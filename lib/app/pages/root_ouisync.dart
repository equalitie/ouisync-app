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
import '../data/data.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pages.dart';

class RootOuiSync extends StatefulWidget {
  const RootOuiSync({
    required this.session,
    required this.foldersRepository,
    required this.path,
    required this.title,
  });

  final Session session;
  final DirectoryRepository foldersRepository;
  final String path;
  final String title;
  
  @override
  State<StatefulWidget> createState() => _RootOuiSyncState(); 
}

class _RootOuiSyncState extends State<RootOuiSync>
  with TickerProviderStateMixin {

  final List<BaseItem> _folderContents = <BaseItem>[];

  late final Timer autoRefreshTimer;
  String _currentFolder = slash;

  late AnimationController _controller;
  
  late Color backgroundColor;
  late Color foregroundColor;

  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    handleIncomingShareIntent();

    initAutoRefresh();
    initAnimationController();

    loadRoot(BlocProvider.of<NavigationBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();

    autoRefreshTimer.cancel();

    _controller.dispose();
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
        return ReceiveSharingIntentPage(
          session: widget.session,
          sharedFileInfo: sharedMedia,
          directoryBloc: BlocProvider.of<DirectoryBloc>(context),
          directoryBlocPath: widget.path,
        );
      })
    );
  }

  void initAutoRefresh() {
    autoRefreshTimer = Timer.periodic(
      Duration(seconds: autoRefreshPeriodInSeconds),
      (timer) { 
        print('[${DateTime.now()}] Pooling data for folder $_currentFolder');

        showSnackBar(
          context,
          content: Text('Updating contents after syncing'),
          action: hideSnackBar(context)
        );

        _reloadCurrentFolder();
      }
    );
  }

  initAnimationController()  => _controller = new AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
  );

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).cardColor;
    foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: _getAppBar(widget.title),
      drawer: _getDrawer(),
      body: _getScreen(),
      floatingActionButton: _getFloatingButton(),
    );
  }

  _getAppBar(destinationPath) => AppBar(
    title: _getTitle(),
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(30.0),
      child: Container(
        child: _getRoute(),
      ),
    ),
    actions: <Widget> [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {

        },
      )
    ]
  );

  _getTitle() => Text(
    widget.title
  );

  _getRoute() => BlocBuilder<RouteBloc, RouteState>(
    builder: (context, state) {
      if (state is RouteLoadSuccess) {
        return state.route;
      }

      return Container(
        child: Text('[!]]')
      );
    }
  );

  _getDrawer() => Drawer(
    child: Center(child: DrawerMenu()),
  );

  _getScreen() => BlocConsumer(
    bloc: BlocProvider.of<NavigationBloc>(context),
    listener: (context, state) {
      if (state is NavigationLoadSuccess) {
        if (state.navigation == Navigation.folder) {
          setState(() { 
            _currentFolder = state.destinationPath;
            print('Current path updated: $_currentFolder');
          });
          
          BlocProvider.of<DirectoryBloc>(context)
          .add(
            RequestContent(
              session: widget.session,
              path: state.destinationPath,
              recursive: false
            )
          );

          BlocProvider.of<RouteBloc>(context)
          .add(
            UpdateRoute(
              path: state.destinationPath,
              data: state.data
            )
          );
        }
      }
    },
    builder: (context, state) => _blocUI(context, state)
  );

  _blocUI(context, state) {
    return Center(
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          if (state is NavigationInitial) {
            return Center(child: Text('Loading ${widget.path}...'));
          }

          if (state is NavigationLoadInProgress){
            return Center(child: CircularProgressIndicator());
          }

          if (state is NavigationLoadSuccess) {
            if (state.navigation == Navigation.file) {
              return _contents();
            }

            if (state.navigation == Navigation.folder) {
              BlocProvider.of<DirectoryBloc>(context)
              .add(
                RequestContent(
                  session: widget.session,
                  path: state.destinationPath,
                  recursive: false
                )
              );

              return _contents();
            }  

            return _noContents();
          }

          if (state is DirectoryLoadFailure) {
            return Text(
              'Something went wrong!',
              style: TextStyle(color: Colors.red),
            );
          }

          return Center(child: Text('[!]'));
        }
      )
    );
  }

  _contents() => BlocBuilder<DirectoryBloc, DirectoryState>(
    builder: (context, state) {
      if (state is DirectoryInitial) {
        return Center(child: Text('Loading contents...'));
      }

      if (state is DirectoryLoadInProgress){
        return Center(child: CircularProgressIndicator());
      }

      if (state is DirectoryLoadSuccess) {
        return state.contents.isEmpty 
        ? _noContents()
        : _contentsList(state.contents);
      }

      if (state is DirectoryLoadFailure) {
        return Text(
          'Something went wrong!',
          style: TextStyle(color: Colors.red),
        );
      }

      return Center(child: Text('root'));
    }
  );

  _noContents() => RefreshIndicator(
      onRefresh: _reloadCurrentFolder,
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

  _contentsList(List contents) {
    updateFolderContents(contents);

    return RefreshIndicator(
      onRefresh: _reloadCurrentFolder,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.transparent
        ),
        itemCount: _folderContents.length,
        itemBuilder: (context, index) {
          final item = _folderContents[index];
          final navigationType = item.itemType == ItemType.file
          ? Navigation.file
          : Navigation.folder;

          final actionByType = item.itemType == ItemType.file
          ? () async {
            final file = await Dialogs.executeFutureWithLoadingDialog(
              context,
              getFile(widget.session, item.path, item.name)
            );
            if (file != null) {
              final size = await file.length;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return FilePage(
                    session: widget.session,
                    foldersRepository: widget.foldersRepository,
                    path: item.path,
                    name: item.name,
                    size: size,
                    title: item.name,
                  ); 
                })
              ); 
            }
          }
          : () {
            BlocProvider.of<NavigationBloc>(context)
            .add(
              NavigateTo(
                navigationType,
                extractParentFromPath(item.path),
                item.path,
                item //data
              )
            );
          };

          return ListItem (
              itemData: item,
              mainAction: actionByType,
              secondaryAction: () => {},
              popupMenu: Dialogs
                .filePopupMenu(
                  context,
                  widget.session,
                  BlocProvider. of<DirectoryBloc>(context),
                  { actionDeleteFile: item }
                ),
          );
        }
      )
    );
  }

  Future<void> _reloadCurrentFolder() async {
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      RequestContent(
        session: widget.session,
        path: _currentFolder,
        recursive: false
      )
    );
  }

  Future<void> updateFolderContents(items) async {
    if (items.isEmpty) {
      if (_folderContents.isNotEmpty) {
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          setState(() {
            _folderContents.clear();
          }); 
        });
      }
      return;
    }

    final contents = items as List<BaseItem>;
    contents.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));
    
    if (!DeepCollectionEquality.unordered().equals(contents, _folderContents)) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        setState(() {
          _folderContents = contents;
        });
      });  
    }
  }

  Future<File?> getFile(Session session, String path, String name) async {
    try {
      final repo = await Repository.open(session);
      return await File.open(repo, path);
    } on Exception catch (e) {
      print('Init file: $e');

      ScaffoldMessenger
      .of(context)
      .showSnackBar(
        SnackBar(
          content: Text('There was a problem opening the file $name.')
        )
      );
    }

    return null;
  }

  _getFloatingButton() => Dialogs.floatingActionsButtonMenu(
    BlocProvider.of<DirectoryBloc>(context),
    widget.session,
    context,
    _controller,
    _currentFolder,// widget.path,
    folderActions,
    flagFolderActionsDialog,
    backgroundColor,
    foregroundColor
  );

}