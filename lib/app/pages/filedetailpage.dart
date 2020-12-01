import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/baseitem.dart';

class FileDetailPage extends StatelessWidget {
  final BaseItem data;

  FileDetailPage({
    this.data
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Text(data.name)
      ),
    );
  }

}