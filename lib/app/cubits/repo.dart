// ignore_for_file: unnecessary_overrides

import 'dart:async';
import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'job.dart';

class RepoState extends Equatable {
  final bool isLoading;
  final Map<String, Job> uploads;
  final Map<String, Job> downloads;
  final String message;
  final bool isDhtEnabled;
  final bool isPexEnabled;
  final bool requestPassword;
  final String
      authenticationMode; // manual, version1 (built in biometrics validation on package biometrics_storage), version2 (local_atuh for biometric validation), no local password
  final oui.AccessMode accessMode;
  final String infoHash;
  final FolderState currentFolder;

  RepoState({
    this.isLoading = false,
    this.uploads = const {},
    this.downloads = const {},
    this.message = "",
    this.isDhtEnabled = false,
    this.isPexEnabled = false,
    this.requestPassword = false,
    this.authenticationMode = "",
    this.infoHash = "",
    this.accessMode = oui.AccessMode.blind,
    this.currentFolder = const FolderState(),
  });

  RepoState copyWith({
    bool? isLoading,
    Map<String, Job>? uploads,
    Map<String, Job>? downloads,
    String? message,
    bool? isDhtEnabled,
    bool? isPexEnabled,
    bool? requestPassword,
    String? authenticationMode,
    oui.AccessMode? accessMode,
    String? infoHash,
    FolderState? currentFolder,
  }) =>
      RepoState(
        isLoading: isLoading ?? this.isLoading,
        uploads: uploads ?? this.uploads,
        downloads: downloads ?? this.downloads,
        message: message ?? this.message,
        isDhtEnabled: isDhtEnabled ?? this.isDhtEnabled,
        isPexEnabled: isPexEnabled ?? this.isPexEnabled,
        requestPassword: requestPassword ?? this.requestPassword,
        authenticationMode: authenticationMode ?? this.authenticationMode,
        accessMode: accessMode ?? this.accessMode,
        infoHash: infoHash ?? this.infoHash,
        currentFolder: currentFolder ?? this.currentFolder,
      );

  @override
  List<Object?> get props => [
        isLoading,
        uploads,
        downloads,
        message,
        isDhtEnabled,
        isPexEnabled,
        requestPassword,
        authenticationMode,
        accessMode,
        infoHash,
        currentFolder,
      ];

  bool get canRead => accessMode != oui.AccessMode.blind;
  bool get canWrite => accessMode == oui.AccessMode.write;
}

class RepoCubit extends Cubit<RepoState> with OuiSyncAppLogger {
  final Folder _currentFolder = Folder();
  final SettingsRepoEntry _settingsRepoEntry;
  final oui.Repository _handle;
  final Settings _settings;

  RepoCubit._(
    this._settingsRepoEntry,
    this._handle,
    this._settings,
    RepoState state,
  ) : super(state) {
    _currentFolder.repo = this;
  }

  static Future<RepoCubit> create({
    required SettingsRepoEntry settingsRepoEntry,
    required oui.Repository handle,
    required Settings settings,
  }) async {
    var state = RepoState();
    var name = settingsRepoEntry.name;

    // Migrate settings
    final legacyDhtEnabled = settings.takeRepositoryBool(name, 'DHT_ENABLED');
    if (legacyDhtEnabled != null) {
      await handle.setDhtEnabled(legacyDhtEnabled);
    }

    final legacyPexEnabled = settings.takeRepositoryBool(name, 'PEX_ENABLED');
    if (legacyPexEnabled != null) {
      await handle.setPexEnabled(legacyPexEnabled);
    }

    final authMode =
        settings.getAuthenticationMode(name) ?? Constants.authModeVersion1;

    state = state.copyWith(
        infoHash: await handle.infoHash,
        accessMode: await handle.accessMode,
        isDhtEnabled: await handle.isDhtEnabled,
        isPexEnabled: await handle.isPexEnabled,
        authenticationMode: authMode);

    return RepoCubit._(settingsRepoEntry, handle, settings, state);
  }

  oui.Repository get handle => _handle;
  String get databaseId => _settingsRepoEntry.databaseId;
  String get name => _settingsRepoEntry.name;
  RepoMetaInfo get metaInfo => _settingsRepoEntry.info;
  SettingsRepoEntry get settingsRepoEntry => _settingsRepoEntry;

  Future<void> setDhtEnabled(bool value) async {
    if (state.isDhtEnabled == value) {
      return;
    }

    await _handle.setDhtEnabled(value);

    emit(state.copyWith(isDhtEnabled: value));
  }

  Future<void> setPexEnabled(bool value) async {
    if (state.isPexEnabled == value) {
      return;
    }

    await _handle.setPexEnabled(value);

    emit(state.copyWith(isPexEnabled: value));
  }

  Future<oui.Directory> openDirectory(String path) async {
    return await oui.Directory.open(_handle, path);
  }

  Future<void> setAuthenticationMode(String value) async {
    if (state.authenticationMode == value) {
      return;
    }

    await _settings.setAuthenticationMode(name, value);

    emit(state.copyWith(authenticationMode: value));
  }

  // This operator is required for the DropdownMenuButton to show entries properly.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoCubit && state.infoHash == other.state.infoHash;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

  Future<oui.ShareToken> createShareToken(
    oui.AccessMode accessMode, {
    String? password,
  }) async {
    return await _handle.createShareToken(
      accessMode: accessMode,
      name: name,
      password: password,
    );
  }

  Future<bool> exists(String path) async {
    return await _handle.exists(path);
  }

  Future<oui.EntryType?> type(String path) => _handle.type(path);

  Future<oui.Progress> get syncProgress => _handle.syncProgress;

  // Get the state monitor of this particular repository. That is 'root >
  // Repositories > this repository ID'.
  StateMonitor get stateMonitor => _handle.stateMonitor;

  Future<void> navigateTo(String destination) async {
    emit(state.copyWith(isLoading: true));

    _currentFolder.goTo(destination);
    await refresh();

    emit(state.copyWith(isLoading: false));
  }

  Future<bool> createFolder(String folderPath) async {
    emit(state.copyWith(isLoading: true));

    try {
      await oui.Directory.create(_handle, folderPath);
      _currentFolder.goTo(folderPath);
      return true;
    } catch (e, st) {
      loggy.app('Directory $folderPath creation failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<bool> deleteFolder(String path, bool recursive) async {
    emit(state.copyWith(isLoading: true));

    try {
      await oui.Directory.remove(_handle, path, recursive: recursive);
      return true;
    } catch (e, st) {
      loggy.app('Directory $path deletion failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<void> saveFile(
      {required String filePath,
      required int length,
      required Stream<List<int>> fileByteStream,
      oui.File? currentFile}) async {
    if (state.uploads.containsKey(filePath)) {
      showMessage(S.current.messageFileIsDownloading);
      return;
    }

    final file = currentFile ?? await _createFile(filePath);

    if (file == null) {
      showMessage(S.current.messageNewFileError(filePath));
      return;
    }

    final job = Job(0, length);
    emit(state.copyWith(uploads: state.uploads.withAdded(filePath, job)));

    await refresh();

    // TODO: We should try to remove the file in case of exception or user cancellation.

    try {
      int offset = 0;
      final stream = fileByteStream.takeWhile((_) => job.state.cancel == false);

      await for (final buffer in stream) {
        await file.write(offset, buffer);
        offset += buffer.length;
        job.update(offset);
      }
    } catch (e) {
      showMessage(S.current.messageWritingFileError(filePath));
      return;
    } finally {
      await file.close();
      await refresh();

      emit(state.copyWith(uploads: state.uploads.withRemoved(filePath)));
    }

    if (job.state.cancel) {
      showMessage(S.current.messageWritingFileCanceled(filePath));
    }
  }

  Future<void> replaceFile(
      {required String filePath,
      required int length,
      required Stream<List<int>> fileByteStream}) async {
    final file = await _openFile(filePath);

    if (file == null) {
      showMessage('Error opening file $filePath');
      return;
    }

    await file.truncate(length);

    await saveFile(
        filePath: filePath,
        length: length,
        fileByteStream: fileByteStream,
        currentFile: file);
  }

  Future<List<BaseItem>> getFolderContents(String path) async {
    String? error;

    final content = <BaseItem>[];

    // If the directory does not exist, the following command will throw.
    final directory = await oui.Directory.open(_handle, path);
    final iterator = directory.iterator;

    try {
      while (iterator.moveNext()) {
        var size = 0;
        final entryName = iterator.current.name;
        final entryType = iterator.current.entryType;
        final entryPath = buildDestinationPath(path, entryName);

        if (entryType == oui.EntryType.file) {
          size = await _getFileSize(entryPath);
          content.add(FileItem(name: entryName, path: entryPath, size: size));
        }

        if (entryType == oui.EntryType.directory) {
          content.add(FolderItem(name: entryName, path: entryPath));
        }
      }
    } catch (e, st) {
      loggy.app('Traversing directory $path exception', e, st);
      error = e.toString();
    }

    if (error != null) {
      throw error;
    }

    return content;
  }

  Future<bool> setReadWritePassword(
    RepoMetaInfo info,
    String oldPassword,
    String newPassword,
    oui.ShareToken? shareToken,
  ) async {
    final name = info.name;

    try {
      await _handle.setReadWriteAccess(
        oldPassword: oldPassword,
        newPassword: newPassword,
        shareToken: shareToken,
      );
    } catch (e, st) {
      loggy.app('Password change for repository $name failed', e, st);
      return false;
    }

    // TODO: should we update state.accessMode here ?

    return true;
  }

  Future<bool> setReadPassword(
    RepoMetaInfo info,
    String newPassword,
    oui.ShareToken? shareToken,
  ) async {
    final name = info.name;

    try {
      await _handle.setReadAccess(
        newPassword: newPassword,
        shareToken: shareToken,
      );
    } catch (e, st) {
      loggy.app('Password change for repository $name failed', e, st);
      return false;
    }

    // TODO: should we update state.accessMode here ?

    return true;
  }

  Future<int> _getFileSize(String path) async {
    oui.File file;
    var length = 0;

    try {
      file = await oui.File.open(_handle, path);
    } catch (e, st) {
      loggy.app("Open file $path exception (getFileSize)", e, st);
      return length;
    }

    try {
      length = await file.length;
    } catch (e, st) {
      loggy.app("Get file size $path exception", e, st);
    }

    await file.close();

    return length;
  }

  Future<void> downloadFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    if (state.downloads.containsKey(sourcePath)) {
      showMessage(S.current.messageFileIsDownloading);
      return;
    }

    final ouisyncFile = await oui.File.open(_handle, sourcePath);
    final length = await ouisyncFile.length;

    final newFile = io.File(destinationPath);

    // TODO: This fails if the file exists, we should ask the user to confirm if they want to overwrite
    // the existing file.
    final sink = newFile.openWrite();
    int offset = 0;

    final job = Job(0, length);
    emit(state.copyWith(downloads: state.downloads.withAdded(sourcePath, job)));

    try {
      while (job.state.cancel == false) {
        late List<int> chunk;

        await Future.wait([
          ouisyncFile.read(offset, Constants.bufferSize).then((ch) {
            chunk = ch;
          }),
          sink.flush()
        ]);

        offset += chunk.length;

        sink.add(chunk);

        if (chunk.length < Constants.bufferSize) {
          break;
        }

        job.update(offset);
      }
    } catch (e, st) {
      loggy.app('Download file $sourcePath exception', e, st);
      showMessage(S.current.messageDownloadingFileError(sourcePath));
    } finally {
      emit(state.copyWith(downloads: state.downloads.withRemoved(sourcePath)));

      await Future.wait(
          [sink.flush().then((_) => sink.close()), ouisyncFile.close()]);
    }
  }

  Future<bool> moveEntry({
    required String source,
    required String destination,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _handle.move(source, destination);
      return true;
    } catch (e, st) {
      loggy.app('Move entry from $source to $destination failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<bool> deleteFile(String filePath) async {
    emit(state.copyWith(isLoading: true));

    try {
      await oui.File.remove(_handle, filePath);
      return true;
    } catch (e, st) {
      loggy.app('Delete file $filePath failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<void> refresh() async {
    final path = state.currentFolder.path;
    bool errorShown = false;

    try {
      while (state.canRead) {
        bool success = await _currentFolder.refresh();

        if (success) break;
        if (_currentFolder.state.isRoot) break;

        _currentFolder.goUp();

        if (!errorShown) {
          errorShown = true;
          showMessage(S.current.messageErrorCurrentPathMissing(path));
        }
      }
    } catch (e) {
      showMessage(e.toString());
    }

    emit(state.copyWith(
      currentFolder: _currentFolder.state,
      isLoading: false,
    ));
  }

  StreamSubscription<void> autoRefresh() =>
      _handle.events.listen((_) => refresh());

  void showMessage(String message) {
    emit(state.copyWith(message: message));
  }

  Future<oui.File?> _createFile(String newFilePath) async {
    oui.File? newFile;

    try {
      newFile = await oui.File.create(_handle, newFilePath);
    } catch (e, st) {
      loggy.app('File creation $newFilePath failed', e, st);
    }

    return newFile;
  }

  Future<oui.File?> _openFile(String filePath) async {
    oui.File? file;

    try {
      file = await oui.File.open(_handle, filePath);
    } catch (e, st) {
      loggy.app('File open $filePath failed', e, st);
    }

    return file;
  }

  @override
  Future<void> close() async {
    await _handle.close();
    await super.close();
  }
}
