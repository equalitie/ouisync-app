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

  final versionName = stripBuild(version).canonicalizedVersion;
  final buildName = '$versionName-$commit';

  // Do a fresh build just in case (TODO: do we need this?)
  await cleanBuild();

  final aab = await buildAab(buildName, version.build[0] as int);
  final winInstaller = await buildWindowsInstaller(buildName);

  final identityName = options.identityName;
  final publisher = options.publisher;
  final winMSIX = await buildWindowsMSIX(identityName, publisher);

  final suffix = createFileSuffix(version, commit);
  final outputDir = await createOutputDir(suffix);

  final collatedAab =
      await collateAsset(outputDir, "ouisync-android", suffix, aab);
  final collatedApk = await extractApk(collatedAab);
  final collatedWinInstaller = await collateAsset(
      outputDir, "ouisync-windows-installer", suffix, winInstaller);

  File? collateWinMSIX;
  if (winMSIX != null) {
    collateWinMSIX =
        await collateAsset(outputDir, 'ouisync-windows-msix', suffix, winMSIX);
  }

  /// Right now the MSIX is not signed, therefore, it can only be used for the
  /// Microsoft Store, not for standalone installations.
  ///
  /// Until we get the certificates and sign the MSIX, we don't upload it to
  /// GitHub releases.
  ///
  ///
  final assets = <File>[
    collatedAab,
    collatedApk,
    collatedWinInstaller,
    if (collateWinMSIX != null) collateWinMSIX
  ];

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
  final String? identityName;
  final String? publisher;

  Options._(
      {this.token,
      this.firstCommit,
      this.detailedLog = true,
      this.identityName,
      this.publisher});

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
    parser.addOption(
      'identity-name',
      abbr: 'i',
      help:
          'The unique identifier for the app in the Microsoft Store (For the MSIX)',
    );
    parser.addOption(
      'publisher',
      abbr: 'b',
      help:
          'The Publisher (CN) value for the app in the Microsoft Store (For the MSIX)',
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
      identityName: results['identity-name'],
      publisher: results['publisher'],
    );
  }
}

Future<void> cleanBuild() async {
  await run('flutter', ['clean']);
}

Future<File> buildWindowsInstaller(String buildName) async {
  await run('flutter', [
    'build',
    'windows',
    '--verbose',
    '--release',
    '--build-name',
    buildName,
  ]);

  final innoScript =
      await File("windows/inno-setup.iss.template").readAsString();
  await File("build/inno-setup.iss")
      .writeAsString(innoScript.replaceAll("<APP_VERSION>", buildName));

  await run("C:/Program Files (x86)/Inno Setup 6/Compil32.exe",
      ['/cc', 'build/inno-setup.iss']);

  return File('build/windows/runner/Release/ouisync-installer.exe');
}

Future<File?> buildWindowsMSIX(String? identityName, String? publisher) async {
  if (identityName == null || publisher == null) {
    final missingOptions =
        StringBuffer('The Windows MSIX creation will be skipped:\n\n');

    if (identityName == null) {
      missingOptions.writeln('  --identity-name, -i: parameter not provided.');
    }
    if (publisher == null) {
      missingOptions.writeln('  --publisher, -b: parameter not provided.\n');
    }

    print(missingOptions.toString());

    return null;
  }

  await run('dart', [
    'run',
    'msix:create',
    '-u',
    '"eQualitie Inc"',
    '-i',
    identityName,
    '-b',
    publisher,
    '--store'
  ]);

  return File('build/windows/runner/Release/ouisync_app.msix');
}

Future<File> buildAab(String buildName, int buildNumber) async {
  final inputPath = 'build/app/outputs/bundle/Release/app-release.aab';

  print('Creating Android App Bundle ...');

  await run('flutter', [
    'build',
    'appbundle',
    '--release',
    '--build-number',
    '$buildNumber',
    '--build-name',
    buildName,
  ]);

  return File(inputPath);
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
    final inputStream = InputFileStream(tempPath);
    final archive = ZipDecoder().decodeBuffer(inputStream);
    archive
        .findFile('universal.apk')!
        .writeContent(OutputFileStream(outputFile.path));

    // Need to close this otherwise we won't be able to delete `tempPath` on Windows.
    await inputStream.close();

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

Future<File> collateAsset(
  Directory outputDir,
  String outName,
  String suffix,
  File inputFile,
) async {
  final ext = extension(inputFile.path);
  return await inputFile.copy(join(outputDir.path, '$outName-$suffix$ext'));
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

Future<Directory> createOutputDir(String tag) async {
  final dir = Directory('$rootWorkDir/release-$tag');
  await dir.create(recursive: true);

  // Create 'latest' symlink
  final link = Link('$rootWorkDir/latest');

  if (await link.exists()) {
    await link.delete();
  }

  await link.create(basename(dir.path));

  return dir;
}

String createFileSuffix(Version version, String commit) {
  final timestamp = DateTime.now();

  final buffer = StringBuffer();

  buffer
    ..write((version.build[0] as int).toString().padLeft(5, '0'))
    ..write('--')
    ..write('v')
    ..write(version.major)
    ..write('.')
    ..write(version.minor)
    ..write('.')
    ..write(version.patch);

  if (version.preRelease.isNotEmpty) {
    buffer
      ..write('--')
      ..write(version.preRelease.join('.'));
  }

  buffer
    ..write('--')
    ..write(formatDate(
      timestamp,
      [yyyy, '-', mm, '-', dd, '--', HH, '-', nn, '-', ss],
    ))
    ..write("-UTC")
    ..write("--$commit");

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
