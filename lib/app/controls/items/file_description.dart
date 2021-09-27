import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    File? file;
    try {
      await Future.delayed(Duration(seconds: 2));

      file = await File.open(widget.repository, path);
      final size = await file.length;

      return formattSize(size, units: true);
    } catch (e) {
      print('Exception getting the file size ($path):\n${e.toString()}');
    }
    finally {
      if (file != null) {
       file.close(); 
      }
    }

    return '0.0 B';
  }

}