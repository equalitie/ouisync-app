import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget {
  const FileDescription({
    required this.repository,
    required this.fileData,
  });

  final Repository repository;
  final BaseItem fileData;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Text(
            fileData.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          size(repository, fileData.path)
        ],
      ),
    );
  }

  Widget size(repository, path) {
    return FutureBuilder<int>(
      initialData: 0,
      future: EntryInfo(repository).fileLength(path),
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasError) {
          return Text(
            '? B',
            style: const TextStyle(fontSize: 14.0),
          );
        }

        if (snapshot.hasData) {
          return Text(
            formattSize(snapshot.data ?? 0, units: true),
            style: const TextStyle(fontSize: 14.0),
          );
        }

        return Container(
          height: 15.0,
          width: 15.0,
          child: CircularProgressIndicator(strokeWidth: 2.0,)
        );
      }
    );
  }
}