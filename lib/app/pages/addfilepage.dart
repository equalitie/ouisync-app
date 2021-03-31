import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';

class AddFilePage extends StatefulWidget {
  AddFilePage({
    @required this.repoPath,
    this.title,
  }) :
  assert(repoPath != null),
  assert(repoPath != "");

  final String repoPath;
  final String title;

  @override
  _AddFilePage createState() => _AddFilePage(); 
}
  
class _AddFilePage extends State<AddFilePage> {
  final _addFileFormKey = GlobalKey<FormState>();

  String _filePath;

  bool _hidden = false;
  bool _read = false;
  bool _write = false;
  bool _move = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: 'Select a file using the button',
          readOnly: true,
          decoration: InputDecoration (
            icon: const Icon(Icons.folder),
            hintText: 'File location',
            labelText: _filePath,//'Add a new file',
            contentPadding: EdgeInsets.all(10.0),
          ),
          validator: (value) {
            return value.isEmpty
            ? 'Please enter a valid path'
            : null;
          },
          onSaved: (newRepoName) {
            BlocProvider.of<RepositoryBloc>(context)
            .add(
              RepositoryCreate(
                repoDir: widget.repoPath,
                newRepoRelativePath: newRepoName
              )
            );

            Navigator.of(context).pop(true);
          },
        ),
        ElevatedButton(
          onPressed: () async {
            String path;
            FilePickerResult result = await FilePicker.platform.pickFiles();

            if(result != null) {
              path = result.files.single.path;
            }

            setState(() {
              _filePath = path;
            });
          },
          child: Text('SELECT FILE')),
        SizedBox(height: 50.0,),
        _configurationList(),
        SizedBox(height: 40.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_addFileFormKey.currentState.validate()) {
                  _addFileFormKey.currentState.save();
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
    );
  }

  _configurationList() => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      CheckboxListTile(
        key: Key('hide'),
        title: Text('Hide'),
        value: _hidden,
        onChanged: (value) {
          setState(() {
            _hidden = !_hidden; 
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