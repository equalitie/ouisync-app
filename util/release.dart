import 'dart:async';
import 'dart:io';

import 'package:git/git.dart';
import 'package:args/args.dart';
import 'package:archive/archive_io.dart';
import 'package:async/async.dart';
import 'package:date_format/date_format.dart';
import 'package:github/github.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as p;
import 'package:properties/properties.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pub_semver/pub_semver.dart';

import 'script_tools.dart';

const rootWorkDir = 'releases';

Future<void> main(List<String> args) async {
  final options = await Options.parse(args);

  final pubspec = Pubspec.parse(await File("pubspec.yaml").readAsString());

  final git = await GitDir.fromExisting(p.current);

  if (!await checkWorkingTreeIsClean(git)) {
    return;
  }

  // TODO: use `pubspec.name` here but first rename it from "ouisync_app" to "ouisync"
  final name = 'ouisync';
  final version = pubspec.version!;
  final commit = await getCommit();

  final buildDesc = BuildDesc(version, commit);
  final outputDir = await createOutputDir(buildDesc);

  List<File> assets = [];

  if (options.apk || options.aab) {
    final aab = await buildAab(buildDesc);

    if (options.aab) {
      assets.add(await collateAsset(outputDir, name, buildDesc, aab));
    }

    if (options.apk) {
      final apk = await extractApk(aab);
      assets.add(await collateAsset(outputDir, name, buildDesc, apk));
    }
  }

  if (options.exe) {
    final asset = await buildWindowsInstaller(buildDesc);
    assets.add(await collateAsset(outputDir, name, buildDesc, asset));
  }

  if (options.msix) {
    /// Right now the MSIX is not signed, therefore, it can only be used for the
    /// Microsoft Store, not for standalone installations.
    ///
    /// Until we get the certificates and sign the MSIX, we don't upload it to
    /// GitHub releases.
    final asset = await buildWindowsMSIX(
      options.additionalAssetsLocation,
      options.identityName!,
      options.publisher!,
    );
    assets.add(await collateAsset(outputDir, name, buildDesc, asset));
  }

  if (options.deb) {
    final asset = await buildDeb(
      name: name,
      outputDir: outputDir,
      buildDesc: buildDesc,
      description: pubspec.description ?? '',
    );
    assets.add(asset);
  }

  if (assets.isNotEmpty) {
    print('Built assets:\n');
    for (final asset in assets) {
      print(' * ${asset.path}');
    }
    print('');
  }

  final auth = options.token != null
      ? Authentication.withToken(options.token)
      : Authentication.anonymous();

  if (options.action != null && options.awaitUpload) {
    print("Press any key to start uploading to github");
    // Doing async readline is a bit cumbersome, and the sync version will work just fine.
    // https://gist.github.com/frencojobs/dca6a24e07ada2b9df1683ddc8fa45c6?permalink_comment_id=4057248#gistcomment-4057248
    stdin.readLineSync();
  }

  final client = GitHub(auth: auth);

  try {
    switch (options.action) {
      case ReleaseAction.create:
        final release = await createRelease(
          client,
          options.slug,
          version: version,
          first: options.firstCommit,
          last: commit,
          detailedLog: options.detailedLog,
        );
        await uploadAssets(client, release, assets);
        break;

      case ReleaseAction.update:
        final release = await findLatestDraftRelease(client, options.slug);
        await uploadAssets(client, release, assets);
        break;

      case null:
        break;
    }
  } finally {
    client.dispose();
  }
}

class Options {
  final bool apk;
  final bool aab;
  final bool exe;
  final bool msix;
  final bool deb;

  final String? additionalAssetsLocation;
  final String? token;
  final RepositorySlug slug;
  final ReleaseAction? action;
  final String? firstCommit;
  final bool detailedLog;
  final String? identityName;
  final String? publisher;
  final bool awaitUpload;

  Options._({
    this.apk = false,
    this.aab = false,
    this.exe = false,
    this.msix = false,
    this.deb = false,
    this.additionalAssetsLocation,
    this.token,
    required this.slug,
    this.action,
    this.firstCommit,
    this.detailedLog = true,
    this.identityName,
    this.publisher,
    this.awaitUpload = false,
  });

  static Future<Options> parse(List<String> args) async {
    final parser = ArgParser();

    parser.addFlag('apk', help: 'Build Android APK', defaultsTo: true);
    parser.addFlag('aab', help: 'Build Android App Bundle', defaultsTo: true);
    parser.addFlag('exe',
        help: 'Build Windows installer', defaultsTo: Platform.isWindows);
    parser.addFlag('msix',
        help: 'Build Windows MSIX package', defaultsTo: Platform.isWindows);
    parser.addFlag('deb',
        help: 'Build Linux deb package', defaultsTo: Platform.isLinux);

    parser.addOption(
      'additional-assets',
      abbr: 'a',
      help:
          'Path to a folder containing any additional assets to be bundle with the MSIX. This assets will be place in the <data> folder, in the same location as the executable.',
    );
    parser.addOption(
      'token-file',
      abbr: 't',
      help:
          'Path to a file containing the GitHub API access token. If omitted, still builds the packages but does not create a GitHub release',
    );
    parser.addOption(
      'repo',
      abbr: 'r',
      help: 'GitHub repository slug (owner/name)',
      defaultsTo: 'equalitie/ouisync-app',
    );
    parser.addFlag(
      'create',
      abbr: 'c',
      negatable: false,
      help:
          'Create new release and upload the assets to it (conflicts with --update)',
      defaultsTo: false,
    );
    parser.addFlag(
      'update',
      abbr: 'u',
      negatable: false,
      help:
          'Do not create new release, upload the assets to the latest existing draft release instead (conflicts with --create)',
      defaultsTo: false,
    );
    parser.addFlag(
      'await-upload',
      defaultsTo: false,
      help:
          'Await user pressing enter to start uploading, useful for when doing --create and --update concurrently on two different PCs',
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
      defaultsTo: 'eQualitieInc.Ouisync',
    );
    parser.addOption(
      'publisher',
      abbr: 'b',
      help:
          'The Publisher (CN) value for the app in the Microsoft Store (For the MSIX)',
      defaultsTo: 'CN=E3D17812-E9F1-46C8-B650-4D39786777D9',
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

    if (results['create'] && results['update']) {
      print('At most one of --create, --update can be used at the same time');
      exit(1);
    }

    final tokenFilePath = results['token-file'];
    final token = (tokenFilePath != null)
        ? await File(tokenFilePath).readAsString()
        : null;

    final slug = RepositorySlug.full(results['repo']!);

    final action = results['create']
        ? ReleaseAction.create
        : results['update']
            ? ReleaseAction.update
            : null;

    if (results['msix']) {
      if (results['identity-name'] == null || results['publisher'] == null) {
        print(
            "The Windows MSIX creation requires the --identity-name and --publisher parameters");
        exit(1);
      }
    }

    return Options._(
      apk: results['apk'],
      aab: results['aab'],
      exe: results['exe'],
      msix: results['msix'],
      deb: results['deb'],
      additionalAssetsLocation: results['additional-assets'],
      token: token?.trim(),
      slug: slug,
      action: action,
      firstCommit: results['first-commit']?.trim(),
      detailedLog: results['detailed-log'],
      identityName: results['identity-name'],
      publisher: results['publisher'],
      awaitUpload: results['await-upload'],
    );
  }
}

enum ReleaseAction {
  create,
  update,
}

class BuildDesc {
  final Version version;
  final DateTime timestamp;
  final String commit;

  BuildDesc(this.version, this.commit) : timestamp = DateTime.now();

  String get versionString => _formatVersion(StringBuffer()).toString();
  String get revisionString => _formatRevision(StringBuffer()).toString();

  @override
  String toString() {
    final buffer = StringBuffer();

    _formatVersion(buffer);

    buffer.write('-');

    _formatRevision(buffer);

    return buffer.toString();
  }

  StringBuffer _formatVersion(StringBuffer buffer) {
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

    return buffer;
  }

  StringBuffer _formatTimestamp(StringBuffer buffer, [String separator = '']) =>
      buffer
        ..write(formatDate(
          timestamp,
          [
            yyyy,
            separator,
            mm,
            separator,
            dd,
            separator,
            HH,
            separator,
            nn,
            separator,
            ss,
          ],
        ));

  StringBuffer _formatRevision(StringBuffer buffer) => _formatTimestamp(buffer)
    ..write('.')
    ..write(commit);
}

////////////////////////////////////////////////////////////////////////////////
//
// exe
//
////////////////////////////////////////////////////////////////////////////////
Future<File> buildWindowsInstaller(BuildDesc buildDesc) async {
  final buildName = buildDesc.toString();

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
  await File("build/inno-setup.iss").writeAsString(
    innoScript.replaceAll("<APP_VERSION>", buildName),
  );

  await run("C:/Program Files (x86)/Inno Setup 6/Compil32.exe",
      ['/cc', 'build/inno-setup.iss']);

  return File('build/windows/x64/runner/Release/ouisync-installer.exe');
}

////////////////////////////////////////////////////////////////////////////////
//
// msix
//
////////////////////////////////////////////////////////////////////////////////
Future<File> buildWindowsMSIX(String? additionalAssetsLocation,
    String identityName, String publisher) async {
  final artifactDir = 'build/windows/x64/runner/Release';

  if (await Directory(artifactDir).exists()) {
    // We had a problem when creating the msix when there was an executable from
    // previous non-msix builds, the executable was not regenerated and the
    // package was unusable.
    print("Removing artifacts from previous builds");
    await Directory(artifactDir).delete(recursive: true);
  }

  String command = 'create';
  if (additionalAssetsLocation != null) {
    command = 'pack';

    await run('dart', ['run', 'msix:build']);

    final additionalAssetsPath = p.join(artifactDir, additionalAssetsLocation);
    await Directory(additionalAssetsPath).create();

    //Add files
    Directory(additionalAssetsLocation).listSync().forEach((element) async {
      final fileName = p.basename(element.path);
      final file = File(element.path);

      await file.copy(p.join(additionalAssetsPath, fileName));
    });
  }

  await run('dart', [
    'run',
    'msix:$command',
    '-u',
    'eQualitie Inc',
    '-i',
    identityName,
    '-b',
    publisher,
    '--store'
  ]);

  return File('$artifactDir/ouisync_app.msix');
}

////////////////////////////////////////////////////////////////////////////////
//
// deb
//
////////////////////////////////////////////////////////////////////////////////
Future<File> buildDeb({
  required String name,
  required Directory outputDir,
  required BuildDesc buildDesc,
  String description = '',
}) async {
  // At some point we'll want to include the command line `ouisync`
  // executable as well, so we rename this flutter app so as to not clash
  // with it.
  // NOTE: This must be the same as `BINARY_NAME` defined in `linux/CMakeList.txt`.
  final executableName = "$name-gui";
  // Unique ID for the GTK application.
  // NOTE: This must be the same as `APPLICATION_ID` defined in `linux/CMakeList.txt`.
  final applicationId = "org.equalitie.$name";

  final buildName = buildDesc.toString();

  await run('flutter', [
    'build',
    'linux',
    '--build-name',
    buildName,
  ]);

  final arch = 'amd64';
  final packageName = '${name}_${buildDesc}_$arch';

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

  final binDir = Directory('${packageDir.path}/usr/bin');
  await binDir.create();
  await Link('${binDir.path}/$executableName')
      .create('../lib/$name/$executableName');

  // Create desktop file
  final desktopDir = Directory('${packageDir.path}/usr/share/applications');
  await desktopDir.create(recursive: true);

  final capitalizedName = '${name[0].toUpperCase()}${name.substring(1)}';

  final desktopContent = '[Desktop Entry]\n'
      'Name=$capitalizedName\n'
      'GenericName=File synchronization\n'
      'Version=$buildName\n'
      'Comment=$description\n'
      'Exec=/usr/bin/$executableName\n'
      'Terminal=false\n'
      'Type=Application\n'
      'Icon=$name\n'
      'Categories=Network;FileTransfer;P2P\n';
  await File('${desktopDir.path}/$applicationId.desktop')
      .writeAsString(desktopContent);

  // Add icon
  final iconSrc = File('assets/ouisync_icon.png');

  for (final res in [16, 22, 24, 32, 48, 64, 128, 256]) {
    final iconDir = Directory(
        '${packageDir.path}/usr/share/icons/hicolor/${res}x$res/apps');
    await iconDir.create(recursive: true);

    final iconDst = File('${iconDir.path}/$name.png');

    await createIcon(iconSrc, iconDst, res);
  }

  // Create debian control file
  final debDir = Directory('${packageDir.path}/DEBIAN');
  await debDir.create();

  final controlContent = 'Package: $name\n'
      'Version: $buildName\n'
      'Architecture: $arch\n'
      'Depends: libgtk-3-0, libsecret-1-0, libfuse2, libayatana-appindicator3-1, libappindicator3-1\n'
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
Future<File> buildAab(BuildDesc buildDesc) async {
  final inputPath = 'build/app/outputs/bundle/release/app-release.aab';

  print('Creating Android App Bundle ...');

  await run('flutter', [
    'build',
    'appbundle',
    '--release',
    '--build-number',
    buildDesc.version.build[0].toString(),
    '--build-name',
    buildDesc.toString(),
  ]);

  return File(inputPath);
}

////////////////////////////////////////////////////////////////////////////////
//
// apk
//
////////////////////////////////////////////////////////////////////////////////
Future<File> extractApk(File bundle) async {
  final outputPath = p.setExtension(bundle.path, '.apk');
  final outputFile = File(outputPath);

  if (await outputFile.exists()) {
    await outputFile.delete();
  }

  print('Creating ${outputFile.path} ...');

  final bundletool = await prepareBundletool();

  final keyProperties = Properties.fromFile('secrets/android/key.properties');
  final storeFile = p.join('android/app', keyProperties.get('storeFile')!);
  final storePassword = keyProperties.get('storePassword')!;
  final keyPassword = keyProperties.get('keyPassword')!;

  final tempPath = p.setExtension(bundle.path, '.apks');

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
  final path = p.join(rootWorkDir, name);

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

Future<Release> createRelease(
  GitHub client,
  RepositorySlug slug, {
  required Version version,
  String? first,
  required String last,
  bool detailedLog = true,
}) async {
  final tagName = buildTagName(version);

  print('Creating release $tagName ($last) ...');

  if (first == null) {
    try {
      final prev = await client.repositories.getLatestRelease(slug);
      first = prev.tagName!;
    } on NotFound {
      print('No previous release found');
      rethrow;
    }
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
        ..isDraft = true
        ..isPrerelease = false);

  print('Release $tagName ($last) successfully created: ${release.htmlUrl}');

  return release;
}

Future<Release> findLatestDraftRelease(
  GitHub client,
  RepositorySlug slug,
) async {
  final release = await client.repositories.listReleases(slug).firstOrNull;

  if (release != null && (release.isDraft ?? false)) {
    return release;
  }

  throw 'No latest draft release found';
}

Future<void> uploadAssets(
  GitHub client,
  Release release,
  List<File> assets,
) async {
  for (final asset in assets) {
    final name = p.basename(asset.path);
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

  print('${assets.length} assets successfully uploaded');
}

Future<File> collateAsset(
  Directory outputDir,
  String name,
  BuildDesc buildDesc,
  File inputFile, {
  String suffix = '',
}) async {
  final ext = p.extension(inputFile.path);
  return await inputFile
      .copy(p.join(outputDir.path, '${name}_$buildDesc$suffix$ext'));
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

  // Library
  final libSlug = RepositorySlug(slug.owner, 'ouisync');
  final libLast = await getSubmoduleCommit(
    last,
    'ouisync',
  );
  final libFirst = await getSubmoduleCommit(
    first,
    'ouisync',
  );

  if (libFirst != null && libLast != null && libFirst != libLast) {
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
        'ouisync',
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

Future<String?> getSubmoduleCommit(String superCommit, String submodule) async {
  final output = await runCapture(
    'git',
    ['ls-tree', superCommit, submodule],
  );
  final parts = output.split(RegExp(r'\s+'));

  if (parts.length < 3) {
    // The above can fail if we moved/renamed submodules.
    return null;
  }

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

Future<Directory> createOutputDir(BuildDesc buildDesc) async {
  final dir = Directory('$rootWorkDir/release_$buildDesc');
  await dir.create(recursive: true);

  // Create 'latest' symlink
  final link = Link('$rootWorkDir/latest');

  if (await link.exists()) {
    await link.delete();
  }

  await link.create(p.basename(dir.path));

  return dir;
}

// Check if working tree is clean and if not confirm with the caller if we want to continue.
Future<bool> checkWorkingTreeIsClean(GitDir git) async {
  if (!await git.isWorkingTreeClean()) {
    while (true) {
      print("Git is dirty, continue anyway? [y/n/diff]");
      final input = stdin.readLineSync();
      if (input == 'y') {
        return true;
      } else if (input == 'n') {
        return false;
      } else if (input == 'diff') {
        await run('git', ['diff', '--color=always']);
      }
    }
  }
  return true;
}

Future<void> createIcon(File src, File dst, int resolution) async {
  final command = image.Command()
    ..decodeImageFile(src.path)
    ..copyResize(
      width: resolution,
      height: resolution,
      interpolation: image.Interpolation.cubic,
    )
    ..writeToFile(dst.path);

  await command.executeThread();
}
