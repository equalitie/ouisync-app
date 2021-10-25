import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../utils/utils.dart';

class FolderDetail extends StatefulWidget {
  const FolderDetail({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.name,
    required this.path,
    required this.parent,
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final String name;
  final String path;
  final String parent;

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  String _selectedDestination = slash;
  List<DropdownMenuItem<String>> _destinations = <DropdownMenuItem<String>>[];

  bool _movingFile = false;
  bool _navigateToDestination = false;

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
          _folderDetails(context),
        ],
      ),
    );
  }

  Widget _folderDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle(widget.name),
          GestureDetector(
            onTap: () => delete(widget.context, widget.bloc, widget.repository, widget.parent, widget.path),
            child: buildIconLabel(
              Icons.delete_rounded,
              'Delete',
              iconSize: 40.0,
              infoSize: 18.0,
              labelPadding: EdgeInsets.only(bottom: 30.0)
            )
          ),
          _buildMoveFolderSection(this.widget.context, this.widget.bloc, this.widget.repository, this.widget.parent, this.widget.path),
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
          syncStatus(),
        ]
      )
    );
  }

  void delete(context, bloc, repository, parent, path) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return buildDeleteFolderAlertDialog(
          context,
          bloc,
          repository,
          parent,
          path,
        );
      },
    );

    if (result ?? false) {
      Navigator.of(context).pop(false);
    }
  }

  AlertDialog buildDeleteFolderAlertDialog(context, bloc, repository, parentPath, path) {
    return AlertDialog(
      title: const Text('Delete folder'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              path,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text('Are you sure you want to delete this folder?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('DELETE'),
          onPressed: () {
            bloc
            .add(
              DeleteFolder(
                repository: repository,
                parentPath: parentPath,
                path: path,
                recursive: false
              )
            );

            bloc.add(
              NavigateTo(
                repository: repository,
                type: Navigation.content,
                origin: extractParentFromPath(parentPath),
                destination: parentPath,
                withProgress: true
              )
            );
    
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }







  Widget _buildMoveFolderSection(context, bloc, repository, parent, path) {
    return Container(
      child: Column(
        children: [
          _buildMoveFolderButton(),
          _buildMoveFolderDetail(context, bloc, repository, parent, path),
        ],
      ),
    );
  }

  GestureDetector _buildMoveFolderButton() {
    return GestureDetector(
          onTap: _showHideMoveFolderSection,
          child: buildIconLabel(
            Icons.drive_file_move_outlined,
            'Move',
            iconSize: 40.0,
            infoSize: 18.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
        );
  }

  Visibility _buildMoveFolderDetail(context, bloc, repository, parent, path) {
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
      onPressed: () => _moveFolder(context, bloc, repository, parent, filePath),
      child: Text('Move')
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: _showHideMoveFolderSection,
      child: Text('Cancel')
    ),
  ];

  void _moveFolder(context, bloc, repository, parent, filePath) {
    final newFilePath = _selectedDestination == slash
    ? '/${widget.name}'
    : '$_selectedDestination/${widget.name}';
    
    bloc.add(
      MoveEntry(
        repository: repository,
        origin: '/f1',
        destination: '/f2',
        entryPath: '/f1/f3',
        newDestinationPath: '/f2/f3'
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

  _showHideMoveFolderSection() => setState(() { _movingFile = !_movingFile; });

  _changeNavigateToCheckBoxState(state) => setState(() => _navigateToDestination = state); 

  Widget syncStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildIdLabel('Sync Status:'),
        Container(
          height: 60.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            border: Border.all(
              color: Colors.green.shade600,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.check
                ),
                Text(
                  'SYNCED',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}