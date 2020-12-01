import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/controls/ouisynclistitem.dart';
import 'package:ouisync_app/app/models/baseitem.dart';
import 'package:ouisync_app/app/models/ouisyncfile.dart';
import 'package:ouisync_app/app/models/ouisyncfolder.dart';
import 'package:ouisync_app/app/pages/folderdetailpage.dart';
import 'package:ouisync_app/app/widgets/menudrawer.dart';
import 'package:ouisync_app/app/widgets/offsetpopup.dart';

import 'filedetailpage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BaseItem> items = List<BaseItem>();

  List<String> branches;
  String _selectedBranch;

  @override
  void initState() {
    super.initState();

    // NativeCallbacks.doSetup();
    loadBranches();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(children: _buildBranchesBar()),
          Divider(),
          Expanded(child: _buildItemsListView()),
          _buildPopupMenuButton(),
        ]
      ),
      drawer: MenuDrawer(),
      //floatingActionButton: _buildFloatingActionButton(),
      persistentFooterButtons: _buildPersistentFooterButtons(),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> _buildBranchesBar() {
    return <Widget>[
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.alt_route),
              Text("Branches ")
            ],
          )
      ),
      Expanded(child: _buildBranchesDropDownButton()),
    ];
  }

  DropdownButton<String> _buildBranchesDropDownButton() {
    return DropdownButton(
        value: _selectedBranch,
        isExpanded: true,
        items: branches.map((value) => DropdownMenuItem(
            value: value,
            child: Text(value)
        )).toList(),
        onChanged: (value) {
          setState(() {
            _selectedBranch = value;
            loadItemsBranch(value);
          });
        },
    );
  }

  ListView _buildItemsListView() {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return OuiSyncListItem (
            itemData: item,
            action: () => { _navigateToDetail(item) }
          );
        });
  }

  void _navigateToDetail(BaseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return item.type == OSType.folder
            ? FolderDetailPage(data: item)
            : FileDetailPage(data: item);
      }),
    );
  }

  Container _buildPopupMenuButton() {
    return Container(
        padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
                height: 80.0,
                width: 80.0,
                child: OffsetPopup()
            )
        )
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      tooltip: 'Add branches, folders, files or links to branches',
      child: Icon(Icons.add),
    );
  }

  List<Widget> _buildPersistentFooterButtons() {
    return <Widget>[
      Text("syncing"),
      RaisedButton(
        elevation: 2.0,
        onPressed: () {},
        color: Colors.green,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white, width: 1),
        ),
        child: Icon(
          Icons.sync,
          color: Colors.white,
        ),
      ),
      Text("network"),
      RaisedButton(
        elevation: 2.0,
        onPressed: () {},
        color: Colors.blue,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white, width: 1),
        ),
        child: Icon(
          Icons.network_wifi,
          color: Colors.white,
        ),
      ),
    ];
  }

  void loadItemsBranch(String branch) {
    items.clear();

    switch (branch) {
      case "branch 1":
        {
          items.add(OuiSyncFolder(
              "A",
              "Folder 1",
              ["root"],
              120.5,
              "status folder 1",
              description: "Description folder 1"
          ));

          items.add(OuiSyncFolder(
              "B",
              "Folder 2",
              ["root"],
              120.5,
              "status folder 2",
              description: "Description folder 2"
          ));

          items.add(OuiSyncFile(
              "1",
              "File 1",
              ["root", "temp"],
              15.5,
              "status file 1")
          );

          items.add(OuiSyncFile(
              "2",
              "File 2",
              ["root", "temp"],
              15.5,
              "status file 2")
          );

          items.add(OuiSyncFile(
              "3",
              "File 3",
              ["root", "temp"],
              15.5,
              "status file 3")
          );

          items.add(OuiSyncFile(
              "4",
              "File 4",
              ["root", "temp"],
              15.5,
              "status file 4")
          );

          items.add(OuiSyncFile(
              "5",
              "File 5",
              ["root", "temp"],
              15.5,
              "status file 5")
          );

          items.add(OuiSyncFile(
              "6",
              "File 6",
              ["root", "temp"],
              15.5,
              "status file 6")
          );

          items.add(OuiSyncFile(
              "7",
              "File 7",
              ["root", "temp"],
              15.5,
              "status file 7")
          );
        }
        break;
      case "branch 2":
        {
          items.add(OuiSyncFolder(
              "C",
              "Folder 3",
              ["root"],
              120.5,
              "status folder 3",
              description: "Description folder 3"
          ));

          items.add(OuiSyncFile(
              "8",
              "File 8",
              ["root", "temp"],
              15.5,
              "status file 8")
          );
          items.add(OuiSyncFile(
              "9",
              "File 9",
              ["root", "temp"],
              15.5,
              "status file 9")
          );
          items.add(OuiSyncFile(
              "10",
              "File 10",
              ["root", "temp"],
              15.5,
              "status file 10")
          );
          items.add(OuiSyncFile(
              "11",
              "File 11",
              ["root", "temp"],
              15.5,
              "status file 11")
          );
        }
        break;
      default:
        items.clear();
        break;
    }

  }

  void loadBranches() {
    branches = ["branch 1", "branch 2"];
  }
}