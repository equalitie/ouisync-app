import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/actions.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

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
      body: _blocBody(),
    );
  }

  _blocBody() {
    return BlocListener<DirectoryBloc, DirectoryState> (
      listener: (context, state) async {
        if (state is DirectoryInitial) {
            // return Center(child: Text('Loading ${widget.data.path}...'));
          }

          if (state is DirectoryLoadInProgress){
            // return Center(child: CircularProgressIndicator());
          }

          if (state is DirectoryLoadSuccess) {
            if (state.contents.isEmpty) {
              print('The file ${widget.data.name} is empty');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('The file ${widget.data.name} is empty'),
                  action: SnackBarAction(
                    label: 'HIDE',
                    onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()
                  ),
                ),  
              );
              
              return;
            }  

            final tempPath = (await getTemporaryDirectory()).path;
            final tempFileExtension = extractFileTypeFromName(widget.data.name);
            final tempFileName = '${DateTime.now().toIso8601String()}.$tempFileExtension';
            final tempFile = new io.File('$tempPath/$tempFileName');

            await tempFile.writeAsBytes(state.contents as List<int>);
            Share.shareFiles([tempFile.path])
            .then((value) async => 
              await tempFile.delete()
            );
          }

          if (state is DirectoryLoadFailure) {
            // return Text(
            //   'Something went wrong!',
            //   style: TextStyle(color: Colors.red),
            // );
          }
      },
      child: _fileInfo()
    );
  }

  _fileInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'name: ',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                widget.data.name,
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'location: ',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                widget.data.path
                .replaceAll(widget.data.name, '')
                .trimRight(),
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'size: ',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                widget.data.size.toString(),
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ],
          ),

          const Divider(
            height: 30.0,
            thickness: 1.0,
            color: Colors.black12,
            indent: 30.0,
            endIndent: 30.0,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  
                },
                child: Text('Preview'),
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
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
                child: Text('Share'),
                autofocus: true,
              ),
            ]
          ),
        ],
      ),
    );
  }
}