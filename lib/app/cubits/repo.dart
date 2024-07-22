import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync/state_monitor.dart';
import 'package:shelf/shelf_io.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/master_key.dart';
import '../utils/mounter.dart';
import '../utils/repo_path.dart' as repo_path;
import '../utils/utils.dart';
import 'cubits.dart';

class RepoState extends Equatable {
  final bool isLoading;
  final Map<String, Job> uploads;
  final Map<String, Job> downloads;
  final bool isDhtEnabled;
  final bool isPexEnabled;
  final bool isCacheServersEnabled;
  final bool requestPassword;
  final RepoLocation location;
  final AuthMode authMode;
  final AccessMode accessMode;
  final String infoHash;
  final FolderState currentFolder;
  final MountState mountState;

  RepoState({
    this.isLoading = false,
    this.uploads = const {},
    this.downloads = const {},
    this.isDhtEnabled = false,
    this.isPexEnabled = false,
    this.isCacheServersEnabled = false,
    this.requestPassword = false,
    required this.location,
    required this.authMode,
    this.infoHash = "",
    this.accessMode = AccessMode.blind,
    this.currentFolder = const FolderState(),
    this.mountState = const MountStateDisabled(),
  });

  RepoState copyWith({
    bool? isLoading,
    Map<String, Job>? uploads,
    Map<String, Job>? downloads,
    String? message,
    bool? isDhtEnabled,
    bool? isPexEnabled,
    bool? isCacheServersEnabled,
    bool? requestPassword,
    RepoLocation? location,
    AuthMode? authMode,
    AccessMode? accessMode,
    String? infoHash,
    FolderState? currentFolder,
    MountState? mountState,
  }) =>
      RepoState(
        isLoading: isLoading ?? this.isLoading,
        uploads: uploads ?? this.uploads,
        downloads: downloads ?? this.downloads,
        isDhtEnabled: isDhtEnabled ?? this.isDhtEnabled,
        isPexEnabled: isPexEnabled ?? this.isPexEnabled,
        isCacheServersEnabled:
            isCacheServersEnabled ?? this.isCacheServersEnabled,
        requestPassword: requestPassword ?? this.requestPassword,
        location: location ?? this.location,
        authMode: authMode ?? this.authMode,
        accessMode: accessMode ?? this.accessMode,
        infoHash: infoHash ?? this.infoHash,
        currentFolder: currentFolder ?? this.currentFolder,
        mountState: mountState ?? this.mountState,
      );

  @override
  List<Object?> get props => [
        isLoading,
        uploads,
        downloads,
        isDhtEnabled,
        isPexEnabled,
        isCacheServersEnabled,
        requestPassword,
        location,
        authMode,
        accessMode,
        infoHash,
        currentFolder,
        mountState,
      ];

  bool get canRead => accessMode != AccessMode.blind;
  bool get canWrite => accessMode == AccessMode.write;
}

class RepoCubit extends Cubit<RepoState> with AppLogger {
  final _currentFolder = Folder();
  final NativeChannels _nativeChannels;
  final NavigationCubit _navigation;
  final EntryBottomSheetCubit _bottomSheet;
  final Repository _repo;
  final Cipher _pathCipher;
  final CacheServers _cacheServers;
  final Mounter _mounter;

  RepoCubit._(
    this._nativeChannels,
    this._navigation,
    this._bottomSheet,
    this._repo,
    this._pathCipher,
    this._cacheServers,
    this._mounter,
    super.state,
  ) {
    _currentFolder.repo = this;
  }

  static Future<RepoCubit> create({
    required NativeChannels nativeChannels,
    required Settings settings,
    required Repository repo,
    required RepoLocation location,
    required NavigationCubit navigation,
    required EntryBottomSheetCubit bottomSheet,
    required CacheServers cacheServers,
    required Mounter mounter,
  }) async {
    final authMode = await repo.getAuthMode();

    var state = RepoState(
      location: location,
      authMode: authMode,
    );

    final infoHash = await repo.infoHash;
    final accessMode = await repo.accessMode;

    state = state.copyWith(
      infoHash: infoHash,
      accessMode: accessMode,
    );

    if (await repo.isSyncEnabled) {
      final isDhtEnabled = await repo.isDhtEnabled;
      final isPexEnabled = await repo.isPexEnabled;

      state = state.copyWith(
        isDhtEnabled: isDhtEnabled,
        isPexEnabled: isPexEnabled,
      );
    }

    final pathCipher = await Cipher.newWithRandomKey();

    final cubit = RepoCubit._(
      nativeChannels,
      navigation,
      bottomSheet,
      repo,
      pathCipher,
      cacheServers,
      mounter,
      state,
    );

    await cubit.mount();

    // Fetching the cache server state involves network request which might take a long time. Using
    // `unawaited` to avoid blocking this function on it.
    unawaited(cubit._updateCacheServersState());

    return cubit;
  }

  RepoLocation get location => state.location;
  String get name => state.location.name;
  AccessMode get accessMode => state.accessMode;
  String get currentFolder => _currentFolder.state.path;
  Stream<void> get events => _repo.events;

  void setCurrent() {
    _nativeChannels.repository = _repo;
  }

  void updateNavigation({required bool isFolder}) {
    _navigation.current(location, currentFolder, isFolder);
  }

  void showMoveEntryBottomSheet({
    required BottomSheetType sheetType,
    required String entryPath,
    required EntryType entryType,
  }) {
    _bottomSheet.showMoveEntry(
      repoCubit: this,
      navigationCubit: _navigation,
      entryPath: entryPath,
      entryType: entryType,
    );
  }

  Future<void> enableSync() async {
    await _repo.setSyncEnabled(true);

    // DHT and PEX states can only be queried when sync is enabled, so let's do it here.
    final isDhtEnabled = await _repo.isDhtEnabled;
    final isPexEnabled = await _repo.isPexEnabled;

    emit(state.copyWith(
      isDhtEnabled: isDhtEnabled,
      isPexEnabled: isPexEnabled,
    ));
  }

  Future<void> setDhtEnabled(bool value) async {
    if (state.isDhtEnabled == value) {
      return;
    }

    await _repo.setDhtEnabled(value);

    emit(state.copyWith(isDhtEnabled: value));
  }

  Future<void> setPexEnabled(bool value) async {
    if (state.isPexEnabled == value) {
      return;
    }

    await _repo.setPexEnabled(value);

    emit(state.copyWith(isPexEnabled: value));
  }

  Future<void> setCacheServersEnabled(bool value) async {
    // Update the state to the desired value for immediate feedback...
    emit(state.copyWith(isCacheServersEnabled: value));
    await _cacheServers.setEnabled(_repo, value);
    // ...then fetch the actual value and update the state again. This is needed because some of
    // the cache server requests might fail.
    await _updateCacheServersState();
  }

  Future<void> _updateCacheServersState() async {
    final value = await _cacheServers.isEnabledForRepo(_repo);
    emit(state.copyWith(isCacheServersEnabled: value));
  }

  Future<Directory> openDirectory(String path) => Directory.open(_repo, path);

  // This operator is required for the DropdownMenuButton to show entries properly.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoCubit && state.infoHash == other.state.infoHash;
  }

  @override
  int get hashCode => state.infoHash.hashCode;

  Future<ShareToken> createShareToken(
    AccessMode accessMode, {
    String? password,
  }) async {
    return await _repo.createShareToken(
      accessMode: accessMode,
      name: name,
      secret: password != null ? LocalPassword(password) : null,
    );
  }

  Future<Uint8List> get credentials => _repo.credentials;

  Future<void> setCredentials(Uint8List credentials) async {
    await _repo.setCredentials(credentials);
    final accessMode = await _repo.accessMode;
    emit(state.copyWith(accessMode: accessMode));
  }

  Future<void> mount() async {
    if (_mounter.mountPoint == null) {
      // Mounting not supported.
      return;
    }

    try {
      await _repo.mount();
      emit(state.copyWith(mountState: const MountStateSuccess()));
    } on Error catch (error) {
      emit(state.copyWith(
        mountState: MountStateError(error.code, error.message),
      ));
    }
  }

  Future<void> unmount() async {
    try {
      await _repo.unmount();
      emit(state.copyWith(mountState: const MountStateDisabled()));
    } catch (_) {}
  }

  String? get mountPoint {
    if (state.mountState is! MountStateSuccess) {
      return null;
    }

    final mountPoint = _mounter.mountPoint;
    if (mountPoint == null) {
      return null;
    }

    return "$mountPoint/$name";
  }

  Future<bool> exists(String path) async {
    return await _repo.exists(path);
  }

  Future<EntryType?> type(String path) => _repo.type(path);

  Future<Progress> get syncProgress => _repo.syncProgress;

  // Get the state monitor of this particular repository. That is 'root >
  // Repositories > this repository ID'.
  StateMonitor? get stateMonitor => _repo.stateMonitor;

  Future<void> navigateTo(String destination) async {
    emit(state.copyWith(isLoading: true));

    _currentFolder.goTo(destination);
    await refresh();

    emit(state.copyWith(isLoading: false));
  }

  Future<bool> createFolder(String folderPath) async {
    emit(state.copyWith(isLoading: true));

    try {
      await Directory.create(_repo, folderPath);
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
      await Directory.remove(_repo, path, recursive: recursive);
      return true;
    } catch (e, st) {
      loggy.app('Directory $path deletion failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<void> saveFile({
    required String filePath,
    required int length,
    required Stream<List<int>> fileByteStream,
    File? currentFile,
  }) async {
    if (state.uploads.containsKey(filePath)) {
      showSnackBar(S.current.messageFileIsDownloading);
      return;
    }

    final file = currentFile ?? await _createFile(filePath);

    if (file == null) {
      showSnackBar(S.current.messageNewFileError(filePath));
      return;
    }

    loggy.debug('Saving file $filePath');

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

      loggy.debug('File saved: $filePath (${formatSize(offset)})');
    } catch (e, st) {
      loggy.debug('Save file to $filePath failed: ${e.toString()}', e, st);
      showSnackBar(S.current.messageWritingFileError(filePath));
      return;
    } finally {
      await file.close();
      await refresh();

      emit(state.copyWith(uploads: state.uploads.withRemoved(filePath)));
    }

    if (job.state.cancel) {
      showSnackBar(S.current.messageWritingFileCanceled(filePath));
    }
  }

  Future<void> replaceFile({
    required String filePath,
    required int length,
    required Stream<List<int>> fileByteStream,
  }) async {
    try {
      await deleteFile(filePath);
    } catch (e, st) {
      loggy.error('Failed deleting file $filePath:', e, st);
    }

    await saveFile(
      filePath: filePath,
      length: length,
      fileByteStream: fileByteStream,
    );
  }

  Future<List<FileSystemEntry>> getFolderContents(String path) async {
    String? error;

    final content = <FileSystemEntry>[];

    // If the directory does not exist, the following command will throw.
    final directory = await Directory.open(_repo, path);

    try {
      for (final dirEntry in directory) {
        final entryPath = repo_path.join(path, dirEntry.name);

        final entry = switch (dirEntry.entryType) {
          EntryType.file => FileEntry(
              path: entryPath,
              size: await _getFileSize(entryPath),
            ),
          EntryType.directory => DirectoryEntry(path: entryPath),
        };

        content.add(entry);
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

  /// Returns which access mode does the given password provide.
  Future<AccessMode> getPasswordAccessMode(String password) async {
    final credentials = await _repo.credentials;

    try {
      await _repo.setAccessMode(AccessMode.blind);
      await _repo.setAccessMode(
        AccessMode.write,
        secret: LocalPassword(password),
      );
      return await _repo.accessMode;
    } finally {
      await _repo.setCredentials(credentials);
    }
  }

  Future<void> setAuthMode(AuthMode authMode) async {
    emit(state.copyWith(isLoading: true));
    await _repo.setAuthMode(authMode);
    emit(state.copyWith(authMode: authMode, isLoading: false));
  }

  Future<bool> setLocalSecret({
    required LocalSecret oldSecret,
    required SetLocalSecret newSecret,
  }) async {
    emit(state.copyWith(isLoading: true));

    // Grab the current credentials so we can restore the access mode when we are done.
    final credentials = await _repo.credentials;

    try {
      // First try to switch the repo to the write mode using `oldSecret`. If the secret is
      // the correct write secret we end up in write mode. If it's the correct read secret we
      // end up in read mode. Otherwise we end up in blind mode. Depending on the mode we end up
      // in, we change the corresponding secret to `newSecret`.
      await _repo.setAccessMode(AccessMode.write, secret: oldSecret);

      switch (await _repo.accessMode) {
        case AccessMode.write:
          await _repo.setAccess(
            read: EnableAccess(newSecret),
            write: EnableAccess(newSecret),
          );
          break;
        case AccessMode.read:
          await _repo.setAccess(
            read: EnableAccess(newSecret),
          );
          break;
        case AccessMode.blind:
          loggy.warning('Incorrect local secret');
          return false;
      }

      // TODO: should we update state.accessMode here ?
      return true;
    } catch (e, st) {
      loggy.error(
          'Setting local secret for repository ${location.name} failed', e, st);
      return false;
    } finally {
      await _repo.setCredentials(credentials);
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Returns null if the authMode is AuthModeBlindOrManual or if decrytion fails.
  /// TODO: If decryption fails, we should throw and catch that above to inform
  /// the user about the fact.
  Future<LocalSecret?> getLocalSecret(MasterKey masterKey) async {
    final authMode = state.authMode;

    try {
      switch (authMode) {
        case AuthModeBlindOrManual():
          return null;
        case AuthModePasswordStoredOnDevice(encryptedPassword: final encrypted):
          final decrypted = await masterKey.decrypt(encrypted);
          if (decrypted == null) throw AuthModeDecryptFailed();
          return LocalPassword(decrypted);
        case AuthModeKeyStoredOnDevice(encryptedKey: final encrypted):
          final decrypted = await masterKey.decryptBytes(encrypted);
          if (decrypted == null) throw AuthModeDecryptFailed();
          return LocalSecretKey(decrypted);
      }
    } catch (e) {
      loggy.error("Failed to decrypt local secret: $e");
      return null;
    }
  }

  /// Unlocks the repository using the secret. The access mode the repository ends up in depends on
  /// what access mode the secret unlock (read or write).
  Future<void> unlock(LocalSecret? secret) async {
    await _repo.setAccessMode(AccessMode.write, secret: secret);
    final accessMode = await _repo.accessMode;
    emit(state.copyWith(accessMode: accessMode));

    if (state.accessMode != AccessMode.blind) {
      await refresh();
    }
  }

  /// Locks the repository (switches it to blind mode)
  Future<void> lock() async {
    await _repo.setAccessMode(AccessMode.blind);
    final accessMode = await _repo.accessMode;
    emit(state.copyWith(accessMode: accessMode));
  }

  Future<int?> _getFileSize(String path) async {
    File file;

    try {
      file = await openFile(path);
    } catch (_) {
      // Most common case of an error here is that the file hasn't been synced yet. No need to spam
      // the logs with it.
      return null;
    }

    try {
      return await file.length;
    } catch (e, st) {
      loggy.error('Failed to get size of file $path:', e, st);
      return null;
    } finally {
      await file.close();
    }
  }

  Future<Uri> previewFileUrl(String path) async {
    final encryptedHandle = await _pathCipher.encrypt(path);
    final mimeType = MimeTypeResolver().lookup(path);

    final handler = createStaticFileHandler(
        encryptedHandle, mimeType, openFile, _pathCipher);

    final server = await serve(handler, Constants.fileServerAuthority, 0);
    final authority = '${server.address.host}:${server.port}';

    print('Serving file at http://$authority');

    final url = Uri.http(
      authority,
      Constants.fileServerPreviewPath,
      {Constants.fileServerHandleQuery: encryptedHandle},
    );

    return url;
  }

  Future<void> downloadFile({
    required String sourcePath,
    required String parentPath,
    required String destinationPath,
  }) async {
    if (state.downloads.containsKey(sourcePath)) {
      showSnackBar(S.current.messageFileIsDownloading);
      return;
    }

    final ouisyncFile = await File.open(_repo, sourcePath);
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
      showSnackBar(S.current.messageDownloadingFileError(sourcePath));
    } finally {
      showSnackBar(S.current.messageDownloadFileLocation(parentPath));
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
      await _repo.move(source, destination);
      return true;
    } catch (e, st) {
      loggy.app('Move entry from $source to $destination failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<bool> moveEntryToRepo({
    required RepoCubit destinationRepoCubit,
    required EntryType type,
    required String source,
    required String destination,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = type == EntryType.file
          ? await _moveFileToRepo(
              destinationRepoCubit,
              source,
              destination,
            )
          : await _moveFolderToRepo(
              destinationRepoCubit,
              source,
              destination,
            );

      return result;
    } catch (e, st) {
      loggy.app('Move entry from $source to $destination failed', e, st);
      return false;
    } finally {
      await destinationRepoCubit.refresh();
      await refresh();
    }
  }

  Future<bool> _moveFileToRepo(
    RepoCubit destinationRepoCubit,
    String source,
    String destination,
  ) async {
    final originFile = await openFile(source);
    final originFileLength = await originFile.length;

    await destinationRepoCubit.saveFile(
      filePath: destination,
      length: originFileLength,
      fileByteStream: originFile.read(0, originFileLength).asStream(),
    );

    await File.remove(_repo, source);
    return true;
  }

  Future<bool> _moveFolderToRepo(
    RepoCubit destinationRepoCubit,
    String source,
    String destination,
  ) async {
    final createFolderOk = await destinationRepoCubit.createFolder(destination);
    if (!createFolderOk) return false;

    await openDirectory(source).then(
      (contents) async {
        for (var entry in contents) {
          final from = repo_path.join(source, entry.name);
          final to = repo_path.join(destination, entry.name);
          final moveOk = entry.entryType == EntryType.file
              ? await _moveFileToRepo(destinationRepoCubit, from, to)
              : await _moveFolderToRepo(destinationRepoCubit, from, to);

          if (!moveOk) return false;
        }
      },
    );

    await Directory.remove(_repo, source);
    return true;
  }

  Future<bool> deleteFile(String filePath) async {
    emit(state.copyWith(isLoading: true));

    try {
      await File.remove(_repo, filePath);
      return true;
    } catch (e, st) {
      loggy.app('Delete file $filePath failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<void> refresh({
    SortBy? sortBy = SortBy.name,
    SortDirection? sortDirection = SortDirection.asc,
  }) async {
    final path = state.currentFolder.path;
    bool errorShown = false;

    try {
      while (state.canRead) {
        bool success = await _currentFolder.refresh(
            sortBy: sortBy, sortDirection: sortDirection);

        if (success) break;
        if (_currentFolder.state.isRoot) break;

        _currentFolder.goUp();

        if (!errorShown) {
          errorShown = true;
          showSnackBar(S.current.messageErrorCurrentPathMissing(path));
        }
      }
    } catch (e) {
      showSnackBar(e.toString());
    }

    emit(state.copyWith(
      currentFolder: _currentFolder.state,
      isLoading: false,
    ));
  }

  StreamSubscription<void> autoRefresh() =>
      _repo.events.listen((_) => refresh());

  Future<File?> _createFile(String newFilePath) async {
    File? newFile;

    try {
      newFile = await File.create(_repo, newFilePath);
    } catch (e, st) {
      loggy.app('File creation $newFilePath failed', e, st);
    }

    return newFile;
  }

  Future<File> openFile(String path) => File.open(_repo, path);

  @override
  Future<void> close() async {
    await _repo.close();
    await super.close();
  }

  Future<PasswordSalt?> getCurrentModePasswordSalt() async {
    switch (accessMode) {
      case AccessMode.blind:
        return null;
      case AccessMode.read:
        return await _repo.getReadPasswordSalt();
      case AccessMode.write:
        return await _repo.getWritePasswordSalt();
    }
  }
}
