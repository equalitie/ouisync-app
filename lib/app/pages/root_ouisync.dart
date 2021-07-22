import 'dart:async';

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

  late AnimationController _controller;
  
  late Color backgroundColor;
  late Color foregroundColor;

  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    handleIncomingShareIntent();
    initAnimationController();

    loadRoot();
  }

  @override
  void dispose() {
    super.dispose();
    
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

  initAnimationController()  => _controller = new AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
  );

  loadRoot() => BlocProvider.of<NavigationBloc>(context)
  .add(NavigateTo(
      Navigation.folder,
      widget.path,
      slash,
      FolderItem(creationDate: DateTime.now(), lastModificationDate: DateTime.now(), items: <BaseItem>[])
  ));

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
      preferredSize: Size.fromHeight(27.0),
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
        final contents = state.contents as List<BaseItem>;
        contents.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));
        
        return contents.isEmpty 
        ? _noContents()
        : _contentsList(contents);
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

  _noContents() => Column(
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
  );

  _contentsList(List<BaseItem> contents) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.transparent
        ),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final item = contents[index];
          final navigationType = item.itemType == ItemType.file
          ? Navigation.file
          : Navigation.folder;

          final actionByType = item.itemType == ItemType.file
          ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return FilePage(
                  session: widget.session,
                  foldersRepository: widget.foldersRepository,
                  folderPath: extractParentFromPath(item.path),
                  data: item,
                  title: item.path,
                ); 
              })
            );
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
    );
  }

  _getFloatingButton() => Dialogs.floatingActionsButtonMenu(
    BlocProvider.of<DirectoryBloc>(context),
    widget.session,
    context,
    _controller,
    widget.path,
    folderActions,
    flagFolderActionsDialog,
    backgroundColor,
    foregroundColor
  );

}