import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/controls/controls.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/pages/pages.dart';
import 'package:ouisync_app/callbacks/nativecallbacks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  List<PermissionStatus> _negativePermissions = [
    PermissionStatus.restricted,
    PermissionStatus.limited,
    PermissionStatus.denied,
    PermissionStatus.permanentlyDenied,
  ];

  @override
  void initState() {
    super.initState();

    NativeCallbacks.doSetup();
    WidgetsBinding.instance.addPostFrameCallback(onLayoutDone);
  }

  void onLayoutDone(Duration timeStamp) async {
    await printAppFolderContents();

    PermissionStatus _permissionStatus = await Permission.storage.status;

    if (_negativePermissions.contains(_permissionStatus)) {
      await _showStoragePermissionNotGrantedDialog();
      return;
    }

    Directory directory = await getApplicationSupportDirectory();

    if (_permissionStatus == PermissionStatus.granted) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => _getBlocScaffold(context, directory.path)
        )
      );
      
      return;
    }

    if (_permissionStatus == PermissionStatus.undetermined) {
      await _showRequestStoragePermissionDialog().whenComplete(() async => {
        await Permission.storage.request().then((value) async => {
          if (value != PermissionStatus.granted) {
            await _showStoragePermissionNotGrantedDialog()
          } else {
             Navigator.push(
               context, 
               MaterialPageRoute(
                 builder: (context) => _getBlocScaffold(context, directory.path)
                )
              )
          }
        })
      });
    }
  }

  Future<void> printAppFolderContents() async {
    final Directory _directory = await getApplicationSupportDirectory();
   
    print('${_directory.path} contents:\n\n');

    var contents = _directory.listSync();
    for (var item in contents) {
      print(item); 
    }
  }

  Future<void> _showRequestStoragePermissionDialog() async {
    Text title = Text('OuiSync - Storage permission needed');
    Text message = Text('Ouisync need access to the phone storage to operate properly.\n\nPlease accept the permissions request');
    
    await _permissionDialog(title, message);
  }

  Future<void> _showStoragePermissionNotGrantedDialog() async {
    Text title = Text('OuiSync - Storage permission not granted');
    Text message = Text('Ouisync need access to the phone storage to operate properly.\n\nWithout this permission the app won\'t work.');
    
    await _permissionDialog(title, message);
  }

   Future<void> _permissionDialog(Widget title, Widget message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget> [
               message, 
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'OuiSync',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold
              ),),
            ),
        ],
      ),
    );
  }

  Scaffold _getBlocScaffold(BuildContext context, String path) {
    BlocProvider.of<DirectoryBloc>(context).add(ContentRequest(path: path));
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

                return _reposList(contents);
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

  _reposList(List<BaseItem> repos) {
    return ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];
        return RepoCard(
          folderData: repo,
          isEncrypted: false,
          isLocal: true,
          isOwn: true,
          action: () => { _actionByType(repo) }
        );
      },
    );
  }

  void _actionByType(BaseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return item.itemType == ItemType.folder
            ? FolderPage(title: item.name, path: item.path)
            : FilePage(title: item.name, data: item);
      }),
    );
  }
}