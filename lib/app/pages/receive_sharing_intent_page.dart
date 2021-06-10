import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
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

    _currentFolder = '/';

    initHeaderParams();
    initAnimationController();
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  initHeaderParams() {
    fileName = removePathFromFileName(widget.sharedFileInfo.first.path);
    pathWithoutName = extractParentFromPath(widget.sharedFileInfo.first.path);
  }

  initAnimationController()  => 
  _controller = new AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
  );

  getFolderContents(path) => BlocProvider.of<DirectoryBloc>(context)
  .add(RequestContent(
    session: widget.session,
    path: path,
    recursive: false
  ));

  getParentFolderFromCurrent() =>
    extractParentFromPath(_currentFolder!);

  updateCurrentFolder(path) {
    setState(() {
      _currentFolder = path;
    });
    return path;
  }

  atRoot() =>
    _currentFolder == '/';

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).cardColor;
    foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Share file to OuiSync'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFileInfoHeader(),
            _contentNavigationButtons(),
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
      floatingActionButton: Dialogs.floatingActionsButtonMenu(
        widget.directoryBloc,
        widget.session,
        context,
        _controller,
        widget.directoryBlocPath,//parentPath
        receiveShareActions,
        flagReceiveShareActionsDialog,
        backgroundColor,
        foregroundColor
      ),
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

  _contentNavigationButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
            child: Text('Back to ${getParentFolderFromCurrent()}'),
            onPressed: atRoot()
            ? null
            : () { 
              final target = getParentFolderFromCurrent();
              getFolderContents(updateCurrentFolder(target)); 
            }
          ),
          Row(
            children: [              
              Expanded(
                flex: 1,
                child: Text(
                  ' @ $_currentFolder ',
                  style: TextStyle (
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    backgroundColor: Colors.black
                  ),
                ),
              ),
            ]
          ),
        ],
      ),
    );
  }

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
                  text: _currentFolder == '/'
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
            mainAction: () {
              if (item.itemType == ItemType.file) {
                return;
              }  

              final path = updateCurrentFolder(item.path);
              getFolderContents(path);
            },
            popupAction: () => {},
        );
      }
    );
  }

  void _saveFileToSelectedFolder(Node<dynamic>? selectedNode, String key) {
    final folderData = selectedNode!.data != null
    ? selectedNode.data as FolderDescription
    : Widget;
    
    final parentPath = key == 'ouisync_repo'
    ? '/'
    : (folderData as FolderDescription).folderData.path;
    final fileName = removePathFromFileName(
      '/${widget.sharedFileInfo.first.path}'
    );
    final destinationPath = parentPath == '/'
    ? '/$fileName'
    : '$parentPath/$fileName';
        
    _saveFileToOuiSync(widget.session, widget.directoryBlocPath, destinationPath);
  }

  Future<void> _saveFileToOuiSync(Session session, String directoryBlocPath, String destinationPath) async {
    var fileStream = io.File(widget.sharedFileInfo.first.path).openRead();
    widget.directoryBloc
    .add(
      CreateFile(
        session: session,
        parentPath: directoryBlocPath,
        newFilePath: destinationPath,
        fileByteStream: fileStream
      )
    );

    Navigator.pop(context);
  }
}
