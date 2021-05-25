import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../bloc/blocs.dart';

class AddFolderPage extends StatefulWidget {
  AddFolderPage({
    @required this.repository,
    @required this.path,
    @required this.title,
  });

  final Repository repository;
  final String path;
  final String title;

  @override
  _AddFolderPage createState() => _AddFolderPage(); 
}
  
class _AddFolderPage extends State<AddFolderPage> {
  final _createFolderFormKey = GlobalKey<FormState>();

  bool _encrypted = false;
  bool _backup = false;
  bool _read = false;
  bool _write = false;
  bool _move = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createFolderFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration (
              icon: const Icon(Icons.folder),
              hintText: 'Folder name',
              labelText: 'Create a new folder',
              contentPadding: EdgeInsets.all(10.0),
            ),
            validator: (value) {
              return value.isEmpty
              ? 'Please enter a valid name (unique, no spaces, ...)'
              : null;
            },
            onSaved: (newFolderName) {
              final folderPath = widget.path == '/'
              ? newFolderName
              : '${widget.path}/$newFolderName';  

              BlocProvider.of<DirectoryBloc>(context)
              .add(
                CreateFolder(
                  repository: widget.repository,
                  parentPath: widget.path,
                  newFolderPath: folderPath
                )
              );

              Navigator.of(context).pop(true);
            },
          ),
          SizedBox(height: 50.0,),
          _configurationList(),
          SizedBox(height: 40.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_createFolderFormKey.currentState.validate()) {
                    _createFolderFormKey.currentState.save();
                  }
                },
                child: const Text('CREATE'),
              ),
              SizedBox(width: 40.0,),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('CANCEL'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _configurationList() => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      CheckboxListTile(
        key: Key('encrypt'),
        title: Text('Encrypted'),
        value: _encrypted,
        onChanged: (value) {
          setState(() {
            _encrypted = !_encrypted; 
          });
        }
      ),
      CheckboxListTile(
        key: Key('backup'),
        title: Text('Backup'),
        value: _backup,
        onChanged: (value) {
          setState(() {
            _backup = !_backup; 
          });
        }
      ),
      CheckboxListTile(
        key: Key('read'),
        title: Text('Readable'),
        value: _read,
        onChanged: (value) {
          setState(() {
            _read = !_read; 
          });
        }
      ),
      CheckboxListTile(
        key: Key('write'),
        title: Text('Writable'),
        value: _write,
        onChanged: (value) {
          setState(() {
            _write = !_write; 
          });
        }
      ),
      CheckboxListTile(
        key: Key('move'),
        title: Text('Movable'),
        value: _move,
        onChanged: (value) {
          setState(() {
            _move = !_move; 
          });
        }
      ),
    ],
  );
}