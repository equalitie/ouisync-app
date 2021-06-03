import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../bloc/blocs.dart';
import '../data/data.dart';
import '../models/models.dart';

class FilePage extends StatefulWidget {
  FilePage({
    required this.session,
    required this.foldersRepository,
    required this.folderPath,
    required this.data,
    required this.title,
  });

  final Session session;
  final DirectoryRepository foldersRepository;
  final String folderPath;
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
                        session: widget.session,
                        parentPath: widget.folderPath,
                        filePath: filePath
                      ),
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