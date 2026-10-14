import 'dart:io';

import 'package:loggy/loggy.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ouisync/helpers.dart' as oui show viewFile, shareFile;
import 'package:path/path.dart' as p;
import 'package:path/path.dart' show posix;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'log.dart';
import '../cubits/cubits.dart' show RepoCubit;
import '../../generated/l10n.dart';
import 'stage.dart';
import 'native.dart';

Future<String> disambiguateEntryName({
  required RepoCubit repoCubit,
  required String path,
  int versions = 0,
}) async {
  final parent = posix.dirname(path);
  final name = posix.basenameWithoutExtension(path);
  final extension = posix.extension(path);

  final newFileName = '$name (${versions += 1})$extension';
  final newPath = posix.join(parent, newFileName);

  if (await repoCubit.entryExists(newPath)) {
    return await disambiguateEntryName(
      repoCubit: repoCubit,
      path: path,
      versions: versions,
    );
  }
  return newPath;
}

Future<void> viewFile({
  required Stage stage,
  required RepoCubit repo,
  required String path,
  required Loggy<AppLogger> loggy,
}) async {
  Future<void> view() async {
    if (Platform.isAndroid) {
      final uri = await Native.instance.getDocumentUri("${repo.name}$path");

      // TODO: consider using launchUrl here as well
      if (!await oui.viewFile(uri)) {
        throw _AppNotFound();
      }
    } else if (Platform.isLinux || Platform.isWindows) {
      final mountPoint = await repo.mountPoint;
      if (mountPoint == null) {
        throw _RepoNotMounted();
      }

      final url = Uri(scheme: 'file', path: '$mountPoint$path');

      // Special non ASCII characters are encoded using Escape Encoding
      // https://datatracker.ietf.org/doc/html/rfc2396#section-2.4.1
      // which are not decoded back by the url_launcher plugin on Windows
      // before passing to the system for execution. Thus on Windows
      // we use the `launchUrlString` function instead of `launchUrl`.
      final result = Platform.isWindows
          ? await launchUrlString(Uri.decodeFull(url.toString()))
          : await launchUrl(url);

      if (!result) {
        throw _AppNotFound();
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      // The synced file isn't a real path on disk (no reliable FUSE/file-provider mount on
      // these platforms), so we export a throwaway local copy and hand that to the OS, which
      // opens it with whatever app is registered as the default viewer.
      final destinationPath = await stage.loading(
        _exportToTempFile(repo: repo, path: path),
      );

      final result = await OpenFilex.open(destinationPath);
      if (result.type != ResultType.done) {
        throw _AppNotFound();
      }
    } else {
      throw _NotImplemented();
    }
  }

  try {
    await view();
  } on _AppNotFound {
    stage.showSnackBar(S.current.messageNoAppsForThisAction);
  } on _RepoNotMounted {
    stage.showSnackBar(S.current.messageRepositoryNotMounted);
  } on _NotImplemented {
    stage.showSnackBar(S.current.messageFilePreviewNotAvailable);
  } catch (e, st) {
    // Covers `PlatformException` as well as errors from exporting the file (e.g. service or
    // filesystem errors).
    loggy.error('Error viewing file $path:', e, st);

    stage.showSnackBar(S.current.messagePreviewingFileFailed(path));
  }
}

Future<void> shareFile({
  required Stage stage,
  required RepoCubit repo,
  required String path,
  required Loggy<AppLogger> loggy,
}) async {
  try {
    if (Platform.isAndroid) {
      await oui.shareFile(
        await Native.instance.getDocumentUri("${repo.name}$path"),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      final destinationPath = await stage.loading(
        _exportToTempFile(repo: repo, path: path),
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(destinationPath)]),
      );
    } else {
      throw UnsupportedError(
        'sharing files is supported only on Android, iOS and macOS',
      );
    }
  } on UnsupportedError {
    rethrow;
  } catch (e, st) {
    // Covers `PlatformException` as well as errors from exporting the file (e.g. service or
    // filesystem errors).
    loggy.error('Error sharing file $path:', e, st);
    stage.showSnackBar(S.current.messageSharingFileFailed(path));
  }
}

/// Copies the repo file at [path] into a fresh, uniquely-named subdirectory of the system
/// temp directory (preserving the original filename, since the OS/native app may use it for
/// display or type detection), so it can be handed to a native OS app to open or share.
Future<String> _exportToTempFile({
  required RepoCubit repo,
  required String path,
}) async {
  final tempDir = await getTemporaryDirectory();
  final previewDir = p.join(
    tempDir.path,
    'preview',
    DateTime.now().microsecondsSinceEpoch.toString(),
  );
  final destinationPath = p.join(previewDir, posix.basename(path));

  await repo.exportFile(sourcePath: path, destinationPath: destinationPath);

  return destinationPath;
}

/// Deletes leftover temp copies created by [_exportToTempFile] in previous runs. The native app
/// that opens/receives such a file may still be reading it when we'd otherwise want to clean up,
/// so instead of deleting right after use, we sweep stale ones on the next app startup.
Future<void> clearPreviewCache() async {
  final tempDir = await getTemporaryDirectory();
  final previewDir = Directory(p.join(tempDir.path, 'preview'));

  if (await previewDir.exists()) {
    await previewDir.delete(recursive: true);
  }
}

class _RepoNotMounted implements Exception {}

class _AppNotFound implements Exception {}

class _NotImplemented implements Exception {}
