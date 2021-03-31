import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';

class AddRepoPage extends StatefulWidget {
  AddRepoPage({
    @required this.reposBaseFolderPath,
    this.title,
  }) :
  assert(reposBaseFolderPath != null),
  assert(reposBaseFolderPath != "");

  final String reposBaseFolderPath;
  final String title;

  @override
  _AddRepoPage createState() => _AddRepoPage();
}

class _AddRepoPage extends State<AddRepoPage> {
  final _createRepoFormKey = GlobalKey<FormState>();

  bool _encrypted = false;
  bool _backup = false;
  bool _read = false;
  bool _write = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createRepoFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration (
              icon: const Icon(Icons.folder),
              hintText: 'Repository name',
              labelText: 'Create a new repository',
              contentPadding: EdgeInsets.all(10.0),
            ),
            validator: (value) {
              return value.isEmpty
              ? 'Please enter a valid name (unique, no spaces, ...)'
              : null;
            },
            onSaved: (newRepoName) {
              BlocProvider.of<RepositoryBloc>(context)
              .add(
                RepositoryCreate(
                  repoDir: widget.reposBaseFolderPath,
                  newRepoRelativePath: newRepoName
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
                  if (_createRepoFormKey.currentState.validate()) {
                    _createRepoFormKey.currentState.save();
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
      )
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
    ],
  );
}