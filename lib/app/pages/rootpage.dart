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

class RootPage extends StatefulWidget {
  RootPage({
    required this.session,
    required this.foldersRepository,
    required this.title,
  });

  final Session session;
  final DirectoryRepository foldersRepository;
  final String title;

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage>
  with TickerProviderStateMixin {

  late AnimationController _controller;
  
  late Color backgroundColor;
  late Color foregroundColor;

  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    initAnimationController();
    handleIncomingShareIntent();
    
    super.initState();
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
        return BlocProvider(
          create: (context) => DirectoryBloc(
            blocRepository: widget.foldersRepository
          ),
          child: ReceiveSharingIntentPage(
            session:  widget.session,
            sharedFileInfo: sharedMedia,
            directoryBloc: BlocProvider.of<RepositoryBloc>(context),
            directoryBlocPath: '/',
          )
        );
      })
    );
  }

  initAnimationController()  => 
  _controller = new AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
  );

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
        BlocProvider.of<RepositoryBloc>(context),
        widget.session,
        context,
        _controller,
        '',//parentPath
        repoActions,
        flagRepoActionsDialog,
        backgroundColor,
        foregroundColor
      ),
    );
  }

  Widget _repositoriesBlocBuilder() {
    return Center(
        child: BlocBuilder<RepositoryBloc, RepositoryState>(
            builder: (context, state) {
              if (state is RepositoryInitial) {
                return Center(child: Text('Loading repositories...'));
              }

              if (state is RepositoryLoadInProgress){
                return Center(child: CircularProgressIndicator());
              }

              if (state is RepositoryLoadSuccess) {
                return state.repositories.isEmpty
                ? _noRepos()
                : _reposListView(context, state.repositories);
              }

              if (state is RepositoryLoadFailure) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }

              return Center(child: Text('repos_'));
            }
        )
    );
  }

  _noRepos() => Column(
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
    ],
  );

  _reposListView(BuildContext context, List<BaseItem> repositories) => ListView.builder(
    itemCount: repositories.length,
    itemBuilder: (context, index) {
      final repo = repositories[index];
      return RepoDescription(
        folderData: repo,
        isEncrypted: false,
        isLocal: true,
        isOwn: true,
        action: () => _navigateToRepositoryContents(
          context: context,
          repoPath: repo.path,
          title: repo.name
        )
      );
    },
  );

  void _navigateToRepositoryContents({
    required BuildContext context,
    required String repoPath,
    required String title
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BlocProvider(
          create: (context) => DirectoryBloc(
            blocRepository: widget.foldersRepository
          ),
          child: FolderPage(
            session: widget.session,
            foldersRepository: widget.foldersRepository,
            path: '',
            title: title
          )
        );
      })
    );
  }
}