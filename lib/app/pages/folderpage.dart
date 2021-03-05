import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/controls/controls.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/pages/pages.dart';

class FolderPage extends StatefulWidget {
  FolderPage({Key key, this.title, this.repoPath, this.folderPath}) : super(key: key);

  final String title;
  final String repoPath;
  final String folderPath;

  @override
  _FolderPage createState() => _FolderPage();
}

class _FolderPage extends State<FolderPage> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<DirectoryBloc>(context).add(ContentRequest(repoPath: widget.repoPath, folderPath: widget.folderPath));
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
      body: _repos(),
      //Center(child: Text('test'))
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return item.itemType == ItemType.folder
          ? FolderPage(title: item.name, repoPath: widget.repoPath, folderPath: widget.folderPath)
        : FilePage(title: item.name, data: item);
      }),
    );
  }
}