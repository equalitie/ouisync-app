import 'package:ouisync_app/app/controls/repo/repofooter.dart';
import 'package:ouisync_app/app/models/item/baseitem.dart';
import 'package:ouisync_app/app/models/item/folderitem.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/models/user/user.dart';
import 'package:ouisync_app/callbacks/nativecallbacks.dart';

class DirectoryRepository {
  List<BaseItem> rootContents = [
    FolderItem("1", "Folder 1", "/folder1", 123.45, SyncStatus.idle, const User(id: "A", name: "Me")),
    FolderItem("2", "Folder 2", "/folder2", 789.01, SyncStatus.syncing, const User(id: "B", name: "Other")),
    FileItem("a", "File 1.txt", "txt", "/", 23.67, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("b", "File 2.txt", "txt", "/", 345.08, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("c", "File 3.txt", "txt", "/", 45676.00, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("d", "File 4.txt", "txt", "/", 32.79, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("e", "File 5.txt", "txt", "/", 267.09, SyncStatus.idle, const User(id: "A", name: "Me")),
  ];

  List<BaseItem> folder1Contents = [
    FileItem("a", "File 6.txt", "txt", "/", 23.67, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("b", "File 7.txt", "txt", "/", 345.08, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("c", "File 8.txt", "txt", "/", 45676.00, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("d", "File 9.txt", "txt", "/", 32.79, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("e", "File 10.txt", "txt", "/", 267.09, SyncStatus.idle, const User(id: "A", name: "Me")),
  ];

  Future<List<BaseItem>> getContents(String path) async {
    List<String> files = await NativeCallbacks.readDirAsync(path);

    return Future
        .delayed(Duration(seconds: 2))
        .then((value) =>
    path == "/"
        ? rootContents
        : folder1Contents
    );
  }
}