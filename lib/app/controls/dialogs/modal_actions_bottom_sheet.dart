import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../utils/utils.dart';

class DirectoryActions extends StatelessWidget {
  const DirectoryActions({
    Key? key,
    required this.parent,
    required this.folderAction,
    required this.fileAction
  }) : super(key: key);

  final String parent;
  final Function folderAction;
  final Function fileAction;

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
          buildTitle('Add Folders/Files'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAction(
                name: 'Create a folder',
                icon: Icons.folder_outlined,
                action: folderAction
              ),
              _buildAction(
                name: 'Add a file',
                icon: Icons.insert_drive_file_outlined,
                action: fileAction
              )
            ]
          ),
        ]
      )
    );
  }

  Widget _buildAction({name, icon, action}) => Padding(
    padding: EdgeInsets.all(10.0),
    child: GestureDetector(
      onTap: action,
      child: Column(
        children: [
          Icon(
            icon,
            size: 100.0,
          ),
          SizedBox(height: 10.0,),
          Text(
            name,
            style: TextStyle(
              fontSize: 14.0 
            )
          )
        ],
      )
    ),
  ); 
}