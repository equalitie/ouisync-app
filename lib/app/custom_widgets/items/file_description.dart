import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/utils/entry_info.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatefulWidget {
  const FileDescription({
    required this.repository,
    required this.fileData,
  });

  final Repository repository;
  final BaseItem fileData;

  @override
  State<StatefulWidget> createState() => _FileDescription();
}

class _FileDescription extends State<FileDescription> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Text(
            widget.fileData.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          size(widget.fileData.path)
        ],
      ),
    );
  }

  Widget size(path) {
    return FutureBuilder<String>(
      future: getFileSize(path),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text(
            '?',
            style: const TextStyle(fontSize: 14.0),
          );
        }

        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: const TextStyle(fontSize: 14.0),
          );
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }

  Future<String> getFileSize(path) async {
    // TODO: Check if this delay is still needed (This delay was here because without it, the library would hang) 
    // await Future.delayed(Duration(seconds: 2));

    final length = await EntryInfo(widget.repository).fileLength(path);
    return formattSize(length, units: true);
  }

}