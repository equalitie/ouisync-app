import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/item/baseitem.dart';

class FilePage extends StatelessWidget {
  final BaseItem data;

  FilePage({
    this.data
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Folder details for ${data.name}"),
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