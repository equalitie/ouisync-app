import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:archive/archive_io.dart';
import 'package:date_format/date_format.dart';
import 'package:github/github.dart';
import 'package:path/path.dart';
import 'package:properties/properties.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pub_semver/pub_semver.dart';

const rootWorkDir = 'releases';

Future<void> main(List<String> args) async {
  final options = await Options.parse(args);

  final pubspec = Pubspec.parse(await File("pubspec.yaml").readAsString());
  final version = pubspec.version!;
  final commit = await getCommit();

  final suffix = createFileSuffix(version);
  final workDir = await createWorkDir(suffix);

  final aabPath = join(workDir.path, 'ouisync-$suffix.aab');
  final aab = await buildAab(aabPath, version, commit: commit);
  final apk = await extractApk(aab);
  final assets = <File>[apk, aab];

  final token = options.token;
  if (token != null) {
    await upload(
      version: version,
      first: options.firstCommit,
      last: commit,
      assets: assets,
      token: token,
      detailedLog: options.detailedLog,
    );
  } else {
    print(
        'no GitHub API access token specified - skipping creation of GitHub release');
  }
}

class Options {
  final String? token;
  final String? firstCommit;
  final bool detailedLog;

  Options._({this.token, this.firstCommit, this.detailedLog = true});

  static Future<Options> parse(List<String> args) async {
    final parser = ArgParser();
    parser.addOption(
      'token-file',
      abbr: 't',
      help:
          'Path to a file containing the GitHub API access token. If omitted, still builds the packages but does not create a GitHub release',
    );
    parser.addOption('first-commit',
        abbr: 'f',
        help:
            'Start of commit range to include in release notes. If omitted, includes everything since the previous release');
    parser.addFlag(
      'detailed-log',
      abbr: 'l',
      defaultsTo: true,
      help: 'Whether to generate detailed changelog in the release notes',
    );
    parser.addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information',
    );

    final results = parser.parse(args);

    if (results['help']) {
      print(parser.usage);
      exit(0);
    }

    final tokenFilePath = results['token-file'];
    final token = (tokenFilePath != null)
        ? await File(tokenFilePath).readAsString()
        : null;

    return Options._(
      token: token?.trim(),
      firstCommit: results['first-commit']?.trim(),
      detailedLog: results['detailed-log'],
    );
  }
}

Future<File> buildAab(
  String outputPath,
  Version version, {
  String? commit,
  String flavor = "vanilla",
}) async {
  final inputPath =
      'build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab';
  var outputFile = File(outputPath);

  if (await outputFile.exists()) {
    print('Not creating $outputPath - already exists');
    return outputFile;
  }

  print('Creating ${outputFile.path} ...');

  final versionName = stripBuild(version).canonicalizedVersion;
  final buildName = commit != null ? '$versionName-$commit' : versionName;

  // Do a fresh build just in case (TODO: do we need this?)
  await run('flutter', ['clean']);

  await run('flutter', [
    'build',
    'appbundle',
    '--flavor',
    flavor,
    '-t' 'lib/main_$flavor.dart',
    '--release',
    '--build-name',
    buildName,
  ]);

  return await File(inputPath).rename(outputPath);
}

Future<File> extractApk(File bundle) async {
  final outputPath = setExtension(bundle.path, '.apk');
  final outputFile = File(outputPath);

  if (await outputFile.exists()) {
    print('Not creating $outputPath - already exists');
    return outputFile;
  }

  print('Creating ${outputFile.path} ...');

  final bundletool = await prepareBundletool();

  final keyProperties = Properties.fromFile('android/key.properties');
  final storeFile = join('android/app', keyProperties.get('storeFile')!);
  final storePassword = keyProperties.get('storePassword')!;
  final keyPassword = keyProperties.get('keyPassword')!;

  final tempPath = setExtension(bundle.path, '.apks');

  await run('java', [
    '-jar',
    bundletool,
    'build-apks',
    '--bundle=${bundle.path}',
    '--mode=universal',
    '--ks=$storeFile',
    '--ks-pass=pass:$storePassword',
    '--ks-key-alias=upload',
    '--key-pass=pass:$keyPassword',
    '--output=$tempPath',
  ]);

  try {
    final archive = ZipDecoder().decodeBuffer(InputFileStream(tempPath));
    archive
        .findFile('universal.apk')!
        .writeContent(OutputFileStream(outputFile.path));

    return outputFile;
  } finally {
    await File(tempPath).delete();
  }
}

Future<String> prepareBundletool() async {
  final version = "1.8.2";
  final name = "bundletool-all-$version.jar";
  final path = join(rootWorkDir, name);

  final file = File(path);

  // Install bundletool if not exists

  if (!await file.exists()) {
    print('Downloading bundletool to generate apk');

    final url =
        'https://github.com/google/bundletool/releases/download/$version/$name';
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      await response.pipe(file.openWrite());
    } finally {
      client.close();
    }
  }

  return path;
}

Future<void> upload({
  required Version version,
  String? first,
  required String last,
  required List<File> assets,
  required String token,
  bool detailedLog = true,
}) async {
  final client = GitHub(auth: Authentication.withToken(token));
  final slug = RepositorySlug('equalitie', 'ouisync-app');

  try {
    final tagName = buildTagName(version);

    print('Creating release $tagName ($last) ...');

    if (first == null) {
      final prev = await client.repositories.getLatestRelease(slug);
      first = prev.tagName!;
    }

    final body = await buildReleaseNotes(
      slug,
      first,
      last,
      detailedLog: detailedLog,
    );

    final release = await client.repositories.createRelease(
      slug,
      CreateRelease(tagName)
        ..name = 'Ouisync $tagName'
        ..body = body
        ..isDraft = true,
    );

    for (final asset in assets) {
      final name = basename(asset.path);
      final content = await asset.readAsBytes();

      print('Uploading $name ...');

      await client.repositories.uploadReleaseAssets(
        release,
        [
          CreateReleaseAsset(
            name: name,
            contentType: 'application/octet-stream',
            assetData: content,
          )
        ],
      );
    }

    print('Release $tagName ($last) successfully created: ${release.htmlUrl}');
  } finally {
    client.dispose();
  }
}

Future<String> buildReleaseNotes(
  RepositorySlug slug,
  String first,
  String last, {
  bool detailedLog = true,
}) async {
  final buf = StringBuffer();

  buf.writeln('## What\'s new');
  buf.writeln('');

  // App
  buf.writeln('### App');
  buf.writeln('');
  buf.writeln(changelogUrl(slug, first, last));

  if (detailedLog) {
    buf.writeln('');
    buf.writeln(await getLog(slug, first, last));
  }

  // Plugin
  final pluginSlug = RepositorySlug(slug.owner, 'ouisync-plugin');
  final pluginLast = await getSubmoduleCommit(last, 'ouisync-plugin');
  final pluginFirst = await getSubmoduleCommit(first, 'ouisync-plugin');

  if (pluginFirst != pluginLast) {
    buf.writeln('');
    buf.writeln('### Plugin');
    buf.writeln('');
    buf.writeln(
      changelogUrl(pluginSlug, pluginFirst, pluginLast),
    );

    if (detailedLog) {
      buf.writeln('');
      buf.writeln(await getLog(
        pluginSlug,
        pluginFirst,
        pluginLast,
        'ouisync-plugin',
      ));
    }
  }

  // Library
  final libSlug = RepositorySlug(slug.owner, 'ouisync');
  final libLast = await getSubmoduleCommit(
    pluginLast,
    'ouisync',
    'ouisync-plugin',
  );
  final libFirst = await getSubmoduleCommit(
    pluginFirst,
    'ouisync',
    'ouisync-plugin',
  );

  if (libFirst != libLast) {
    buf.writeln('');
    buf.writeln('### Library');
    buf.writeln('');
    buf.writeln(
      changelogUrl(libSlug, libFirst, libLast),
    );

    if (detailedLog) {
      buf.writeln('');
      buf.writeln(await getLog(
        libSlug,
        libFirst,
        libLast,
        'ouisync-plugin/ouisync',
      ));
    }
  }

  return buf.toString();
}

Future<String> getCommit([String? workingDirectory]) => runCapture(
      'git',
      ['rev-parse', '--short', 'HEAD'],
      workingDirectory,
    );

Future<String> getSubmoduleCommit(
  String superCommit,
  String submodule, [
  String? workingDirectory,
]) async {
  final output = await runCapture(
    'git',
    ['ls-tree', superCommit, submodule],
    workingDirectory,
  );
  final parts = output.split(RegExp(r'\s+'));

  return parts[2];
}

Future<String> getLog(
  RepositorySlug slug,
  String first,
  String last, [
  String? workingDirectory,
]) =>
    runCapture(
      'git',
      [
        'log',
        '$first...$last',
        '--pretty=format:- https://github.com/${slug.owner}/${slug.name}/commit/%h %s'
      ],
      workingDirectory,
    );

String changelogUrl(RepositorySlug slug, String first, String last) {
  return 'https://github.com/${slug.owner}/${slug.name}/compare/$first...$last';
}

Version stripBuild(Version version) {
  final pre = version.preRelease.join('.');
  return Version(
    version.major,
    version.minor,
    version.patch,
    pre: pre.isNotEmpty ? pre : null,
  );
}

String buildTagName(Version version) {
  final v = stripBuild(version).canonicalizedVersion;
  return 'v$v';
}

Future<Directory> createWorkDir(String tag) async {
  final dir = Directory('$rootWorkDir/$tag');
  await dir.create(recursive: true);

  // Create 'latest' symlink
  final link = Link('$rootWorkDir/latest');

  if (await link.exists()) {
    await link.delete();
  }

  await link.create(basename(dir.path));

  return dir;
}

String createFileSuffix(Version version) {
  final timestamp = DateTime.now();

  final buffer = StringBuffer();
  buffer
    ..write('v')
    ..write(version.major)
    ..write('.')
    ..write(version.minor)
    ..write('.')
    ..write(version.patch);

  if (version.preRelease.isNotEmpty) {
    buffer
      ..write('-')
      ..write(version.preRelease.join('.'));
  }

  buffer
    ..write('-')
    ..write(formatDate(
      timestamp,
      [yyyy, mm, dd, HH, nn, ss],
    ));

  return buffer.toString();
}

Future<void> run(
  String command,
  List<String> args, [
  String? workingDirectory,
]) async {
  final process = await Process.start(
    command,
    args,
    workingDirectory: workingDirectory,
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
