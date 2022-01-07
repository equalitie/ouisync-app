import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../bloc/blocs.dart';
import '../custom_widgets/custom_widgets.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class AddSharedFilePage extends StatefulHookWidget {
  AddSharedFilePage({
    required this.repository,
    required this.listOfSharedMedia,
    required this.routeBloc,
    required this.directoryBloc,
    required this.directoryBlocPath,
    required this.navigationBar
  });

  final Repository? repository;
  final List<SharedMediaFile> listOfSharedMedia;
  final RouteBloc routeBloc;
  final DirectoryBloc directoryBloc;
  final String directoryBlocPath;
  final CustomNavigationBar navigationBar;

  @override
  _ReceiveSharingIntentPageState createState() => _ReceiveSharingIntentPageState();
}

class _ReceiveSharingIntentPageState extends State<AddSharedFilePage>
  with TickerProviderStateMixin {

  late final fileName;
  late final pathWithoutName;

  String _currentFolder = Strings.rootPath;
  final rootItem = FolderItem(
    path: Strings.rootPath,
    items: <BaseItem>[]
  ); 
  
  @override
  void initState() {
    super.initState();

    initHeaderParams(widget.listOfSharedMedia.first.path);
  }

  initHeaderParams(String sharedFilePath) {
    fileName = getPathFromFileName(sharedFilePath);
    pathWithoutName = extractParentFromPath(sharedFilePath);
  }

  updateCurrentFolder(path) => setState(() {
    _currentFolder = path;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.titleAddShareFilePage),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFileInfoHeader(),
            _navigationRoute(widget.routeBloc),
            Divider(
              height: 10.0,
            ),
            Expanded(
              flex: 1,
              child: _directoriesBlocBuilder(widget.directoryBloc)
            ),
          ]
        ),
      ),
      floatingActionButton: _actionButtons(widget.directoryBloc),
    );
  }

  _buildFileInfoHeader() { 
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Column(
        children: [
          Card(
            color: Colors.yellow.shade700,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.file_present_rounded,
                        size: 35.0,
                      ),
                      SizedBox(width: 2.0),
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
                  SizedBox(height: 5.0),
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
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
            child: Row(
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
          ),
        ],
      ),
    );
  }
  
  _navigationRoute(RouteBloc routeBloc) => BlocConsumer(
    bloc: routeBloc, 
    builder: (context, state) {
      if (state is RouteLoadSuccess) {
        return Fields.routeBar(route: state.route);
      }

      return Container(
        child: Text('')
      );
    },
    listener: (context, state) {
      if (state is RouteLoadSuccess) {
        if (state.path == Strings.rootPath) {
          updateCurrentFolder(rootItem.path);
        }
      }
    }
  );

  _directoriesBlocBuilder(DirectoryBloc directoryBloc) {
    return Center(
      child: BlocBuilder(
        bloc: directoryBloc,
        builder: (context, state) {
          if (state is DirectoryInitial) {
            return Center(child: Text('Loading contents...'));
          }

          if (state is DirectoryLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is DirectoryLoadSuccess) {
            return loadContents(directoryBloc, state.contents as List<BaseItem>);
          }

          if (state is NavigationLoadSuccess) {
            return loadContents(directoryBloc, state.contents);
          }

          if (state is NavigationLoadFailure) {
            return Text(
              'Something went wrong!',
              style: TextStyle(color: Colors.red),
            );
          }

          return Center(child: Text('Ooops!'));
        }
      )
    );
  }

  Widget loadContents(DirectoryBloc directoryBloc, List<BaseItem> contents) {
    if (contents.isEmpty) {
      return _noContents();
    }

    final items = contents;
    items.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));

    return _contentsList(directoryBloc, items);
  }

  Widget _actionButtons(DirectoryBloc directoryBloc) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,  
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: Constants.heroTagCreateFolderSharedFile,
            onPressed: () async => await _createNewFolder(directoryBloc, _currentFolder),
            icon: const Icon(Icons.create_new_folder_rounded),
            label: const Text(Strings.actionNewFolder)
          ),
          SizedBox(width: 30.0),
          FloatingActionButton.extended(
            heroTag: Constants.heroTagSaveToFolderSharedFile,
            onPressed: () async => await _saveFileToSelectedFolder(
              directoryBloc: directoryBloc,
              destination: _currentFolder,
              fileName: getPathFromFileName(widget.listOfSharedMedia.single.path)
            ),
            icon: const Icon(Icons.arrow_circle_down),
            label: Text('${removeParentFromPath(_currentFolder)}')
          ),
        ],
      )
    );
  }

  _createNewFolder(DirectoryBloc directoryBloc, String current) {
    final formKey = GlobalKey<FormState>();

    final dialogTitle = 'Create Folder';
    final actionBody = FolderCreation(
      context: context,
      bloc: directoryBloc,
      repository: widget.repository!,
      path: current,
      formKey: formKey,
    );

    Dialogs.actionDialog(
      context,
      dialogTitle,
      actionBody
    ).then((newFolder) {
      setState(() {
        _currentFolder = newFolder;
      });
    });
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
              child: Fields.inPageMainMessage(Strings.messageEmptyFolderStructure),
            ),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Fields.inPageSecondaryMessage(
                  _currentFolder == Strings.rootPath
                  ? Strings.messageCreateNewFolderRootToStart
                  : Strings.messageCreateNewFolder,
                  tags: {
                    Constants.inlineTextBold: InlineTextStyles.bold,
                    Constants.inlineTextSize: InlineTextStyles.size(size: 20.0),
                    Constants.inlineTextIcon: InlineTextStyles.icon(Icons.south)
                  }
                )
              ),
            ),
          ],
        ),
      )
    ],
  );

  _contentsList(DirectoryBloc directoryBloc, List<BaseItem> contents) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
      separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.transparent,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final item = contents[index];
        return ListItem (
          repository: widget.repository!,
          itemData: item,
          mainAction: item.itemType == ItemType.file
          ? () { }
          : () { 
            final current = _currentFolder;
            updateCurrentFolder(item.path);

            _navigateTo(
              directoryBloc: directoryBloc,
              type: Navigation.content,
              origin: current,
              destination: item.path
            );
          },
          secondaryAction: item.itemType == ItemType.file
          ? () { }
          : () async {
            updateCurrentFolder(item.path);

            await _saveFileToSelectedFolder(
              directoryBloc: directoryBloc,
              destination: _currentFolder,
              fileName: getPathFromFileName(widget.listOfSharedMedia.single.path)
            );
          },
          filePopupMenu: Dialogs
              .filePopupMenu(
                context,
                widget.repository!,
                directoryBloc,
                { Strings.actionDeleteFile: item }
              ),
          folderDotsAction: () {},
          isDestination: true,
        );
      }
    );
  }

  Future<void> _saveFileToSelectedFolder({required DirectoryBloc directoryBloc, required String destination, required String fileName}) async {
    final filePath = destination == Strings.rootPath
    ? '/$fileName'
    : '$destination/$fileName';
        
    _saveFileToOuiSync(directoryBloc, destination, filePath);
  }

  Future<void> _saveFileToOuiSync(DirectoryBloc directoryBloc, String destination, String filePath) async {
    var fileStream = io.File(widget.listOfSharedMedia.first.path).openRead();
    directoryBloc.add(
      CreateFile(
        repository: widget.repository!,
        parentPath: destination,
        newFilePath: filePath,
        fileByteStream: fileStream
      )
    );

    _navigateTo(
      directoryBloc: directoryBloc,
      type: Navigation.content,
      origin: extractParentFromPath(destination),
      destination: destination,
    );

    Navigator.pop(context);
  }

  _navigateTo({
    required DirectoryBloc directoryBloc,
    required Navigation type,
    required String origin,
    required String destination
  }) {
    _currentFolder == Strings.rootPath
    ? directoryBloc.add(
      GetContent(
        repository: widget.repository!,
        path: origin,
        recursive: false,
        withProgress: true
      )
    )
    : directoryBloc.add(
      NavigateTo(
        repository: widget.repository!,
        type: type,
        origin: origin,
        destination: destination,
        withProgress: true
      )
    );
  }
}
