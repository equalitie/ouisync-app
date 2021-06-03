import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../data/data.dart';
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

class _ReceiveSharingIntentPageState extends State<ReceiveSharingIntentPage> {
  
  Widget? _bodyWidget;
  
  @override
  void initState() {
    super.initState();

    initFoldersList();
  }

  Future<void> initFoldersList() async {
    setState(() {
      _bodyWidget = _emptyTree();
    });

    final foldersList = await DirectoryRepository().getContentsRecursive(widget.session, '/');
    if (foldersList.isEmpty) {
      return;
    }

    _buildFoldersTree(foldersList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share file to OuiSync'),
      ),
      body: _bodyWidget,
    );
  }

  _emptyTree() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
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
            text: messageCreateNewFolderToStartStyled,
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
      ),
    ],
  );

  _buildFoldersTree(List<Node> nodes) {
    final folderNodes = <Node>[];
    folderNodes.add(
      Node(
        parent: true,
        label: 'OuiSync',
        key: 'ouisync_repo',
        expanded: true,
        children: nodes
      )
    );

    var _treeViewController = TreeViewController(children: folderNodes);
    final foldersTree = TreeView(
      allowParentSelect: true,
      controller: _treeViewController,
      onNodeTap: (key) {
        if (key == 'file') {
          return;
        }

        final selectedNode = _treeViewController.getNode(key);
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
      },
    );

    setState(() {
      _bodyWidget = foldersTree;
    });
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

  Widget _getHeader() { 
    var fileName = removePathFromFileName(widget.sharedFileInfo.first.path);
    var pathWithoutName = removeFileNameFromPath(widget.sharedFileInfo.first.path);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Pick the location for the file:',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ]
        ),
        SizedBox(height: 20.0),
        Container(
          constraints: BoxConstraints.tightForFinite(),
          color: Colors.grey,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.source),
                  SizedBox(width: 10.0),
                  Text(
                    pathWithoutName,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.file_present),
                  SizedBox(width: 10.0),
                  Text(
                    fileName,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ],
          )
        ),
      ],
    );
  }
}
