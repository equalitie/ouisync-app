import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pages.dart';

class RootFolderPage extends StatefulWidget {
  RootFolderPage({
    Key key,
    @required this.session,
    @required this.foldersRepository,
    @required this.path,
    @required this.title,
  }) : super(key: key);

  final Session session;
  final DirectoryRepository foldersRepository;
  final String path;
  final String title;

  @override
  _RootFolderPageState createState() => _RootFolderPageState();
}

class _RootFolderPageState extends State<RootFolderPage>
  with TickerProviderStateMixin {
    
  Repository _repository;
  
  AnimationController _controller;
  
  Color backgroundColor;
  Color foregroundColor;

  StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    initRepository().then((value) => _getFolderContents());
    initAnimationController();

    handleIncomingShareIntent();
  }

  @override
  void dispose() {
    super.dispose();
    
    _repository.close();
    _controller.dispose();
    _intentDataStreamSubscription.cancel();
  }

  Future<void> initRepository() async {
    final repository = await Repository.open(widget.session);
    setState(() {
      this._repository = repository;
    });
  }

  _getFolderContents() => BlocProvider.of<DirectoryBloc>(context)
  .add(RequestContent(
    repository: _repository,
    path: widget.path,
    recursive: false
  ));

  initAnimationController()  => _controller = new AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
  );

  void handleIncomingShareIntent() {
    // For sharing files coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
        print("Shared:" + (value?.map((f)=> f.path)?.join(",") ?? ""));  
        _processIntent(value);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing files coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      print("Shared:" + (value?.map((f)=> f.path)?.join(",") ?? ""));  
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
        return BlocProvider(
          create: (context) => DirectoryBloc(
            repository: widget.foldersRepository
          ),
          child: ReceiveSharingIntentPage(
            repository: _repository,
            sharedFileInfo: sharedMedia,
          )
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).cardColor;
    foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {

            },
          )
        ]
      ),
      drawer: Drawer(
        child: Center(child: DrawerMenu()),
      ),
      body: _repositoriesBlocBuilder(),
      floatingActionButton: Dialogs.floatingActionsButtonMenu(
        BlocProvider. of<DirectoryBloc>(context),
        _repository,
        context,
        _controller,
        widget.path,
        folderActions,
        flagFolderActionsDialog,
        backgroundColor,
        foregroundColor
      ),
    );
  }

  Widget _repositoriesBlocBuilder() {
    return Center(
      child: BlocBuilder<DirectoryBloc, DirectoryState>(
        builder: (context, state) {
          if (state is DirectoryInitial) {
            return Center(child: Text('Loading ${widget.path} contents...'));
          }

          if (state is DirectoryLoadInProgress){
            return Center(child: CircularProgressIndicator());
          }

          if (state is DirectoryLoadSuccess) {
            final contents = state.contents;

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
      )
    );
  }

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
          return ListItem (
              itemData: item,
              action: () {
                _actionByType(widget.foldersRepository, widget.path, item); 
              }
          );
        }
    );
  }

  void _actionByType(DirectoryRepository folderRespository, String folderPath, BaseItem data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BlocProvider(
          create: (context) => DirectoryBloc(
            repository: widget.foldersRepository
          ),
          child: _pageByType(
            folderRespository,
            folderPath,
            data
          ),
        );
      })
    );
  }

  _pageByType(DirectoryRepository folderRepository, String folderPath, BaseItem data) { 
    String destinationPath = folderPath == '/'
      ? '/${data.name}'
      : '$folderPath/${data.name}';

    return data.itemType == ItemType.folder
    ? FolderPage(
      repository: _repository,
      foldersRepository: folderRepository,
      path: destinationPath,
      title: destinationPath,
    )
    : FilePage(
      repository: _repository,
      foldersRepository: folderRepository,
      folderPath: folderPath,
      data: data,
      title: '$folderPath/${data.name}',
    );
  }
}