import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../bloc/blocs.dart';
import '../data/data.dart';

class FilePage extends StatefulWidget {
  FilePage({
    required this.session,
    required this.foldersRepository,
    required this.path,
    required this.name,
    required this.size,
    required this.title,
  });

  final Session session;
  final DirectoryRepository foldersRepository;
  final String path;
  final String name;
  final int size;
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
      body: _fileInfo()//_blocBody(),
    );
  }

  _blocBody() {
    return BlocListener<DirectoryBloc, DirectoryState> (
      listener: (context, state) async {
        if (state is DirectoryLoadSuccess) {
          if (state.contents.isEmpty) {
            print('The file ${widget.title} is empty');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('The file ${widget.title} is empty'),
                action: SnackBarAction(
                  label: 'HIDE',
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()
                ),
              ),  
            );
            
            return;
          }

          //Use this for getting the dfile metadadta. Initially the size, for passing to the content provider.
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
                widget.name,
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
                widget.path
                .replaceAll(widget.title, '')
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
                formattSize(widget.size, units: true),
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
                onPressed: () async =>
                  await NativeChannels.previewOuiSyncFile(widget.path, widget.size),
                child: Text('Preview'),
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: () async =>
                  await NativeChannels.shareOuiSyncFile(widget.path, widget.size),
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