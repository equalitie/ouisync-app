import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/models.dart';

class FilePage extends StatefulWidget {
  FilePage({Key key, this.title, this.data});

  final String title;
  final BaseItem data;

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
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Folder details for ${widget.data.name}"),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Pop!")
              ),
            ],
          )
      ),
    );
  }
}