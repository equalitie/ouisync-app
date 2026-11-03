import 'dart:io' as io;
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart'
    show
        AndroidOptions,
        DarwinOptions,
        FilePickerPlatform,
        FilePickerStatus,
        FileType,
        LinuxOptions,
        PlatformFile,
        WebOptions,
        WindowsOptions;

/// After calling this function the FilePicker will pick the file specified by
//`filePath` of the disk.
void fakeFilePickerPicks(String filePath) {
  FilePickerPlatform.instance = _FakeFilePickerPlatform(filePath);
}

/// Fake FilePicker instance that simulates picking the given file.
class _FakeFilePickerPlatform extends FilePickerPlatform {
  _FakeFilePickerPlatform(this.pickedFile);

  final String pickedFile;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => [_FakePlatformFile(pickedFile)];
}

/// Picked file backed by a file on the local disk.
final class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile(String path) : _file = io.File(path);

  final io.File _file;

  @override
  String get name => p.basename(_file.path);

  @override
  Uri get uri => _file.absolute.uri;

  @override
  XFile get xFile => XFile(_file.path);

  @override
  int? lengthSync() => _file.lengthSync();

  @override
  Future<int?> length() => _file.length();

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() =>
      _file.openRead().map(Uint8List.fromList);
}
