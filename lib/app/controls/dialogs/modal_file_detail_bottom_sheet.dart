import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.directoryRepository,
    required this.name,
    required this.path,
    required this.parent,
    required this.size,
  });

  final DirectoryRepository directoryRepository;
  final String name;
  final String path;
  final String parent;
  final int size;

  @override
  _FileDetailState createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  DropdownMenuItem? _selectedDestination ;
  List<DropdownMenuItem> _destinations = <DropdownMenuItem>[];

  bool _movingFile = false;
  bool _navigateToDestination = false;

  @override
  void initState() {
    super.initState();
    
    _loadFolders(widget.directoryRepository);
  }

  Future<void> _loadFolders(DirectoryRepository repository) async {
    final directoriesItem = <DropdownMenuItem>[];
    final repoContents = await repository.getContentsRecursive(slash);
    repoContents.forEach((element) { 
      if (element.itemType == ItemType.folder 
      && element.path != widget.parent) {
        directoriesItem.add(DropdownMenuItem(
          child: Text(element.name),
          value: element.path,
        ));
      }  
    });

    setState(() {
      _destinations.addAll(directoriesItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHandle(context),
          _fileDetails(context),
        ],
      ),
    );
  }

  Widget _fileDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle('File Details'),
          GestureDetector(
            onTap: () async => await NativeChannels.previewOuiSyncFile(widget.path, widget.size),
            child: buildIconLabel(
              Icons.preview_rounded,
              'Preview',
              iconSize: 40.0,
              infoSize: 18.0,
              labelPadding: EdgeInsets.only(bottom: 30.0)
            ),
          ),
          GestureDetector(
            onTap: () async => await NativeChannels.shareOuiSyncFile(widget.path, widget.size),
            child: buildIconLabel(
              Icons.share_rounded,
              'Share',
              iconSize: 40.0,
              infoSize: 18.0,
              labelPadding: EdgeInsets.only(bottom: 30.0)
            ),
          ),
          _buildMoveFileSection(),
          Divider(
            height: 50.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          buildIconLabel(
            Icons.info_rounded,
            'Information',
            iconSize: 40.0,
            infoSize: 24.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
          buildInfoLabel(
            'Name: ',
            widget.name
          ),
          buildInfoLabel(
            'Location: ', 
            widget.path
            .replaceAll(widget.name, '')
            .trimRight(),
          ),
          buildInfoLabel(
            'Size: ',
            formattSize(widget.size, units: true)
          ),
        ],
      ),
    );
  }

  Widget _buildMoveFileSection() {
    return Container(
      child: Column(
        children: [
          _buildMoveFileButton(),
          _buildMoveFileDetail(),
        ],
      ),
    );
  }

  GestureDetector _buildMoveFileButton() {
    return GestureDetector(
          onTap: _showHideMoveFileSection,
          child: buildIconLabel(
            Icons.drive_file_move_outlined,
            'Move',
            iconSize: 40.0,
            infoSize: 18.0,
            labelPadding: EdgeInsets.only(bottom: 10.0)
          ),
        );
  }

  Visibility _buildMoveFileDetail() {
    return Visibility(
      visible: _movingFile,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        child: Container(
          child: Column(
            children: [
              buildInfoLabel('From:', extractParentFromPath(widget.path)),
              _destinationDropDown(),
              _buildNavigateToCheckBox(),
              buildActionsSection(
                context,
                _actions(context, 'origin', 'filePath'),
                padding: EdgeInsets.only(top: 30.0)
              ),
            ]
          ),
        )
      )
    );
  }

  DropdownButtonFormField _destinationDropDown() {
    return DropdownButtonFormField(
      value: _selectedDestination,
      hint: Text('Destination'),
      items: _destinations,
    );
  }

  Padding _buildNavigateToCheckBox() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            child: buildIdLabel('Navigate to destination'),
            onTap: () => _changeNavigateToCheckBoxState(!_navigateToDestination),
          ),
          Checkbox(
            value: _navigateToDestination,
            onChanged: (value) => _changeNavigateToCheckBoxState(value)
          )
        ],
      )
    );
  }

  List<Widget> _actions(context, origin, filePath) => [
    ElevatedButton(
      onPressed: () => _moveFile(context, origin, filePath),
      child: Text('Move')
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: _showHideMoveFileSection,
      child: Text('Cancel')
    ),
  ];

  void _moveFile(context, origin, filePath) {
    final newFilePath = _selectedDestination!.value == slash
    ? '/${widget.name}'
    : '${_selectedDestination!.value}/${widget.name}';
    
    BlocProvider.of<DirectoryBloc>(context)
    .add(
      MoveFile(
        origin: origin,
        destination: _selectedDestination!.value,
        filePath: filePath,
        newFilePath: newFilePath
      )
    );

    if (_navigateToDestination) {
      BlocProvider.of<DirectoryBloc>(context)
      .add(
        NavigateTo(
          type: Navigation.content,
          origin: origin,
          destination: _selectedDestination!.value,
          withProgress: true
        )
      );

      return;
    }

    Navigator.of(context).pop(newFilePath);
  }

  _showHideMoveFileSection() => setState(() { _movingFile = !_movingFile; });
  _changeNavigateToCheckBoxState(state) => setState(() => _navigateToDestination = state); 
}