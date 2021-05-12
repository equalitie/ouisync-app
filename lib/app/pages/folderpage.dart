import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'pages.dart';

class FolderPage extends StatefulWidget {
  FolderPage({
    Key key, 
    @required this.repoPath,
    @required this.folderPath,
    @required this.foldersRepository,
    this.title
  }) : 
  assert(repoPath != null),
  assert(repoPath != ''),
  assert(folderPath != null),
  assert(foldersRepository != null),
  super(key: key);

  final String repoPath;
  final String folderPath;
  final DirectoryRepository foldersRepository;
  final String title;

  @override
  _FolderPageState createState() => _FolderPageState();

}

class _FolderPageState extends State<FolderPage>
  with TickerProviderStateMixin {

  AnimationController _controller;
  
  Color backgroundColor;
  Color foregroundColor;

  @override
  void initState() {
    BlocProvider.of<DirectoryBloc>(context).add(
      RequestContent(
        repoPath: widget.repoPath, 
        folderRelativePath: widget.folderPath,
      )
    );

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
      body: _folderContentsBlocBuilder(),
      floatingActionButton: Dialogs.floatingActionsButtonMenu(
        BlocProvider. of<DirectoryBloc>(context),
        context,
        _controller,
        widget.repoPath,
        widget.folderPath,
        folderActions,
        flagFolderActionsDialog,
        backgroundColor,
        foregroundColor
      )
    );
  }

  Widget _folderContentsBlocBuilder() {
    return Center(
        child: BlocBuilder<DirectoryBloc, DirectoryState>(
            builder: (context, state) {
              if (state is DirectoryInitial) {
                return Center(child: Text('Loading ${widget.folderPath} contents...'));
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
          widget.folderPath.isEmpty
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
                _actionByType(widget.repoPath, widget.folderPath, widget.foldersRepository, item); 
              }
          );
        }
    );
  }

  void _actionByType(String repoPath, String folderPath, DirectoryRepository repository, BaseItem data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BlocProvider(
          create: (context) => DirectoryBloc(
            repository: widget.foldersRepository
          ),
          child: _pageByType(
            repoPath,
            folderPath,
            repository,
            data
          ),
        );
      })
    );
  }

  _pageByType(String repoPath, String folderPath, DirectoryRepository repository, BaseItem data) => 
    data.itemType == ItemType.folder
    ? FolderPage(
      title: data.name,
      repoPath: repoPath,
      folderPath: widget.folderPath.isEmpty
        ? data.name
        : '${widget.folderPath}/${data.name}',
      foldersRepository: repository
    )
    : FilePage(
      title: data.name,
      repoPath: repoPath,
      folderPath: folderPath,
      foldersRepository: repository,
      data: data
    );

}