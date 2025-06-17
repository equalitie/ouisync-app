import 'dart:math';

import 'constants.dart';

// source: https://gist.github.com/zzpmaster/ec51afdbbfa5b2bf6ced13374ff891d9
String formatSize(int bytes, {int decimals = 1}) {
  final scale = _sizeScale(bytes);
  final value = _formatSizeValue(bytes, scale, decimals: decimals);
  final unit = _formatSizeUnit(scale);

  return '$value $unit';
}

String formatSizeProgress(int totalBytes, int soFarBytes, {int decimals = 1}) {
  final scale = _sizeScale(totalBytes);
  final totalValue = _formatSizeValue(totalBytes, scale, decimals: decimals);
  final soFarValue = _formatSizeValue(soFarBytes, scale, decimals: decimals);
  final unit = _formatSizeUnit(scale);

  return '$soFarValue/$totalValue $unit';
}

String formatThroughput(int bytesPerSecond, {int decimals = 1}) {
  // Use KiB/s even for values less than 1 KiB/s, for readability
  final scale = max(_sizeScale(bytesPerSecond), 1);
  final value = _formatSizeValue(bytesPerSecond, scale, decimals: decimals);
  final unit = _formatSizeUnit(scale);

  return '$value $unit/s';
}

int _sizeScale(int bytes) => bytes > 0 ? (log(bytes) / log(1024)).floor() : 0;

String _formatSizeValue(int bytes, int scale, {int decimals = 2}) =>
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
    "YiB",
  ];

  return suffixes[scale];
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
