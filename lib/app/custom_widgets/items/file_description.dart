import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget {
  FileDescription({
    required this.repository,
    required this.fileData,
  });

  final Repository repository;
  final BaseItem fileData;

  final ValueNotifier<String> _size = ValueNotifier<String>('-');

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Fields.constrainedText(
            fileData.name,
            flex: 0,
            softWrap: true
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          size(repository, fileData.path)
        ],
      ),
    );
  }

  Widget size(repository, path){
    return FutureBuilder<int>(
      future: EntryInfo(repository).fileLength(path),
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasError) {
          return Fields.constrainedText(
            '? B',
            flex: 0,
            fontSize: Dimensions.fontSmall,
            fontWeight: FontWeight.w400,
            softWrap: true
          );
        }

        if (snapshot.hasData) {
          return Fields.constrainedText(
            formattSize(snapshot.data ?? 0, units: true),
            flex: 0,
            fontSize: Dimensions.fontSmall,
            fontWeight: FontWeight.w400,
            softWrap: true
          );
        }

        return Container(
          height: Dimensions.sizeCircularProgressIndicatorSmall.height,
          width: Dimensions.sizeCircularProgressIndicatorSmall.width,
          child: CircularProgressIndicator(strokeWidth: 2.0,)
        );
      }
    );
  }
}