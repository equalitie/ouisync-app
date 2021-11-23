import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../custom_widgets/custom_widgets.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class AddSharedFilePage extends StatefulHookWidget {
  AddSharedFilePage({
    required this.repository,
    required this.sharedFileInfo,
    required this.directoryBloc,
    required this.directoryBlocPath
  });

  final Repository repository;
  final List<SharedMediaFile> sharedFileInfo;
  final Bloc directoryBloc;
  final String directoryBlocPath;

  @override
  _ReceiveSharingIntentPageState createState() => _ReceiveSharingIntentPageState();
}

class _ReceiveSharingIntentPageState extends State<AddSharedFilePage>
  with TickerProviderStateMixin {

  late final fileName;
  late final pathWithoutName;

  late String _currentFolder;
  final rootItem = FolderItem(
    path: Strings.rootPath,
    items: <BaseItem>[]
  ); 

  late Color backgroundColor;
  late Color foregroundColor;
  
  @override
  void initState() {
    super.initState();

    _currentFolder = rootItem.path;

    initHeaderParams();
  }

  initHeaderParams() {
    fileName = getPathFromFileName(widget.sharedFileInfo.first.path);
    pathWithoutName = extractParentFromPath(widget.sharedFileInfo.first.path);
  }

  updateCurrentFolder(path) => setState(() {
    _currentFolder = path;
  });

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
      floatingActionButton: _actionButtons(),
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
  
  _navigationRoute() => BlocConsumer(
    bloc: BlocProvider.of<RouteBloc>(context), 
    builder: (context, state) {
      if (state is RouteLoadSuccess) {
        return state.route;
      }

      return Container(
        child: Text('[!]]')
      );
    },
    listener: (context, state) {
      if (state is RouteLoadSuccess) {
        if (state.path == Strings.rootPath) {
          updateCurrentFolder(rootItem);
        }
      }
    }
  );

  _directoriesBlocBuilder() {
    return Center(
      child: BlocBuilder<DirectoryBloc, DirectoryState>(
        builder: (context, state) {
          if (state is DirectoryInitial) {
            return Center(child: Text('Loading contents...'));
          }

          if (state is DirectoryLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is DirectoryLoadSuccess) {
            return loadContents(state.contents as List<BaseItem>);
          }

          if (state is NavigationLoadSuccess) {
            return loadContents(state.contents);
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

  Widget loadContents(List<BaseItem> contents) {
    if (contents.isEmpty) {
      return _noContents();
    }

    final items = contents;
    items.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));

    return _contentsList(items);
  }

  Widget _actionButtons() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,  
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () async => await _createNewFolder(_currentFolder),
            icon: const Icon(Icons.create_new_folder_rounded),
            label: const Text(Strings.actionNewFolder)
          ),
          SizedBox(width: 30.0),
          FloatingActionButton.extended(
            onPressed: () async => await _saveFileToSelectedFolder(
              destination: _currentFolder,
              fileName: getPathFromFileName(widget.sharedFileInfo.single.path)
            ),
            icon: const Icon(Icons.arrow_circle_down),
            label: Text('${removeParentFromPath(_currentFolder)}')
          ),
        ],
      )
    );
  }

  _createNewFolder(String current) {
    final formKey = GlobalKey<FormState>();

    final dialogTitle = 'Create Folder';
    final actionBody = FolderCreation(
      context: context,
      bloc: BlocProvider.of<DirectoryBloc>(context),
      repository: widget.repository,
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
              child: Text(
                Strings.messageEmptyFolderStructure,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23.0,
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
                  text: _currentFolder == Strings.rootPath
                  ? Strings.messageCreateNewFolderRootToStartStyled
                  : Strings.messageCreateNewFolderStyled,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.0,
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
      padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
      separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.transparent,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final item = contents[index];
        return ListItem (
          repository: widget.repository,
          itemData: item,
          mainAction: item.itemType == ItemType.file
          ? () { }
          : () { 
            final current = _currentFolder;
            updateCurrentFolder(item.path);

            _navigateTo(
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
              destination: _currentFolder,
              fileName: getPathFromFileName(widget.sharedFileInfo.single.path)
            );
          },
          filePopupMenu: Dialogs
              .filePopupMenu(
                context,
                widget.repository,
                BlocProvider. of<DirectoryBloc>(context),
                { Strings.actionDeleteFile: item }
              ),
          folderDotsAction: () {},
          isDestination: true,
        );
      }
    );
  }

  Future<void> _saveFileToSelectedFolder({required String destination, required String fileName}) async {
    final filePath = destination == Strings.rootPath
    ? '/$fileName'
    : '$destination/$fileName';
        
    _saveFileToOuiSync(destination, filePath);
  }

  Future<void> _saveFileToOuiSync(String destination, String filePath) async {
    var fileStream = io.File(widget.sharedFileInfo.first.path).openRead();
    widget.directoryBloc
    .add(
      CreateFile(
        repository: widget.repository,
        parentPath: destination,
        newFilePath: filePath,
        fileByteStream: fileStream
      )
    );

    _navigateTo(
      type: Navigation.content,
      origin: extractParentFromPath(destination),
      destination: destination,
    );

    Navigator.pop(context);
  }

  _navigateTo({type, origin, destination}) {
    _currentFolder == Strings.rootPath
    ? BlocProvider.of<DirectoryBloc>(context)
    .add(
      GetContent(
        repository: widget.repository,
        path: origin,
        recursive: false,
        withProgress: true
      )
    )
    : BlocProvider.of<DirectoryBloc>(context)
    .add(
      NavigateTo(
        repository: widget.repository,
        type: type,
        origin: origin,
        destination: destination,
        withProgress: true
      )
    );
  }
}
