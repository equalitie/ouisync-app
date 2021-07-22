import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import '../bloc/blocs.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../utils/actions.dart';
import '../utils/utils.dart';

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

  late final filePath;

  late final tempPath;
  late final tempFileName;

  @override
  void initState() {
    super.initState();

    initTempFileParams();
  }

  Future<void> initTempFileParams() async {
    filePath = widget.folderPath.isEmpty
    ? widget.data.name
    : '${widget.folderPath}/${widget.data.name}';

    tempPath = (await getTemporaryDirectory()).path;

    final tempFileExtension = extractFileTypeFromName(widget.data.name);
    tempFileName = '${DateTime.now().toIso8601String()}.$tempFileExtension';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _blocBody(),//_fileDetails()
    );
  }

  _fileDetails() => BlocBuilder<DirectoryBloc, DirectoryState>(
    builder: (context, state) {
      if (state is DirectoryInitial) {
        //return Center(child: Text('Reading file ${widget.data.name}...'));
        return _fileInfo();
      }

      if (state is DirectoryLoadInProgress){
        return Center(child: CircularProgressIndicator());
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
          
          return Center(child: Text('File ${widget.data.name} is empty.'));
        }

        final tempFile = new io.File('$tempPath/$tempFileName');
        tempFile.writeAsBytes(state.contents as List<int>)
        .then((value) async {
          if (state.action == actionPreview) {
            await OpenFile.open(tempFile.path)
            .then((result) async {
              print("type=${result.type}  message=${result.message}");
            })
            .whenComplete(() {
              Timer.periodic(
                Duration(seconds: 5),
                (timer) async {
                  await tempFile.delete(); 
                  print('File ${tempFile.path} deleted from cache');
                  timer.cancel();
                  print('Timer cancelled');
                }
              );
              print('File ${tempFile.path} opened');
            });
          }  

          if (state.action == actionShare) {
            await Share.shareFiles([tempFile.path])
            .then((value) async => 
              await tempFile.delete()
            )
            .whenComplete(() => 
              print('File ${tempFile.path} shared')
            ); 
          }
        });

        return _fileInfo();
      }

      if (state is DirectoryLoadFailure) {
        return Text(
          'Something went wrong!',
          style: TextStyle(color: Colors.red),
        );
      }

      return Center(child: Text('file ${widget.data.name}'));
    }
  );

  _blocBody() {
    return BlocListener<DirectoryBloc, DirectoryState> (
      listener: (context, state) async {
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

          final tempFile = new io.File('$tempPath/$tempFileName');
          await tempFile.writeAsBytes(state.contents as List<int>);

          if (state.action == actionPreview) {
            await OpenFile.open(tempFile.path)
            .then((result) async {
              print("type=${result.type}  message=${result.message}");
            })
            .whenComplete(() {
              Timer.periodic(
                Duration(seconds: 5),
                (timer) async {
                  await tempFile.delete(); 
                  print('File ${tempFile.path} deleted from cache');
                  timer.cancel();
                  print('Timer cancelled');
                }
              );
              print('File ${tempFile.path} opened');
            });
          }  

          if (state.action == actionShare) {
            await Share.shareFiles([tempFile.path])
            .then((value) async => 
              await tempFile.delete()
            )
            .whenComplete(() => 
              print('File ${tempFile.path} shared')
            ); 
          }
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
                  BlocProvider.of<DirectoryBloc>(context)
                  .add(
                    ReadFile(
                      session: widget.session,
                      parentPath: widget.folderPath,
                      filePath: filePath,
                      action: actionPreview
                    ),
                  );
                },
                child: Text('Preview'),
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<DirectoryBloc>(context)
                  .add(
                    ReadFile(
                      session: widget.session,
                      parentPath: widget.folderPath,
                      filePath: filePath,
                      action: actionShare
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