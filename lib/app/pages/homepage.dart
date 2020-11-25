import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/controls/ouisynclistitem.dart';
import 'package:ouisync_app/app/models/baseitem.dart';
import 'package:ouisync_app/app/models/ouisyncfile.dart';
import 'package:ouisync_app/app/models/ouisyncfolder.dart';
import 'package:ouisync_app/app/pages/folderdetailpage.dart';
import 'package:ouisync_app/cpp/native_add.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BaseItem> items = List<BaseItem>();

  @override
  void initState() {
    super.initState();
    setState(() {
      items.add(
          OuiSyncFolder(
              "A",
              "Folder 1",
              ["root"],
              120.5,
              "status folder 1",
              description: "Description folder 1"
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // child: Text('1 + 2 == ${nativeAdd(1, 2)}'),
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return OuiSyncListItem (
                  itemData: item,
                  action: () => { _actionByType(item) }
                );
              })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: items.length.isOdd ? createNewFolder : createNewFile,
        tooltip: 'Add new repository or file',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _actionByType(BaseItem item) {
    item.type == OSType.folder
        ? navigateToFolderDetail(item)
        : createNewFile();
  }

  void navigateToFolderDetail(BaseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return FolderDetailPage(data: item);
      }),
    );
  }

  void createNewFolder() {
    BaseItem folder = OuiSyncFolder(
        "A",
        "Folder 1",
        ["root"],
        120.5,
        "status folder 1",
        description: "Description folder 1"
    );

    setState(() {
      items.add(folder);
    });
  }

  void createNewFile() {
    BaseItem file = OuiSyncFile(
        "1",
        "File 1",
        ["root", "storage", "emulated"],
        11.0,
        "status file 1",
        description: "Description file 1"
    );

    setState(() {
      items.add(file);
    });
  }
}