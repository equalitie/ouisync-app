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
String join(String a, String b) => _context.join(a, b);
String separator() => _context.separator;
