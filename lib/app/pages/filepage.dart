import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../data/repositories/directoryrepository.dart';
import '../models/models.dart';

class FilePage extends StatefulWidget {
  FilePage({
    Key key,
    @required this.repoPath,
    @required this.folderPath,
    @required this.foldersRepository,
    @required this.data,
    this.title,
  }) :
  assert(repoPath != null),
  assert(repoPath != ''),
  assert(folderPath != null),
  assert(foldersRepository != null),
  super(key: key);

  final String repoPath;
  final String folderPath;
  final DirectoryRepository foldersRepository;
  final BaseItem data;
  final String title;

  @override
  _FilePage createState() => _FilePage();
}

class _FilePage extends State<FilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Folder details for ${widget.data.name}"),
              SizedBox(height: 50.0,),
              TextButton(
                  onPressed: () {
                    String filePath = widget.folderPath.isEmpty
                    ? widget.data.name
                    : '${widget.folderPath}/${widget.data.name}';
                    BlocProvider.of<DirectoryBloc>(context)
                    .add(
                      ReadFile(
                        repoPath: widget.repoPath,
                        parentPath: widget.folderPath,
                        fileRelativePath: filePath,
                        totalBytes: widget.data.size)
                    );
                  },
                  child: Text("Preview")
              ),
              SizedBox(height: 50.0,),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Pop!")
              ),
            ],
          )
      ),
    );
  }
}