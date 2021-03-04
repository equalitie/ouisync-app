import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const appRootDirectory = "/data/user/0/com.equalitie.ouisync_app/files";
const appDefaultFolder = "$appRootDirectory/branches";

const List<PermissionStatus> negativePermissionStatus = [
    PermissionStatus.restricted,
    PermissionStatus.limited,
    PermissionStatus.denied,
    PermissionStatus.permanentlyDenied,
  ];