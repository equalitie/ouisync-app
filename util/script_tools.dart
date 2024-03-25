import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> run(
  String command,
  List<String> args, [
  String? workingDirectory,
]) async {
  final process = await Process.start(
    command,
    args,
    workingDirectory: workingDirectory,
    // This helps on Windows with finding `command` in $PATH environment variable.
    runInShell: true,
  );

  unawaited(process.stdout.transform(utf8.decoder).forEach(stdout.write));
  unawaited(process.stderr.transform(utf8.decoder).forEach(stderr.write));

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw 'Command "$command ${args.join(' ')}" failed with exit code $exitCode';
  }
}

Future<String> runCapture(
  String command,
  List<String> args, [
  String? workingDirectory,
]) async {
  final result = await Process.run(
    command,
    args,
    workingDirectory: workingDirectory,
  );

  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw 'Command $command ${args.join(' ')} failed with exit code $exitCode';
  }

  return result.stdout.trim();
}

// Copy directory including its contents
Future<void> copyDirectory(Directory src, Directory dst) async {
  await for (final srcEntry in src.list(recursive: true, followLinks: false)) {
    final dstPath = p.join(dst.path, p.relative(srcEntry.path, from: src.path));

    if (srcEntry is File) {
      final dstEntry = File(dstPath);
      await Directory(dstEntry.parent.path).create(recursive: true);
      await srcEntry.copy(dstEntry.path);
    } else if (srcEntry is Directory) {
      await Directory(dstPath).create(recursive: true);
    }
  }
}