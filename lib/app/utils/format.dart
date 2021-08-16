import 'dart:math';

// source: https://gist.github.com/zzpmaster/ec51afdbbfa5b2bf6ced13374ff891d9
dynamic formattSize(int bytes, { int decimals = 2, bool units = false }) {
  if (bytes <= 0) return "0 B";
  if (bytes < 1000) return '$bytes B';

  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1000)).floor();

  final size = double.parse(((bytes / pow(1000, i)).toStringAsFixed(decimals)));

  return units
  ? '$size ${suffixes[i]}'
  : size;
}