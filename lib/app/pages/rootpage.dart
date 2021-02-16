import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/controls/items/listitem.dart';
import 'package:ouisync_app/app/controls/menu/drawermenu.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/pages/filepage.dart';
import 'package:ouisync_app/app/pages/folderpage.dart';
import 'package:ouisync_app/callbacks/nativecallbacks.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();

    NativeCallbacks.doSetup();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<DirectoryBloc>(context).add(ContentRequest(path: "/"));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {

            },
          )
        ]
      ),
      drawer: Drawer(
        child: Center(child: DrawerMenu()),
      ),
      body: _repos(),
    );
  }

  Widget _repos() {
    return Center(
        child: BlocBuilder<DirectoryBloc, DirectoryState>(
            builder: (context, state) {
              if (state is DirectoryInitial) {
                return Center(child: Text('Loading root directory contents...'));
              }

              if (state is DirectoryLoadInProgress){
                return Center(child: CircularProgressIndicator());
              }

              if (state is DirectoryLoadSuccess) {
                final contents = state.contents;

                return _contentsList(contents);
              }

              if (state is DirectoryLoadFailure) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }

              return Center(child: Text('root'));
            }
        )
    );
  }

  _contentsList(List<BaseItem> contents) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.transparent
        ),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final item = contents[index];
          return ListItem (
              itemData: item,
              action: () => { _actionByType(item) }
          );
        }
    );
  }

  void _actionByType(BaseItem item) {
    if (item.itemType == ItemType.folder) {
      navigateToFolderDetail(item);
    }
  }

  void navigateToFolderDetail(BaseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return FolderPage(title: item.name, path: item.path);
      }),
    );
  }

  void navigateToFileDetail(BaseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return FilePage(data: item);
      }),
    );
  }
}