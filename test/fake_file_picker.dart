import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart'
    show
        FilePickerResult,
        FileType,
        FilePickerStatus,
        PlatformFile,
        AndroidSAFOptions,
        FilePickerPlatform;

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
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
    AndroidSAFOptions? androidSafOptions,
  }) async {
    final name = p.basename(pickedFile);
    final file = io.File(pickedFile);
    final size = await file.length();
    final readStream = file.openRead();

    return FilePickerResult([
      PlatformFile(
        path: pickedFile,
        name: name,
        size: size,
        readStream: readStream,
      ),
    ]);
  }
}
