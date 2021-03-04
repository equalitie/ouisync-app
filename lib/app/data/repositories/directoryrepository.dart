import 'package:ouisync_app/app/controls/controls.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/callbacks/nativecallbacks.dart';

class DirectoryRepository {
  List<BaseItem> repos = [
    FolderItem("0", "Repo XYZ", "/repo XYZ", 12.45, SyncStatus.idle, const User(id: "A", name: "Me")),
  ];

  List<BaseItem> repoXYZContents = [
    FolderItem("1", "Folder 1", "/repo XYZ/folder 1", 123.45, SyncStatus.idle, const User(id: "A", name: "Me")),
    FolderItem("2", "Folder 2", "/repo XYZ/folder 2", 789.01, SyncStatus.syncing, const User(id: "B", name: "Other")),
    FileItem("a", "File 1.txt", "txt", "/repo XYZ/File 1.txt", 23.67, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("b", "File 2.txt", "txt", "/repo XYZ/File 2.txt", 345.08, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("c", "File 3.txt", "txt", "/repo XYZ/File 3.txt", 45676.00, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("d", "File 4.txt", "txt", "/repo XYZ/File 4.txt", 32.79, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("e", "File 5.txt", "txt", "/repo XYZ/File 5.txt", 267.09, SyncStatus.idle, const User(id: "A", name: "Me")),
  ];

  List<BaseItem> folder1Contents = [
    FolderItem("1", "Folder 3", "/repo XYZ/folder 1/folder 3", 123.45, SyncStatus.idle, const User(id: "A", name: "Me")),
    FolderItem("2", "Folder 4", "/repo XYZ/folder 1/folder 4", 789.01, SyncStatus.syncing, const User(id: "B", name: "Other")),
    FileItem("a", "File 6.txt", "txt", "/repo XYZ/folder 1/File 6.txt", 23.67, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("b", "File 7.txt", "txt", "/repo XYZ/folder 1/File 7.txt", 345.08, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("c", "File 8.txt", "txt", "/repo XYZ/folder 1/File 8.txt", 45676.00, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("d", "File 9.txt", "txt", "/repo XYZ/folder 1/File 9.txt", 32.79, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("e", "File 10.txt", "txt", "/repo XYZ/folder 1/File 10.txt", 267.09, SyncStatus.idle, const User(id: "A", name: "Me")),
  ];

  List<BaseItem> folder2Contents = [
    FileItem("a", "File 11.txt", "txt", "/repo XYZ/folder 2/File 11.txt", 23.67, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("b", "File 12.txt", "txt", "/repo XYZ/folder 2/File 12.txt", 345.08, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("c", "File 13.txt", "txt", "/repo XYZ/folder 2/File 13.txt", 45676.00, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("d", "File 14.txt", "txt", "/repo XYZ/folder 2/File 14.txt", 32.79, SyncStatus.idle, const User(id: "A", name: "Me")),
    FileItem("e", "File 15.txt", "txt", "/repo XYZ/folder 2/File 15.txt", 267.09, SyncStatus.idle, const User(id: "A", name: "Me")),
  ];

  Future<List<BaseItem>> getContents(String repoDir, String folderPath) async {
    print("About to call readDirAsync...");
    
    List<dynamic> files;
    
    await NativeCallbacks.readDirAsync(repoDir, folderPath)
    .catchError((onError) {
      print('Error on readDirAsync call: $onError');
    })
    .then((value) => {
        print('readDirAsync returned ${value.length} items'),
        files = value
    })
    .whenComplete(() => {
      print('readDirAsync completed')
    });
    
    print("Files returned: " + files.toString());

    // repoDir = "/";

    // return Future
    //     .delayed(Duration(seconds: 2))
    //     .then((value) =>
    // repoDir == "/"
    //     ? repos
    //     : repoDir == "/repo XYZ"
    //     ? repoXYZContents
    //     : repoDir == "/repo XYZ/folder 1"
    //     ? folder1Contents
    //     : repoDir == "/repo XYZ/folder 2"
    //     ? folder2Contents
    //     : []
    // );
  }
}