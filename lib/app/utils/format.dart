import 'dart:math';

import 'package:ouisync_app/app/utils/utils.dart';
import 'package:path/path.dart' as p;

// source: https://gist.github.com/zzpmaster/ec51afdbbfa5b2bf6ced13374ff891d9
String formatSize(int bytes, {int decimals = 1}) {
  final scale = _sizeScale(bytes);
  final value = _formatSizeValue(bytes, scale, decimals: decimals);
  final unit = _formatSizeUnit(scale);

  return '$value $unit';
}

String formatSizeProgress(
  int totalBytes,
  int soFarBytes, {
  int decimals = 1,
}) {
  final scale = _sizeScale(totalBytes);
  final totalValue = _formatSizeValue(totalBytes, scale, decimals: decimals);
  final soFarValue = _formatSizeValue(soFarBytes, scale, decimals: decimals);
  final unit = _formatSizeUnit(scale);

  return '$soFarValue/$totalValue $unit';
}

int _sizeScale(int bytes) => bytes > 0 ? (log(bytes) / log(1024)).floor() : 0;

String _formatSizeValue(
  int bytes,
  int scale, {
  int decimals = 2,
}) =>
    (bytes / pow(1024, scale)).toStringAsFixed(decimals);

String _formatSizeUnit(int scale) {
  const suffixes = [
    "B",
    "KiB",
    "MiB",
    "GiB",
    "TiB",
    "PiB",
    "EiB",
    "ZiB",
    "YiB"
  ];

  return suffixes[scale];
}

String buildDestinationPath(String parentPath, String entryPath) {
  /// We want to maintain a POSIX style path inside the library, even when
  /// the app is running on Windows.
  final context = p.Context(style: p.Style.posix);
  return context.join(parentPath, entryPath);
}

String formatShareLinkForDisplay(String shareLink) {
  final shareTokenUri = Uri.parse(shareLink);
  final truncatedToken =
      '${shareTokenUri.fragment.substring(0, Constants.maxCharacterRepoTokenForDisplay)}...';

  final displayToken = shareTokenUri.replace(fragment: truncatedToken);
  return displayToken.toString();
}

String maskPassword(String? password, {bool mask = true}) =>
    (mask ? "●" * (password ?? '').length : password) ?? '';
