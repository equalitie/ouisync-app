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
  // TODO: use `pubspec.name` here but first rename it from "ouisync_app" to "ouisync"
  final name = 'ouisync';
  final version = pubspec.version!;

  final commit = await getCommit();

  final versionName = stripBuild(version).canonicalizedVersion;
  final buildName = '$versionName-$commit';

  final suffix = createFileSuffix(version, commit);
  final outputDir = await createOutputDir(suffix);

  List<File> assets = [];

  if (options.apk || options.aab) {
    final aab = await buildAab(buildName, version.build[0] as int);

    if (options.aab) {
      assets.add(await collateAsset(outputDir, name, suffix, aab));
    }

    if (options.apk) {
      final apk = await extractApk(aab);
      assets.add(await collateAsset(outputDir, name, suffix, apk));
    }
  }

  if (options.exe) {
    final asset = await buildWindowsInstaller(buildName);
    assets.add(await collateAsset(outputDir, name, suffix, asset));
  }

  if (options.msix) {
    /// Right now the MSIX is not signed, therefore, it can only be used for the
    /// Microsoft Store, not for standalone installations.
    ///
    /// Until we get the certificates and sign the MSIX, we don't upload it to
    /// GitHub releases.
    await buildWindowsMSIX(options.identityName, options.publisher);
  }

  if (options.deb) {
    await buildDeb(
      outputDir: outputDir,
      name: name,
      version: versionName,
      commit: commit,
      description: pubspec.description ?? '',
    );
  }

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
  final bool apk;
  final bool aab;
  final bool exe;
  final bool msix;
  final bool deb;

  final String? token;
  final String? firstCommit;
  final bool detailedLog;
  final String? identityName;
  final String? publisher;

  Options._({
    this.apk = false,
    this.aab = false,
    this.exe = false,
    this.msix = false,
    this.deb = false,
    this.token,
    this.firstCommit,
    this.detailedLog = true,
    this.identityName,
    this.publisher,
  });

  static Future<Options> parse(List<String> args) async {
    final parser = ArgParser();

    parser.addFlag('apk', help: 'Build Android APK', defaultsTo: true);
    parser.addFlag('aab', help: 'Build Android App Bundle', defaultsTo: true);
    parser.addFlag('exe', help: 'Build Windows installer', defaultsTo: true);
    parser.addFlag('msix',
        help: 'Build Windows MSIX package', defaultsTo: true);
    parser.addFlag('deb', help: 'Build Linux deb package', defaultsTo: true);

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
      apk: results['apk'],
      aab: results['aab'],
      exe: results['exe'],
      msix: results['msix'],
      deb: results['deb'],
      token: token?.trim(),
      firstCommit: results['first-commit']?.trim(),
      detailedLog: results['detailed-log'],
      identityName: results['identity-name'],
      publisher: results['publisher'],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
//
// exe
//
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
//
// msix
//
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
//
// deb
//
////////////////////////////////////////////////////////////////////////////////
Future<File> buildDeb({
  required Directory outputDir,
  required String name,
  required String version,
  String? commit,
  String description = '',
}) async {
  final buildName = commit != null ? '$version-$commit' : version;

  await run('flutter', [
    'build',
    'linux',
    '--build-name',
    buildName,
  ]);

  final arch = 'amd64';
  final revision = commit != null ? '0+$commit' : '0';
  final packageName = '${name}_$version-${revision}_$arch';

  final packageDir = Directory('${outputDir.path}/$packageName');

  // Delete any previous dir
  try {
    await packageDir.delete(recursive: true);
  } on PathNotFoundException {
    // ignore if it doesn't exist yet
  }

  await packageDir.create();

  // Copy files
  final bundleDir = Directory('build/linux/x64/release/bundle');

  final libDir = Directory('${packageDir.path}/usr/lib/$name');
  await libDir.create(recursive: true);
  await copyDirectory(bundleDir, libDir);

  // HACK: rename the binary 'ouisync_app' -> 'ouisync'
  await File('${libDir.path}/ouisync_app').rename('${libDir.path}/$name');

  final binDir = Directory('${packageDir.path}/usr/bin');
  await binDir.create();
  await Link('${binDir.path}/$name').create('../lib/$name/$name');

  // Create desktop file
  final desktopDir = Directory('${packageDir.path}/usr/share/applications');
  await desktopDir.create(recursive: true);

  final capitalizedName = '${name[0].toUpperCase()}${name.substring(1)}';

  final desktopContent = '[Desktop Entry]\n'
      'Name=$capitalizedName\n'
      'GenericName=File synchronization\n'
      'Version=$version-$revision\n'
      'Comment=$description\n'
      'Exec=/usr/bin/$name\n'
      'Terminal=false\n'
      'Type=Application\n'
      'Icon=$name\n'
      'Categories=Network;FileTransfer;P2P\n';
  await File('${desktopDir.path}/$name.desktop').writeAsString(desktopContent);

  // Add icon
  // TODO: other resolutions?
  final iconDir =
      Directory('${packageDir.path}/usr/share/icons/hicolor/192x192/apps');
  await iconDir.create(recursive: true);
  await File('assets/ic_launcher.png').copy('${iconDir.path}/$name.png');

  // Create debian control file
  final debDir = Directory('${packageDir.path}/DEBIAN');
  await debDir.create();

  final controlContent = 'Package: $name\n'
      'Version: $version-$revision\n'
      'Architecture: $arch\n'
      // TODO: dependencies
      'Maintainer: Ouisync developers <support@ouisync.net>\n'
      'Description: $description\n';
  await File('${debDir.path}/control').writeAsString(controlContent);

  final package = File('${outputDir.path}/$packageName.deb');

  await run('dpkg-deb', [
    '--root-owner-group',
    '-b',
    packageDir.path,
    package.path,
  ]);

  return package;
}

////////////////////////////////////////////////////////////////////////////////
//
// aab
//
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
//
// apk
//
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
//
// utils
//
////////////////////////////////////////////////////////////////////////////////

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
    ..write('+')
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
    final dstPath = join(dst.path, relative(srcEntry.path, from: src.path));

    if (srcEntry is File) {
      final dstEntry = File(dstPath);
      await Directory(dstEntry.parent.path).create(recursive: true);
      await srcEntry.copy(dstEntry.path);
    } else if (srcEntry is Directory) {
      await Directory(dstPath).create(recursive: true);
    }
  }
}
