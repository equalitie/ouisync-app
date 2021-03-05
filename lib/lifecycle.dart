
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/controls/menu/drawermenu.dart';
import 'package:ouisync_app/app/controls/repo/repocard.dart';
import 'package:ouisync_app/app/models/item/baseitem.dart';
import 'package:ouisync_app/app/models/item/itemtype.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/callbacks/nativecallbacks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/pages/pages.dart';

class LifeCycle extends StatefulWidget {
  final Widget child;

  const LifeCycle({@required this.child});

  @override
  _LifeCycleState createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> 
                      with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    
    NativeCallbacks.doSetup();

    requestPermissions().then((granted) => {
      if (granted) {
        setupRepository()  
      }
    });

    super.initState();
  }

  Future<bool> requestPermissions () async {
    PermissionStatus _permissionStatus = await Permission.storage.status;

    if (_permissionStatus == PermissionStatus.granted) {
      return true;
    }

    if (negativePermissionStatus.contains(_permissionStatus)) {
      await Dialogs.showStoragePermissionNotGrantedDialog(context);
      return false;
    }

    if (_permissionStatus == PermissionStatus.undetermined) {
      await Dialogs.showRequestStoragePermissionDialog(context);

      await Permission.storage.request().then((status) => 
        _permissionStatus = status
      );

      if (_permissionStatus == PermissionStatus.granted) {
        return true;
      }

      await Dialogs.showStoragePermissionNotGrantedDialog(context);
    }

    return false;
  }

  void setupRepository() async {
    Directory repoDir = await getApplicationSupportDirectory();

    String repoPath = '${repoDir.path}/ouisync';
    String folderPath = '$repoPath/blocks';

    print('Repository path:\n$repoPath');

    await printAppFolderContents(repoPath);
    await printAppFolderContents(folderPath);

    print('Initializing Ouisync repo');
    NativeCallbacks.initializeOuisyncRepository(repoPath);

    print("Calling _readDir");
    await _readDir(repoPath, folderPath);

  }

  Future<void> printAppFolderContents(String path) async {
    final Directory _directory = Directory(path);
   
    print('${_directory.path} contents:\n\n');

    var contents = _directory.listSync();
    for (var item in contents) {
      print(item); 
    }
  }


  Future<void> _readDir(String repoPath, String folderPath) async {
    print('Checking storage permissions and executing readDir event -$repoPath, $folderPath'      );
    _getBlocScaffold(context, repoPath, folderPath);
  }

  Scaffold _getBlocScaffold(BuildContext context, String repoPath, String folderPath) {
    BlocProvider.of<DirectoryBloc>(context).add(ContentRequest(repoPath: repoPath, folderPath: folderPath));
    return Scaffold(
      appBar: AppBar(
        title: Text('OuiSync - LifeCycle'),
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
      body: _repos(repoPath, folderPath),
    );
  }

  Widget _repos(String repoPath, String folderPath) {
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

                return _reposList(contents, repoPath, folderPath);
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

  _reposList(List<BaseItem> repos, String repoPath, String folderPath) {
    return ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];
        return RepoCard(
          folderData: repo,
          isEncrypted: false,
          isLocal: true,
          isOwn: true,
          action: () => { _actionByType(repo, repoPath, folderPath) }
        );
      },
    );
  }

  void _actionByType(BaseItem item, String repoPath, String folderPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return item.itemType == ItemType.folder
            ? FolderPage(title: item.name, repoPath: repoPath, folderPath: folderPath)
            : FilePage(title: item.name, data: item);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App Lyfecycle State: $state');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

}