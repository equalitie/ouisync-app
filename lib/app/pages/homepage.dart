import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/controls/ouisynclistitem.dart';
import 'package:ouisync_app/app/models/baseitem.dart';
import 'package:ouisync_app/app/models/ouisyncfile.dart';
import 'package:ouisync_app/app/models/ouisyncfolder.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BaseItem> items = List<BaseItem>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return OuiSyncListItem (
                  itemData: item,
                );
              })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewItem,
        tooltip: 'Add new task',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void createNewItem() {
    BaseItem file = OuiSyncFile(
        "1",
        "File 1",
        ["root", "storage", "emulated"],
        11.0,
        "status file 1",
        description: "Description file 1"
    );

    BaseItem folder = OuiSyncFolder(
        "A",
        "Folder 1",
        ["root"],
        120.5,
        "status folder 1",
        description: "Description folder 1"
    );

    setState(() {
      items.add(file);
      items.add(file);
      items.add(file);
      items.add(folder);
    });
  }
}