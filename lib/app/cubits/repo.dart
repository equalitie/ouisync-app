import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:ouisync/native_channels.dart' show NativeChannels;
import 'package:ouisync/ouisync.dart';
import 'package:ouisync/state_monitor.dart';
import 'package:shelf/shelf_io.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../generated/l10n.dart';
import '../models/models.dart';
import '../utils/cipher.dart' as cipher;
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

class RepoCubit extends Cubit<RepoState> with CubitActions, AppLogger {
  final _currentFolder = Folder();
  final NativeChannels _nativeChannels;
  final NavigationCubit _navigation;
  final EntrySelectionCubit _entrySelection;
  final EntryBottomSheetCubit _bottomSheet;
  final Repository _repo;
  final cipher.SecretKey _pathSecretKey;
  final CacheServers _cacheServers;

  RepoCubit._(
    this._nativeChannels,
    this._navigation,
    this._entrySelection,
    this._bottomSheet,
    this._repo,
    this._pathSecretKey,
    this._cacheServers,
    super.state,
  ) {
    _currentFolder.repo = this;
  }

  static Future<RepoCubit> create({
    required NativeChannels nativeChannels,
    required Repository repo,
    required Session session,
    required NavigationCubit navigation,
    required EntrySelectionCubit entrySelection,
    required EntryBottomSheetCubit bottomSheet,
    required CacheServers cacheServers,
  }) async {
    final authMode = await repo.getAuthMode();

    var state = RepoState(
      location: RepoLocation.fromDbPath(repo.path),
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

    final pathSecretKey = cipher.randomSecretKey();

    final cubit = RepoCubit._(
      nativeChannels,
      navigation,
      entrySelection,
      bottomSheet,
      repo,
      pathSecretKey,
      cacheServers,
      state,
    );

    await cubit.mount();

    // Fetching the cache server state involves network request which might take a long time. Using
    // `unawaited` to avoid blocking this function on it.
    unawaited(cubit._updateCacheServersState());

    return cubit;
  }

  Future<String> get infoHash async => await _repo.infoHash;
  RepoLocation get location => state.location;
  String get name => state.location.name;
  AccessMode get accessMode => state.accessMode;
  String get currentFolder => _currentFolder.state.path;
  Stream<void> get events => _repo.events;
  EntrySelectionCubit get entrySelectionCubit => _entrySelection;

  Future<void> delete() => _repo.delete();

  void setCurrent() {
    _nativeChannels.repository = _repo;
  }

  void updateNavigation() {
    _navigation.current(location, currentFolder);
  }

  Future<void> startEntriesSelection([
    bool isSingleSelection = false,
    FileSystemEntry? singleEntry,
  ]) async {
    final currentPath = _currentFolder.state.path;
    await _entrySelection.startSelectionForRepo(
      this,
      currentPath,
      isSingleSelection,
      singleEntry,
    );
  }

  Future<void> endEntriesSelection() async {
    await _entrySelection.endSelection();
  }

  void showMoveEntryBottomSheet({
    required BottomSheetType sheetType,
    required FileSystemEntry entry,
  }) {
    _bottomSheet.showMoveEntry(
      repoCubit: this,
      navigationCubit: _navigation,
      type: sheetType,
      entry: entry,
    );
  }

  void showMoveSelectedEntriesBottomSheet({
    required BottomSheetType sheetType,
    FileSystemEntry? entry,
  }) {
    _bottomSheet.showMoveSelectedEntries(
      repoCubit: this,
      type: sheetType,
      entry: entry,
    );
  }

  Future<void> enableSync() async {
    await _repo.setSyncEnabled(true);

    // DHT and PEX states can only be queried when sync is enabled, so let's do it here.
    final isDhtEnabled = await _repo.isDhtEnabled;
    final isPexEnabled = await _repo.isPexEnabled;

    emitUnlessClosed(state.copyWith(
      isDhtEnabled: isDhtEnabled,
      isPexEnabled: isPexEnabled,
    ));
  }

  Future<void> setDhtEnabled(bool value) async {
    if (state.isDhtEnabled == value) {
      return;
    }

    await _repo.setDhtEnabled(value);

    emitUnlessClosed(state.copyWith(isDhtEnabled: value));
  }

  Future<void> setPexEnabled(bool value) async {
    if (state.isPexEnabled == value) {
      return;
    }

    await _repo.setPexEnabled(value);

    emitUnlessClosed(state.copyWith(isPexEnabled: value));
  }

  Future<void> setCacheServersEnabled(bool value) async {
    // Update the state to the desired value for immediate feedback...
    emitUnlessClosed(state.copyWith(isCacheServersEnabled: value));
    await _cacheServers.setEnabled(_repo, value);
    // ...then fetch the actual value and update the state again. This is needed because some of
    // the cache server requests might fail.
    await _updateCacheServersState();
  }

  Future<void> _updateCacheServersState() async {
    final value = await _cacheServers.isEnabledForRepo(_repo);
    emitUnlessClosed(state.copyWith(isCacheServersEnabled: value));
  }

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
    return await _repo.share(
      accessMode: accessMode,
      secret: password != null ? LocalPassword(password) : null,
    );
  }

  Future<void> mount() async {
    try {
      await _repo.mount();
      emitUnlessClosed(state.copyWith(mountState: const MountStateSuccess()));
    } on Unsupported {
      emitUnlessClosed(state.copyWith(mountState: const MountStateDisabled()));
    } catch (error, stack) {
      emitUnlessClosed(
          state.copyWith(mountState: MountStateFailure(error, stack)));
    }
  }

  Future<void> unmount() async {
    try {
      await _repo.unmount();
      emitUnlessClosed(state.copyWith(mountState: const MountStateDisabled()));
    } catch (_) {}
  }

  Future<String?> get mountPoint => _repo.mountPoint;

  Future<bool> entryExists(String path) => _repo.entryExists(path);

  Future<EntryType?> entryType(String path) => _repo.entryType(path);

  Future<Progress> get syncProgress => _repo.syncProgress;

  Future<NetworkStats> get networkStats => _repo.networkStats;

  // Get the state monitor of this particular repository. That is 'root >
  // Repositories > this repository ID'.
  StateMonitor? get stateMonitor => _repo.stateMonitor;

  Future<void> navigateTo(String destination) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    _currentFolder.goTo(destination);
    await refresh();

    emitUnlessClosed(state.copyWith(isLoading: false));
  }

  Future<List<FileSystemEntry>> getFolderContents(String path) async {
    String? error;

    final content = <FileSystemEntry>[];

    // If the directory does not exist, the following command will throw.
    final directory = await Directory.read(_repo, path);

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
      loggy.debug('Traversing directory $path exception', e, st);
      error = e.toString();
    }

    if (error != null) {
      throw error;
    }

    return content;
  }

  Future<bool> isFolderEmpty(String path) async {
    final directory = await Directory.read(_repo, path);
    return directory.isEmpty;
  }

  Future<bool> createFolder(String folderPath) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    try {
      await Directory.create(_repo, folderPath);
      _currentFolder.goTo(folderPath);
      return true;
    } catch (e, st) {
      loggy.debug('Directory $folderPath creation failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<bool> deleteFolder(String path, bool recursive) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    try {
      await Directory.remove(_repo, path, recursive: recursive);
      return true;
    } catch (e, st) {
      loggy.debug('Directory $path deletion failed', e, st);
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
    emitUnlessClosed(
        state.copyWith(uploads: state.uploads.withAdded(filePath, job)));

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

      emitUnlessClosed(
          state.copyWith(uploads: state.uploads.withRemoved(filePath)));
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

  /// Returns which access mode does the given secret provide.
  /// TODO: It should be possible to add API which does not temporarily unlock
  /// the repository.
  Future<AccessMode> getSecretAccessMode(LocalSecret secret) async {
    final credentials = await _repo.credentials;

    try {
      await _repo.setAccessMode(AccessMode.blind);
      await _repo.setAccessMode(
        AccessMode.write,
        secret: secret,
      );
      return await _repo.accessMode;
    } finally {
      await _repo.setCredentials(credentials);
    }
  }

  Future<Access> getAccessOf(LocalSecret secret) async {
    final accessMode = await getSecretAccessMode(secret);

    return switch (accessMode) {
      AccessMode.blind => BlindAccess(),
      AccessMode.read => ReadAccess(secret),
      AccessMode.write => WriteAccess(secret),
    };
  }

  Future<void> setAuthMode(AuthMode authMode) async {
    emitUnlessClosed(state.copyWith(isLoading: true));
    await _repo.setAuthMode(authMode);
    emitUnlessClosed(state.copyWith(authMode: authMode, isLoading: false));
  }

  Future<bool> setLocalSecret({
    required LocalSecret oldSecret,
    required SetLocalSecret newSecret,
  }) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

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
      emitUnlessClosed(state.copyWith(isLoading: false));
    }
  }

  Future<void> setAccess({
    AccessChange? read,
    AccessChange? write,
  }) async {
    await _repo.setAccess(read: read, write: write);

    // Operation succeeded (did not throw), so we can set `state.accessMode`
    // based on `read` and `write`.
    AccessMode newAccessMode;

    if (read is DisableAccess && write is DisableAccess) {
      newAccessMode = AccessMode.blind;
    } else if (write is DisableAccess) {
      newAccessMode = AccessMode.read;
    } else /* `write` or both (`read` and `write`) are `EnableAccess` */ {
      newAccessMode = AccessMode.write;
    }

    emitUnlessClosed(state.copyWith(accessMode: newAccessMode));
  }

  Future<void> resetAccess(ShareToken token) async {
    await _repo.resetAccess(token);
    final accessMode = await _repo.accessMode;
    emitUnlessClosed(state.copyWith(accessMode: accessMode));
  }

  /// Unlocks the repository using the secret. The access mode the repository ends up in depends on
  /// what access mode the secret unlock (read or write).
  Future<void> unlock(LocalSecret? secret) async {
    await _repo.setAccessMode(AccessMode.write, secret: secret);
    final accessMode = await _repo.accessMode;
    emitUnlessClosed(state.copyWith(accessMode: accessMode));

    if (state.accessMode != AccessMode.blind) {
      await refresh();
    }
  }

  /// Locks the repository (switches it to blind mode)
  Future<void> lock() async {
    await _repo.setAccessMode(AccessMode.blind);
    final accessMode = await _repo.accessMode;
    emitUnlessClosed(state.copyWith(accessMode: accessMode));
  }

  /// Move this repo to another location on the filesystem.
  Future<void> move(String to) async {
    await _repo.move(to);

    emitUnlessClosed(
      state.copyWith(location: RepoLocation.fromDbPath(_repo.path)),
    );
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
    final encryptedHandle =
        base64Encode(await cipher.encrypt(_pathSecretKey, utf8.encode(path)));
    final mimeType = MimeTypeResolver().lookup(path);

    final handler = createStaticFileHandler(
      encryptedHandle,
      mimeType,
      openFile,
      _pathSecretKey,
    );

    final server = await serve(handler, Constants.fileServerAuthority, 0);
    final authority = '${server.address.host}:${server.port}';

    loggy.debug('Serving file at http://$authority');

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
    emitUnlessClosed(
        state.copyWith(downloads: state.downloads.withAdded(sourcePath, job)));

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
      loggy.debug('Download file $sourcePath exception', e, st);
      showSnackBar(S.current.messageDownloadingFileError(sourcePath));
    } finally {
      showSnackBar(S.current.messageDownloadFileLocation(parentPath));
      emitUnlessClosed(
          state.copyWith(downloads: state.downloads.withRemoved(sourcePath)));

      await Future.wait(
          [sink.flush().then((_) => sink.close()), ouisyncFile.close()]);
    }
  }

  Future<bool> copyEntry({
    required String source,
    required String destination,
    required EntryType type,
    RepoCubit? destinationRepoCubit,
    required bool recursive,
  }) async {
    emitUnlessClosed(state.copyWith(isLoading: true));
    try {
      final result = type == EntryType.file
          ? await _copyFile(source, destination, destinationRepoCubit)
          : await _copyFolder(
              source,
              destination,
              destinationRepoCubit,
              recursive,
            );

      return result;
    } catch (e, st) {
      loggy.error('Move entry from $source to $destination failed', e, st);
      return false;
    } finally {
      await refresh();
    }
  }

  Future<bool> _copyFile(
    String source,
    String destination,
    RepoCubit? destinationRepoCubit,
  ) async {
    final originFile = await openFile(source);
    final originFileLength = await originFile.length;

    await (destinationRepoCubit ?? this).saveFile(
      filePath: destination,
      length: originFileLength,
      fileByteStream: originFile.readStream(),
    );

    return true;
  }

  Future<bool> _copyFolder(
    String source,
    String destination,
    RepoCubit? destinationRepoCubit,
    bool recursive,
  ) async {
    final createFolderOk = await (destinationRepoCubit ?? this).createFolder(
      destination,
    );

    if (createFolderOk && recursive) {
      final contents = await Directory.read(_repo, source);

      for (var entry in contents) {
        final from = repo_path.join(source, entry.name);
        final to = repo_path.join(destination, entry.name);
        final copyOk = entry.entryType == EntryType.file
            ? await _copyFile(from, to, destinationRepoCubit)
            : await _copyFolder(
                from,
                to,
                destinationRepoCubit,
                recursive,
              );

        if (!copyOk) return false;
      }
    }

    return createFolderOk;
  }

  Future<bool> moveEntry({
    required String source,
    required String destination,
  }) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    try {
      await _repo.moveEntry(source, destination);
      return true;
    } catch (e, st) {
      loggy.debug('Move entry from $source to $destination failed', e, st);
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
    required bool recursive,
  }) async {
    emitUnlessClosed(state.copyWith(isLoading: true));
    try {
      if (type == EntryType.file) {
        final moveFileResult = await _moveFileToRepo(
          destinationRepoCubit,
          source,
          destination,
        );

        return moveFileResult;
      }

      final moveFolderResult = await _moveFolderToRepo(
        destinationRepoCubit,
        source,
        destination,
        recursive,
      );

      return moveFolderResult;
    } catch (e, st) {
      loggy.debug('Move entry from $source to $destination failed', e, st);
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
    final copied = await _copyFile(
      source,
      destination,
      destinationRepoCubit,
    );
    if (copied) {
      await File.remove(_repo, source);
      return true;
    }
    return false;
  }

  Future<bool> _moveFolderToRepo(
    RepoCubit destinationRepoCubit,
    String source,
    String destination,
    bool recursive,
  ) async {
    final copied = await _copyFolder(
      source,
      destination,
      destinationRepoCubit,
      recursive,
    );
    if (copied) {
      if (recursive) {
        await Directory.remove(_repo, source, recursive: true);
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteFile(String filePath) async {
    emitUnlessClosed(state.copyWith(isLoading: true));

    try {
      await File.remove(_repo, filePath);
      return true;
    } catch (e, st) {
      loggy.debug('Delete file $filePath failed', e, st);
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

    emitUnlessClosed(state.copyWith(
      currentFolder: _currentFolder.state,
      isLoading: false,
    ));
  }

  StreamSubscription<void> autoRefresh() =>
      _repo.events.asyncMapSample((_) => refresh()).listen(null);

  Future<File?> _createFile(String newFilePath) async {
    File? newFile;

    try {
      newFile = await File.create(_repo, newFilePath);
    } catch (e, st) {
      loggy.debug('File creation $newFilePath failed', e, st);
    }

    return newFile;
  }

  Future<File> openFile(String path) => File.open(_repo, path);
}
