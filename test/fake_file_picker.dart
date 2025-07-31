import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart'
    show FilePicker, FilePickerResult, FileType, FilePickerStatus, PlatformFile;

/// After calling this function the FilePicker will pick the file specified by
//`filePath` of the disk.
void fakeFilePickerPicks(String filePath) {
  FilePicker.platform = _FakeFilePicker(filePath);
}

/// Fake FilePicker instance that simulates picking the given file.
class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.pickedFile);

  final String pickedFile;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
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
