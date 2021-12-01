import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Widget size(Repository repository, String path) {
    return FutureBuilder<String>(
      future: getFileSize(repository, path),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text(
            '? B',
            style: const TextStyle(fontSize: 14.0),
          );
        }

        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
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

  Future<String> getFileSize(Repository repository, String path) async {
    // This delay is needed for now, otherwise the library will return null several times, before returning the actual value
    // and finish the state update. This occurs while the synchronization is on.
    await Future.delayed(Duration(seconds: 2));
    print('${DateTime.now()} | Getting size for file $path');
    final length = await EntryInfo(repository).fileLength(path);

    print('${DateTime.now()} | $path size: $length');
    return formattSize(length, units: true);
  }
}