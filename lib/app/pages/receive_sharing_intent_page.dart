import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_text/styled_text.dart';

import '../bloc/blocs.dart';
import '../controls/controls.dart';
import '../hooks/hooks.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class ReceiveSharingIntentPage extends StatefulHookWidget {
  ReceiveSharingIntentPage({
    required this.sharedFileInfo,
    required this.directoryBloc,
    required this.directoryBlocPath
  });

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

  late BaseItem _currentFolderData;
  final rootItem = FolderItem(
    path: slash,
    items: <BaseItem>[]
  ); 

  late Color backgroundColor;
  late Color foregroundColor;
  
  @override
  void initState() {
    super.initState();

    _currentFolderData = rootItem;

    initHeaderParams();
  }

  initHeaderParams() {
    fileName = getPathFromFileName(widget.sharedFileInfo.first.path);
    pathWithoutName = extractParentFromPath(widget.sharedFileInfo.first.path);
  }

  updateCurrentFolder(data) => setState(() {
    _currentFolderData = data;
  });

  @override
  Widget build(BuildContext context) {
    backgroundColor = Theme.of(context).cardColor;
    foregroundColor = Theme.of(context).accentColor;

    final hideFabsAnimationController = useAnimationController(
      duration: const Duration(milliseconds: actionsFloatingActionButtonAnimationDuration),
      initialValue: 1,
    );

    final scrollController = useScrollControllerForAnimation(hideFabsAnimationController);

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
              child: _directoriesBlocBuilder(scrollController)
            ),
          ]
        ),
      ),
      floatingActionButton: FadeTransition(
        opacity: hideFabsAnimationController,
        child: ScaleTransition(
          scale: hideFabsAnimationController,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,  
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {},
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: const Text(actionNewFolder)
                ),
                SizedBox(width: 30.0),
                FloatingActionButton.extended(
                  onPressed: () async => await _saveFileToSelectedFolder(
                    destination: _currentFolderData.path,
                    fileName: getPathFromFileName(widget.sharedFileInfo.single.path)
                  ),
                  icon: const Icon(Icons.arrow_circle_down),
                  label: Text('${removeParentFromPath(_currentFolderData.path)}')
                ),
              ],
            )
          ),
        ),
      )
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
        if (state.path == slash) {
          updateCurrentFolder(rootItem);
        }
      }
    }
  );

  _directoriesBlocBuilder(ScrollController scrollController) {
    return Center(
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          if (state is NavigationInitial) {
            return Center(child: Text('Loading contents...'));
          }

          if (state is NavigationLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is NavigationLoadSuccess) {
            if (state.contents.isEmpty) {
              return _noContents();
            }

            final contents = state.contents;
            contents.sort((a, b) => a.itemType.index.compareTo(b.itemType.index));

            return _contentsList(contents, scrollController);
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
                  text: _currentFolderData.path == slash
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

  _contentsList(List<BaseItem> contents, ScrollController scrollController) {
    return ListView.separated(
      controller: scrollController,
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
              final current = _currentFolderData.path;
              updateCurrentFolder(item);

              _navigateTo(
                type: Navigation.content,
                origin: current,
                destination: item.path
              );
            },
            secondaryAction: item.itemType == ItemType.file
            ? () { }
            : () async {
              updateCurrentFolder(item);

              await _saveFileToSelectedFolder(
                destination: item.path,
                fileName: getPathFromFileName(widget.sharedFileInfo.single.path)
              );
            },
            popupMenu: Dialogs
                .filePopupMenu(
                  context,
                  BlocProvider. of<DirectoryBloc>(context),
                  { actionDeleteFile: item }
                ),
            isDestination: true,
        );
      }
    );
  }

  Future<void> _saveFileToSelectedFolder({required String destination, required String fileName}) async {
    final filePath = destination == slash
    ? '/$fileName'
    : '$destination/$fileName';
        
    _saveFileToOuiSync(destination, filePath);
  }

  Future<void> _saveFileToOuiSync(String destination, String filePath) async {
    var fileStream = io.File(widget.sharedFileInfo.first.path).openRead();
    widget.directoryBloc
    .add(
      CreateFile(
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
    _currentFolderData.path == slash
    ? loadRoot(BlocProvider.of<NavigationBloc>(context))
    : BlocProvider.of<NavigationBloc>(context)
    .add(
      NavigateTo(
        type: type,
        origin: origin,
        destination: destination,
        withProgress: true
      )
    );
  }
}
