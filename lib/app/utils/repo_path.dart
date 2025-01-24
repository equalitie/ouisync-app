import 'package:path/path.dart' as p;

/// We want to maintain a POSIX style path inside the library, even when
/// the app is running on Windows.
final _context = p.Context(style: p.Style.posix);

/// Use these functions only for paths passed to the Ouisync backend as
/// they won't work with Windows style paths containing the `\` slash.
String basename(String path) => _context.basename(path);
String basenameWithoutExtension(String path) =>
    _context.basenameWithoutExtension(path);
String dirname(String path) => _context.dirname(path);
String extension(String path) => _context.extension(path);
String join(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
  String? part9,
  String? part10,
  String? part11,
  String? part12,
  String? part13,
  String? part14,
  String? part15,
  String? part16,
]) =>
    _context.join(
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
      part16,
    );
String separator() => _context.separator;
