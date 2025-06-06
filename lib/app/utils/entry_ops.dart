import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync/helpers.dart' as oui show viewFile, shareFile;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' show posix;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'actions.dart';
import 'log.dart';
import 'utils.dart' show AppThemeExtension, Fields, ThemeGetter;
import '../widgets/widgets.dart' show DisambiguationAction, ReplaceKeepEntry;
import '../cubits/cubits.dart' show RepoCubit;
import '../../generated/l10n.dart';

Future<DisambiguationAction?> pickEntryDisambiguationAction(
  BuildContext context,
  String entryName,
  EntryType entryType,
) async => await showDialog<DisambiguationAction?>(
  context: context,
  builder:
      (BuildContext context) => AlertDialog(
        title: Flex(
          direction: Axis.horizontal,
          children: [
            Fields.constrainedText(
              S.current.titleMovingEntry,
              style: context.theme.appTextStyle.titleMedium,
              maxLines: 2,
            ),
          ],
        ),
        content: ReplaceKeepEntry(name: entryName, type: entryType),
      ),
);

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
  required RepoCubit repo,
  required String path,
  required PackageInfo packageInfo,
  required Loggy<AppLogger> loggy,
}) async {
  Future<void> view() async {
    if (Platform.isAndroid) {
      final uri = _makeAndroidUri(repo, path, packageInfo);

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
      final result =
          Platform.isWindows
              ? await launchUrlString(Uri.decodeFull(url.toString()))
              : await launchUrl(url);

      if (!result) {
        throw _AppNotFound();
      }
    } else if (Platform.isIOS) {
      // TODO: There is some issue with permissions, launchUrl doesn't work
      // and when I try to send this Uri to Swift to run
      // `NSWorkspace.shared.open(url)` it just returns `false`. Tried also
      // with running `url.startAccessingSecurityScopedResource()` but that
      // also just returns `false`. I'll leave this to later or to someone
      // who understands the macOS file permissions better.
      throw _NotImplemented();
    } else {
      // Until we have a proper implementation for OSX (iOS, macOS), we are
      // using a local HTTP server and the internet navigator previewer.
      final url = await repo.previewFileUrl(path);
      await launchUrl(url);
    }
  }

  try {
    await view();
  } on _AppNotFound {
    showSnackBar(S.current.messageNoAppsForThisAction);
  } on _RepoNotMounted {
    showSnackBar(S.current.messageRepositoryNotMounted);
  } on _NotImplemented {
    showSnackBar(S.current.messageFilePreviewNotAvailable);
  } on PlatformException catch (e, st) {
    loggy.error('Error viewing file $path:', e, st);

    showSnackBar(S.current.messagePreviewingFileFailed(path));
  }
}

Future<void> shareFile({
  required RepoCubit repo,
  required String path,
  required PackageInfo packageInfo,
}) async {
  if (Platform.isAndroid) {
    await oui.shareFile(_makeAndroidUri(repo, path, packageInfo));
  } else {
    throw UnsupportedError('sharing files is supported only on Android');
  }
}

Uri _makeAndroidUri(RepoCubit repo, String path, PackageInfo packageInfo) =>
    Uri(
      scheme: 'content',
      host: '${packageInfo.packageName}.provider',
      path: '${repo.name}$path',
    );

class _RepoNotMounted implements Exception {}

class _AppNotFound implements Exception {}

class _NotImplemented implements Exception {}
