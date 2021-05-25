import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../data/data.dart';
import '../utils/utils.dart';

class ReceiveSharingIntentPage extends StatefulWidget {
  ReceiveSharingIntentPage({
    @required this.repository,
    @required this.sharedFileInfo
  }) : assert (sharedFileInfo != null);

  final Repository repository;
  final List<SharedMediaFile> sharedFileInfo;

  @override
  _ReceiveSharingIntentPageState createState() => _ReceiveSharingIntentPageState();
}

class _ReceiveSharingIntentPageState extends State<ReceiveSharingIntentPage> {
  
  TreeView _foldersTree = TreeView(controller: TreeViewController()); 

  @override
  void initState() {
    super.initState();

    loadContents();
  }

  Future<void> loadContents() async {
    List<Node> folderNodes = [];

    final folderStructure = await DirectoryRepository().getContentsRecursive(widget.repository, '/');
    folderNodes.add(
      Node(
        parent: true,
        label: 'OuiSync',
        key: 'ouisync_repo',
        expanded: true,
        children: folderStructure
      )
    );

    var _treeViewController = TreeViewController(children: folderNodes);
    setState(() {
      _foldersTree = TreeView(
        allowParentSelect: true,
        controller: _treeViewController,
        onNodeTap: (key) {
          if (key == 'file') {
            return;
          }

          var selectedNode = _treeViewController.getNode(key);
          var data = selectedNode.data;
        },
      );
    });
  }

  Future<void> _saveFileToOuiSync(Repository repository, String parentPath, String destinationPath) async {
    // var fileStream = File(widget.sharedFileInfo.first.path).openRead();
    
    // BlocProvider.of<DirectoryBloc>(context)
    //   .add(
    //     CreateFile(
    //       repository: repository,
    //       parentPath: parentPath,
    //       newFileRelativePath: destinationPath,
    //       fileStream: fileStream
    //     )
    //   );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share file to OuiSync'),
      ),
      body: _foldersTree,
    );
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
