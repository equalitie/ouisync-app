import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class ReceiveSharingIntentPage extends StatefulWidget {
  ReceiveSharingIntentPage({
    required this.session,
    required this.sharedFileInfo,
    required this.directoryBloc,
    required this.directoryBlocPath
  });

  final Session session;
  final List<SharedMediaFile> sharedFileInfo;
  final Bloc directoryBloc;
  final String directoryBlocPath;

  @override
  _ReceiveSharingIntentPageState createState() => _ReceiveSharingIntentPageState();
}

class _ReceiveSharingIntentPageState extends State<ReceiveSharingIntentPage>
  with TickerProviderStateMixin {

  late final fileName;
  late final pathWithoutName;

  String? _currentFolder;

  late AnimationController _controller;

  late Color backgroundColor;
  late Color foregroundColor;
  
  @override
  void initState() {
    super.initState();

    _currentFolder = slash;

    initHeaderParams();
    initAnimationController();
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  initHeaderParams() {
    fileName = getPathFromFileName(widget.sharedFileInfo.first.path);
    pathWithoutName = extractParentFromPath(widget.sharedFileInfo.first.path);
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
        title: Text('Add file to OuiSync'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFileInfoHeader(),
            _navigationRoute(),
            Divider(
              height: 10.0,
            ),
            Expanded(
              flex: 1,
              child: _directoriesBlocBuilder()
            ),
          ]
        ),
      ),
      floatingActionButton: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,  
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.save_alt_rounded),
              label: Text('Use $_currentFolder')
            ),
            SizedBox(width: 30.0),
            FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.create_new_folder_rounded),
              label: const Text(actionNewFolder)
            ),
          ],
        )
      )
    );
  }

  _buildFileInfoHeader() { 
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            constraints: BoxConstraints.tightForFinite(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.blueGrey.shade50,
              shape: BoxShape.rectangle,
              boxShadow: [ 
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(3.0, 3.0),
                  blurRadius: 1.0,
                  spreadRadius: 0.2,
                ) 
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.file_present),
                    SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: Text(
                        fileName,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  pathWithoutName,
                  textAlign: TextAlign.start,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            )
          ),
          const Divider(
            height: 40.0,
            thickness: 1.0,
            color: Colors.black12,
            indent: 30.0,
            endIndent: 30.0,
          ),
          Row(
            children: [
              Text(
                'Where do you want to put it?',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                ),
              ),
            ]
          ),
        ],
      ),
    );
  }

  _navigationRoute() => BlocBuilder<RouteBloc, RouteState>(
    builder: (context, state) {
      if (state is RouteLoadSuccess) {
        return state.route;
      }

      return Container(
        child: Text('[!]]')
      );
    }
  );

  _directoriesBlocBuilder() {
    return Center(
      child: BlocBuilder<DirectoryBloc, DirectoryState>(
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
      )
    );
  }

  _noContents() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                messageEmptyFolderStructure,
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: StyledText(
                  text: _currentFolder == slash
                  ? messageCreateNewFolderRootToStartStyled
                  : messageCreateNewFolderStyled,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal
                  ),
                  styles: {
                    'bold': TextStyle(fontWeight: FontWeight.bold),
                    'arrow_down': IconStyle(Icons.south),
                  },
                ),
              ),
            ),
          ],
        ),
      )
    ],
  );

  _contentsList(List<BaseItem> contents) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.transparent,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final item = contents[index];
        return ListItem (
            itemData: item,
            mainAction: item.itemType == ItemType.file
            ? () { }
            : () { 
              _saveFileToSelectedFolder(
                item.path,
                getPathFromFileName(widget.sharedFileInfo.single.path),
                item
              );
            },
            secondaryAction: item.itemType == ItemType.file
            ? () { }
            : () {
               _navigateTo(
                Navigation.folder,
                extractParentFromPath(item.path),
                item.path,
                item //data
              );

               setState(() {
                _currentFolder = item.path;
              });
            },
            popupMenu: Dialogs
                .filePopupMenu(
                  context,
                  widget.session,
                  BlocProvider. of<DirectoryBloc>(context),
                  { actionDeleteFile: item }
                ),
            isDestination: true,
        );
      }
    );
  }

  void _saveFileToSelectedFolder(String path, String fileName, BaseItem data) {
    final destinationPath = path == '/'
    ? '/$fileName'
    : '$path/$fileName';
        
    _saveFileToOuiSync(widget.session, path, destinationPath, data);
  }

  Future<void> _saveFileToOuiSync(Session session, String parentPath, String destinationPath, BaseItem data) async {
    var fileStream = io.File(widget.sharedFileInfo.first.path).openRead();
    widget.directoryBloc
    .add(
      CreateFile(
        session: session,
        parentPath: parentPath,
        newFilePath: destinationPath,
        fileByteStream: fileStream
      )
    );

    _navigateTo(
      Navigation.folder,
      extractParentFromPath(parentPath),
      parentPath,
      data
    );

    Navigator.pop(context);
  }

  _navigateTo(type, parent, destination, data) {
    BlocProvider.of<NavigationBloc>(context)
    .add(
      NavigateTo(
        type,
        parent,
        destination,
        data
      )
    );
  }
}
