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

class _ReceiveSharingIntentPageState extends State<ReceiveSharingIntentPage>
  with TickerProviderStateMixin {

  Widget? _bodyWidget;

  late TreeViewController _treeViewController;

  late AnimationController _controller;

  late Color backgroundColor;
  late Color foregroundColor;
  
  @override
  void initState() {
    super.initState();

    initAnimationController();
    initFoldersList();
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  initAnimationController()  => 
  _controller = new AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
  );

  Future<void> initFoldersList() async {
    setState(() {
      _bodyWidget = Center(child: CircularProgressIndicator());
    });

    final nodeList = await DirectoryRepository().getContentsRecursive(widget.session, '/');
    if (nodeList.isEmpty) {
      setState(() {
        _bodyWidget = _emptyTree();
      });
      return;
    }

    _folders(nodeList);
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).cardColor;
    foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Share file to OuiSync'),
      ),
      body: _bodyWidget,
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

  Widget _buildFileInfoHeader() { 
    var fileName = removePathFromFileName(widget.sharedFileInfo.first.path);
    var pathWithoutName = removeFileNameFromPath(widget.sharedFileInfo.first.path);

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
            height: 30.0,
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
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600
                ),
              ),
            ]
          ),
        ],
      ),
    );
  }

  _emptyTree() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _buildFileInfoHeader(),
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
                  text: messageCreateNewFolderToStartStyled,
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

  _folders(List<Node> nodeList) {
      var foldersColumn = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildFileInfoHeader(),
            const Divider(
              height: 20.0,
              thickness: 0.0,
              color: Colors.transparent,
            ),
            Expanded(
              child: _buildFoldersTree(nodeList),
            ),
          ],
        ),
      );

      setState(() {
        _bodyWidget = foldersColumn;
      });
  }

  _buildFoldersTree(List<Node> nodeList) {
    var folderNodes = <Node>[];
    folderNodes.add( // root node
      Node(
        parent: true,
        label: 'OuiSync',
        key: 'ouisync_repo',
        expanded: true,
        children: nodeList
      )
    );
    
    return _getFolderTree(folderNodes);
  }

  TreeView _getFolderTree(List<Node> folderNodes) {
    _treeViewController = TreeViewController(
      children: folderNodes
    );
    
    var foldersTree = TreeView(
      allowParentSelect: true,
      controller: _treeViewController,
      theme: _buildTreeViewTheme(),
      onExpansionChanged: _expandNode,
      onNodeTap: (key) {
        if (key == 'file') {
          return;
        }
    
        final selectedNode = _treeViewController.getNode(key);
        _saveFileToSelectedFolder(selectedNode, key);
      },
    );

    return foldersTree;
  }

  _expandNode(String key, bool expanded) {
    Node? node = _treeViewController.getNode(key);
    if (node != null) {
      List<Node> updated = _treeViewController.updateNode(
        key,
        node.copyWith(
          expanded: expanded,
          icon: expanded
          ? Icons.folder_open
          : Icons.folder
        ),
      );

      setState(() {
        _treeViewController = _treeViewController.copyWith(children: updated);
      });
    }
  }

  TreeViewTheme _buildTreeViewTheme() {
    return TreeViewTheme(
      parentLabelStyle: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        debugLabel: 'Parent node label'
      ),
      parentLabelOverflow: TextOverflow.fade,
      iconTheme: IconThemeData(
        size: 30.0
      ),
      expanderTheme: ExpanderThemeData(
        type: ExpanderType.chevron,
        size: 40.0
      ),
      labelStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        debugLabel: 'Child node label'
      ),
      labelOverflow: TextOverflow.ellipsis
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
