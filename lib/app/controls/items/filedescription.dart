import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/item/fileitem.dart';

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

  List<Widget> _getUI() {
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
        "size: ${_formattSize(this.fileData.size)}",
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

  String _formattSize(double size, { int decimals = 2 }) {
    print('size: $size\n');
    final units = ['b', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = 0.0;
    var h = 0.0;

    final kb = 1 / 1024; // change it to 1024 and see the diff

    for (; h < kb && i < units.length; i++) {
      if ((h = pow(1024, i) / size) >= kb) {
        break;
      }
    }

    return (1 / h).toStringAsFixed(decimals) + " " + units[i.toInt()];
  }
}