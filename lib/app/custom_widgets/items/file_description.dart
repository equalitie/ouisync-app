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

  final ValueNotifier<int> _fileSize = ValueNotifier<int>(0);

  Future<int> getFileSize() async {
    final length = await EntryInfo(repository).fileLength(fileData.path);
    return length;
  }

  @override
  Widget build(BuildContext context) {
    getFileSize()
    .then((formattedSize) {
      _fileSize.value = formattedSize;
    });

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
          ValueListenableBuilder(
            valueListenable: _fileSize,
            builder: (context, length, widget) {
              if ((length as int) <= 0) {
                return Container(
                  height: Dimensions.sizeCircularProgressIndicatorSmall.height,
                  width: Dimensions.sizeCircularProgressIndicatorSmall.width,
                  child: CircularProgressIndicator(
                    strokeWidth: Dimensions.strokeCircularProgressIndicatorSmall,
                  )
                );
              }
            
              final fileSize = formattSize(length, units: true);
              return Fields.constrainedText(
                fileSize,
                flex: 0,
                fontSize: Dimensions.fontSmall,
                fontWeight: FontWeight.w400,
                softWrap: true
              );
            }
          )
        ],
      ),
    );
  }
}