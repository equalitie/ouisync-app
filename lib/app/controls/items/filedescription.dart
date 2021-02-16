import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/item/fileitem.dart';
import 'package:ouisync_app/app/utils/descriptions.dart';

class FileDescription extends StatelessWidget {
  const FileDescription({
    Key key,
    this.fileData,
  }) : super(key: key);

  final FileItem fileData;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  _getUI(),
      ),
    );
  }

  List<Widget> _getUI(){
    return [
      Text(
        this.fileData.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
      Text(
        "sync: ${Descriptions.getSyncStatusDescription(this.fileData.syncStatus)}",
        style: const TextStyle(fontSize: 12.0),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
      Text(
          this.fileData.path.length == 0
              ? "-"
              : this.fileData.path,
          style: const TextStyle(fontSize: 12.0)
      ),
    ];
  }
}