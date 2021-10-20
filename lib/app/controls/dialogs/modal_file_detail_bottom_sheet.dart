import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.name,
    required this.path,
    required this.parent,
    required this.size,
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final String name;
  final String path;
  final String parent;
  final int size;

  @override
  _FileDetailState createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  String _selectedDestination = slash;
  List<DropdownMenuItem<String>> _destinations = <DropdownMenuItem<String>>[];

  bool _movingFile = false;
  bool _navigateToDestination = false;

  @override
  void initState() {
    super.initState();
    
    _loadFolders(widget.repository);
  }

  Future<void> _loadFolders(Repository repository) async {
    final directoriesItem = <DropdownMenuItem<String>>[];
    final directoryRepository = DirectoryRepository();
    
    if (widget.parent != slash) {
      directoriesItem.add(DropdownMenuItem(
        child: Text(slash),
        value: slash,
      ));
    }

    final repoContents = await directoryRepository.getContentsRecursive(repository, slash, <BaseItem>[]);
    repoContents.sort((a, b) => a.path.compareTo(b.path));
    
    repoContents.forEach((element) { 
      if (element.itemType == ItemType.folder 
      && element.path != widget.parent) {
        directoriesItem.add(DropdownMenuItem(
          child: Text(element.path),
          value: element.path,
        ));
      }  
    });

    _selectedDestination = directoriesItem.first.value!;
    _destinations.addAll(directoriesItem);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
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
          _buildPreviewButton(),
          _buildShareButton(),
          _buildMoveFileSection(widget.context, widget.bloc, widget.repository, widget.parent, widget.path),
          _buildDeleteButton(),
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

  GestureDetector _buildPreviewButton() {
    return GestureDetector(
          onTap: () async => await NativeChannels.previewOuiSyncFile(widget.path, widget.size),
          child: buildIconLabel(
            Icons.preview_rounded,
            'Preview',
            iconSize: 40.0,
            infoSize: 18.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
        );
  }

  GestureDetector _buildShareButton() {
    return GestureDetector(
          onTap: () async => await NativeChannels.shareOuiSyncFile(widget.path, widget.size),
          child: buildIconLabel(
            Icons.share_rounded,
            'Share',
            iconSize: 40.0,
            infoSize: 18.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
        );
  }

  Widget _buildMoveFileSection(context, bloc, repository, parent, path) {
    return Container(
      child: Column(
        children: [
          _buildMoveFileButton(),
          _buildMoveFileDetail(context, bloc, repository, parent, path),
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
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
        );
  }

  Visibility _buildMoveFileDetail(context, bloc, repository, parent, path) {
    return Visibility(
      visible: _movingFile,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
        child: Container(
          child: Column(
            children: [
              buildInfoLabel('From:', extractParentFromPath(widget.path), padding: EdgeInsets.all(0.0)),
              _destinationDropDown(),
              _buildNavigateToCheckBox(),
              buildActionsSection(
                context,
                _actions(context, bloc, repository, parent, path),
                padding: EdgeInsets.only(top: 20.0)
              ),
            ]
          ),
        )
      )
    );
  }

  DropdownButtonFormField _destinationDropDown() {
    return DropdownButtonFormField(
      icon: const Icon(Icons.create_new_folder_outlined),
      iconSize: 30.0,
      hint: Text('Destination'),
      value: _selectedDestination,
      items: _destinations,
      onChanged: (value) {
        _selectedDestination = value;
      },
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

  List<Widget> _actions(context, bloc, repository, parent, filePath) => [
    ElevatedButton(
      onPressed: () => _moveFile(context, bloc, repository, parent, filePath),
      child: Text('Move')
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: _showHideMoveFileSection,
      child: Text('Cancel')
    ),
  ];

  void _moveFile(context, bloc, repository, parent, filePath) {
    final newFilePath = _selectedDestination == slash
    ? '/${widget.name}'
    : '$_selectedDestination/${widget.name}';
    
    bloc.add(
      MoveEntry(
        repository: repository,
        origin: parent,
        destination: _selectedDestination,
        entryPath: filePath,
        newDestinationPath: newFilePath
      )
    );

    if (_navigateToDestination) {
      bloc.add(
        NavigateTo(
          repository: repository,
          type: Navigation.content,
          origin: parent,
          destination: _selectedDestination,
          withProgress: true
        )
      );

      // return;
    }

    Navigator.of(context).pop(newFilePath);
  }

  _showHideMoveFileSection() => setState(() { _movingFile = !_movingFile; });
  _changeNavigateToCheckBoxState(state) => setState(() => _navigateToDestination = state); 

  GestureDetector _buildDeleteButton() {
    return GestureDetector(
      onTap: () async => {},
      child: buildIconLabel(
        Icons.delete_outlined,
        'Delete',
        iconSize: 40.0,
        infoSize: 18.0,
        labelPadding: EdgeInsets.only(bottom: 30.0)
      ),
    );
  }
}