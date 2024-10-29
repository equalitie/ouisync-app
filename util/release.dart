import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:git/git.dart';
import 'package:args/args.dart';
import 'package:archive/archive_io.dart';
import 'package:async/async.dart';
import 'package:date_format/date_format.dart';
import 'package:github/github.dart';
import 'package:hex/hex.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as p;
import 'package:properties/properties.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pub_semver/pub_semver.dart';

const rootWorkDir = 'releases';
const String windowsArtifactDir = 'build/windows/x64/runner/Release';

enum Flavor {
  production(true, true, true),
  nightly(true, true, false),
  unofficial(false, false, false);

  const Flavor(
      this.requiresSigning, this.requiresSentryDSN, this.doGitCleanCheck);

  final bool requiresSigning;
  final bool requiresSentryDSN;
  final bool doGitCleanCheck;

  static Flavor fromString(String name) {
    switch (name) {
      case "":
      case "production":
        return Flavor.production;
      case "nightly":
        return Flavor.nightly;
      case "unofficial":
        return Flavor.unofficial;
      default:
        throw ('Invalid flavor "$name", must be one of {production, nightly, unofficial}');
    }
  }

  @override
  String toString() {
    switch (this) {
      case Flavor.production:
        return "production";
      case Flavor.nightly:
        return "nightly";
      case Flavor.unofficial:
        return "unofficial";
    }
  }

  String get displayString {
    switch (this) {
      case Flavor.production:
        return "";
      case Flavor.nightly:
        return "nightly";
      case Flavor.unofficial:
        return "unofficial";
    }
  }
}

Future<void> main(List<String> args) async {
  final options = await Options.parse(args);

  final pubspec = Pubspec.parse(await File("pubspec.yaml").readAsString());
  final sentryDSN = await getSentryDSN(options);

  final git = await GitDir.fromExisting(p.current);

  Version version = determineVersion(pubspec, options);

  final commit = await getCommit();
  final buildDesc = BuildDesc(version, commit);

  if (buildDesc.flavor.doGitCleanCheck && !await checkWorkingTreeIsClean(git)) {
    return;
  }

  if (buildDesc.flavor != Flavor.production) {
    await addBadgeToIcons(buildDesc.flavor.displayString);
  }

  // TODO: use `pubspec.name` here but first rename it from "ouisync_app" to "ouisync"
  final name = 'ouisync';

  final outputDir = await createOutputDir(buildDesc);

  List<File> assets = [];

  if (options.apk || options.aab) {
    Flavor flavor = buildDesc.flavor;

    final secrets = switch (flavor.requiresSigning) {
      true => options.androidKeyPropertiesPath != null
          ? AndroidSecrets(options.androidKeyPropertiesPath!)
          : await prepareAndroidSecretsFromPass(flavor),
      false => null,
    };

    try {
      final aab = await buildAab(buildDesc, secrets, sentryDSN);

      if (options.aab) {
        assets.add(await collateAsset(outputDir, name, buildDesc, aab));
      }

      if (options.apk) {
        final apk = await extractApk(aab, flavor, secrets);
        assets.add(await collateAsset(outputDir, name, buildDesc, apk));
      }
    } finally {
      secrets?.destroy();
    }
  }

  if (options.exe) {
    final asset = await buildWindowsInstaller(buildDesc, sentryDSN);
    assets.add(await collateAsset(outputDir, name, buildDesc, asset));
  }

  if (options.msix) {
    /// Right now the MSIX is not signed, therefore, it can only be used for the
    /// Microsoft Store, not for standalone installations.
    ///
    /// Until we get the certificates and sign the MSIX, we don't upload it to
    /// GitHub releases.
    final asset = await buildWindowsMSIX(
        options.identityName!, options.publisher!, sentryDSN);
    assets.add(await collateAsset(outputDir, name, buildDesc, asset));
  }

  if (options.debGui) {
    final asset = await buildDebGUI(
        name: name,
        outputDir: outputDir,
        buildDesc: buildDesc,
        description: pubspec.description ?? '',
        sentryDSN: sentryDSN);
    assets.add(asset);
  }

  if (options.debCli) {
    final asset = await buildDebCLI(
        name: name,
        outputDir: outputDir,
        buildDesc: buildDesc,
        description: pubspec.description ?? '');
    assets.add(asset);
  }

  if (assets.isNotEmpty) {
    print('Built assets:\n');
    for (final asset in assets) {
      print(' * ${asset.path}');
    }
    print('');
  }

  await computeChecksums(assets);

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
  final bool debGui;
  final bool debCli;

  final String? token;
  final RepositorySlug slug;
  final ReleaseAction? action;
  final String? firstCommit;
  final bool detailedLog;
  final String? identityName;
  final String? publisher;
  final bool awaitUpload;
  final Flavor flavor;
  final String? androidKeyPropertiesPath;
  final String? sentryDSN;

  Options._({
    this.apk = false,
    this.aab = false,
    this.exe = false,
    this.msix = false,
    this.debGui = false,
    this.debCli = false,
    this.token,
    required this.slug,
    this.action,
    this.firstCommit,
    this.detailedLog = true,
    this.identityName,
    this.publisher,
    this.awaitUpload = false,
    this.flavor = Flavor.production,
    this.androidKeyPropertiesPath = null,
    this.sentryDSN = null,
  });

  static Future<Options> parse(List<String> args) async {
    final parser = ArgParser();

    parser.addFlag('apk', help: 'Build Android APK', defaultsTo: false);
    parser.addFlag('aab', help: 'Build Android App Bundle', defaultsTo: false);
    parser.addFlag('exe', help: 'Build Windows installer', defaultsTo: false);
    parser.addFlag('msix',
        help: 'Build Windows MSIX package', defaultsTo: false);
    parser.addFlag('deb-gui',
        help: 'Build Linux deb GUI package', defaultsTo: false);
    parser.addFlag('deb-cli',
        help: 'Build Linux deb CLI package', defaultsTo: false);

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
    parser.addOption('flavor',
        help:
            'Specify a build flavor, one of {production, nightly, unofficial}, nightly is the default');

    parser.addOption('android-key-properties',
        help: 'Path to Android key.properties file');

    parser.addOption('sentry',
        help: 'Path to file containing Sentry DSN (single line)');

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

    final androidKeyProperties = results['android-key-properties'];

    if (androidKeyProperties != null) {
      if (!await File(androidKeyProperties).exists()) {
        print(
            "Android keystore properties file '$androidKeyProperties' does not exist");
        exit(1);
      }
    }

    final sentryDSNFile = results['sentry'];
    String? sentryDSN = null;

    if (sentryDSNFile != null) {
      final file = File(sentryDSNFile);

      if (!await file.exists()) {
        print("File containing Sentry DSN does not exist (${file.path})");
        exit(1);
      }

      sentryDSN = (await file.readAsString()).trim();

      if (!(Uri.tryParse(sentryDSN)?.hasAbsolutePath ?? false)) {
        print("Sentry DSN in ${file.path} file is not a valid URI");
        exit(1);
      }
    }

    final apk = results['apk'];
    final aab = results['aab'];
    final exe = results['exe'];
    final msix = results['msix'];
    final debGui = results['deb-gui'];
    final debCli = results['deb-cli'];

    if (!apk && !aab && !exe && !msix && !debGui && !debCli) {
      print(
          "No package to build. Use one or more flags from {--apk, --aab, --exe, --msix, --deb-gui, --deb-cli}");
      exit(1);
    }

    return Options._(
      apk: apk,
      aab: aab,
      exe: exe,
      msix: msix,
      debGui: debGui,
      debCli: debCli,
      token: token?.trim(),
      slug: slug,
      action: action,
      firstCommit: results['first-commit']?.trim(),
      detailedLog: results['detailed-log'],
      identityName: results['identity-name'],
      publisher: results['publisher'],
      awaitUpload: results['await-upload'],
      flavor: Flavor.fromString(results['flavor']),
      androidKeyPropertiesPath: androidKeyProperties,
      sentryDSN: sentryDSN,
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
  // The "foo" in "1.2.3+foo".
  String get buildIdentifier => version.build[0].toString();

  Flavor get flavor => Flavor.fromString(version.preRelease.first.toString());

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

    if (flavor.displayString.isNotEmpty) {
      buffer
        ..write('-')
        ..write(flavor.displayString);
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
Future<File> buildWindowsInstaller(
    BuildDesc buildDesc, String? sentryDSN) async {
  final buildName = buildDesc.toString();

  await run('flutter', [
    'build',
    'windows',
    '--verbose',
    '--release',
    if (sentryDSN != null) '--dart-define=SENTRY_DSN=$sentryDSN',
    '--build-name',
    buildName,
  ]);

  /// Download the Dokan MSI to be bundle with the Ouisync MSIX, into the source
  /// directory (releases/bundled-assets-windows)
  await prepareDokanBundle();

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
Future<File> buildWindowsMSIX(
    String identityName, String publisher, String? sentryDSN) async {
  if (await Directory(windowsArtifactDir).exists()) {
    // We had a problem when creating the msix when there was an executable from
    // previous non-msix builds, the executable was not regenerated and the
    // package was unusable.
    print("Removing artifacts from previous builds");
    //await Directory(windowsArtifactDir).delete(recursive: true);
  }

  final args = [
    '--publisher-display-name',
    'eQualitie Inc',
    '--identity-name',
    identityName,
    '--publisher',
    publisher,
    '--store'
  ];

  /// We first build the MSIX, before adding the additional assets to be
  /// packaged in the MSIX file
  await run('dart', [
    'run',
    if (sentryDSN != null) '--define=SENTRY_DSN=$sentryDSN',
    'msix:build',
    ...args
  ]);

  /// Download the Dokan MSI to be bundle with the Ouisync MSIX, into the source
  /// directory (releases/bundled-assets-windows)
  await prepareDokanBundle();

  /// Package the MSIX, including the Dokan bundled files (script, MSI) inside
  /// the data directory (Release/data/bundled-assets-windows)
  await run('dart', ['run', 'msix:pack', ...args]);

  return File('$windowsArtifactDir/ouisync_app.msix');
}

Future<void> prepareDokanBundle() async {
  final version = "2.1.0.1000";
  final assetPath = 'releases/bundled-assets-windows';
  final name = "Dokan_x64.msi";
  final path = p.join(assetPath, name);

  final file = File(path);

  // Get Dokan (x64) MSI from repo

  if (!await file.exists()) {
    print('Downloading Dokan (x64) MSI');

    final assetDir = Directory(assetPath);

    if (!await assetDir.exists()) {
      await assetDir.create(recursive: true);
    }

    final url =
        'https://github.com/dokan-dev/dokany/releases/download/v$version/$name';
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      await response.pipe(file.openWrite());
    } finally {
      client.close();
    }
  }

  /// Move all additional assets to the data directory (Release/data)
  final dataPath =
      await Directory('$windowsArtifactDir/data/bundled-assets').create();

  final msixAssetsPath = Directory('releases/bundled-assets-windows');
  await copyDirectory(msixAssetsPath, dataPath);

  final scriptsPath = Directory('windows/util/scripts');
  await copyDirectory(scriptsPath, dataPath);
}

////////////////////////////////////////////////////////////////////////////////
//
// deb GUI
//
////////////////////////////////////////////////////////////////////////////////
Future<File> buildDebGUI({
  required String name,
  required Directory outputDir,
  required BuildDesc buildDesc,
  required String? sentryDSN,
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
    if (sentryDSN != null) '--dart-define=SENTRY_DSN=$sentryDSN',
    '--build-name',
    buildName,
  ]);

  final arch = 'amd64';
  final packageName = '$name-gui_${buildDesc}_$arch';

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

  final controlContent = 'Package: $name-gui\n'
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
// deb CLI
//
////////////////////////////////////////////////////////////////////////////////
Future<File> buildDebCLI(
    {required String name,
    required Directory outputDir,
    required BuildDesc buildDesc,
    String description = ''}) async {
  final buildName = buildDesc.toString();

  await run('cargo', ['build', '--release', '--package', 'ouisync-cli'],
      workingDirectory: './ouisync');

  final arch = 'amd64';
  final packageName = '$name-cli_${buildDesc}_$arch';

  final packageDir = Directory('${outputDir.path}/$packageName');

  // Delete any previous dir
  try {
    await packageDir.delete(recursive: true);
  } on PathNotFoundException {
    // ignore if it doesn't exist yet
  }

  await packageDir.create();

  // Copy the binary

  final binDir = Directory('${packageDir.path}/usr/bin');
  await binDir.create(recursive: true);
  await File('./ouisync/target/release/ouisync').copy('${binDir.path}/ouisync');

  // Create debian control file
  final debDir = Directory('${packageDir.path}/DEBIAN');
  await debDir.create();

  final controlContent = 'Package: $name-cli\n'
      'Version: $buildName\n'
      'Architecture: $arch\n'
      'Depends: libfuse2\n'
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
Future<File> buildAab(
    BuildDesc buildDesc, AndroidSecrets? secrets, String? sentryDSN) async {
  Flavor flavor = buildDesc.flavor;

  final env = Map<String, String>();

  if (secrets != null) {
    env['KEYSTORE_PROPERTIES'] = secrets.keystorePropertiesPath;
  }

  final inputFileName = "app-$flavor-release.aab";
  final inputPath = 'build/app/outputs/bundle/${flavor}Release/$inputFileName';

  print('Creating Android App Bundle ...');

  await run(
    'flutter',
    [
      'build',
      'appbundle',
      '--release',
      if (sentryDSN != null) '--dart-define=SENTRY_DSN=$sentryDSN',
      '--build-number',
      buildDesc.buildIdentifier,
      '--flavor=$flavor',
      '--build-name',
      buildDesc.toString(),
    ],
    environment: env,
  );

  return File(inputPath);
}

////////////////////////////////////////////////////////////////////////////////
//
// apk
//
////////////////////////////////////////////////////////////////////////////////
Future<File> extractApk(
    File bundle, Flavor flavor, AndroidSecrets? secrets) async {
  final outputPath = p.setExtension(bundle.path, '.apk');
  final outputFile = File(outputPath);

  if (await outputFile.exists()) {
    await outputFile.delete();
  }

  print('Creating ${outputFile.path} ...');

  final bundletool = await prepareBundletool();

  final tempPath = p.setExtension(bundle.path, '.apks');

  String? storeFile;
  String? storePassword;
  String? keyPassword;
  String? keyAlias;

  if (secrets != null) {
    final keyProperties = Properties.fromFile(secrets.keystorePropertiesPath);
    storeFile = p.join('android/app', keyProperties.get('storeFile')!);
    storePassword = keyProperties.get('storePassword')!;
    keyPassword = keyProperties.get('keyPassword')!;
    keyAlias = keyProperties.get('keyAlias')!;
  }

  await run('java', [
    '-jar',
    bundletool,
    'build-apks',
    '--bundle=${bundle.path}',
    '--mode=universal',
    if (storeFile != null) '--ks=$storeFile',
    if (storePassword != null) '--ks-pass=pass:$storePassword',
    if (keyAlias != null) '--ks-key-alias=$keyAlias',
    if (keyPassword != null) '--key-pass=pass:$keyPassword',
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
    final contentType = p.extension(name) == checksumExtension
        ? 'text/plain'
        : 'application/octet-stream';

    print('Uploading $name ...');

    await client.repositories.uploadReleaseAssets(
      release,
      [
        CreateReleaseAsset(
          name: name,
          contentType: contentType,
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

const checksumExtension = '.sha256';

Future<void> computeChecksums(List<File> assets) async {
  assets.addAll(await Future.wait(assets.map(computeChecksum)));
}

Future<File> computeChecksum(File input) async {
  final algo = Sha256();
  final sink = algo.newHashSink();

  await input.openRead().forEach((chunk) => sink.add(chunk));

  sink.close();

  final hash = HEX.encode((await sink.hash()).bytes);
  final name = p.basename(input.path);

  final output = File('${input.path}$checksumExtension');
  await output.writeAsString('$hash  $name\n');

  return output;
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
      workingDirectory: workingDirectory,
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
      workingDirectory: workingDirectory,
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

Version determineVersion(Pubspec pubspec, Options options) {
  final pubspecVersion = pubspec.version!;
  if (pubspecVersion.isPreRelease) {
    throw "Pre-release string (the \"foo\" in \"1.2.3-foo\") is already set in pubspec.yaml";
  }
  return Version(
      pubspecVersion.major, pubspecVersion.minor, pubspecVersion.patch,
      pre: options.flavor.toString(),
      build: pubspecVersion.build[0].toString());
}

Future<void> run(
  String command,
  List<String> args, {
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  final process = await Process.start(
    command,
    args,
    workingDirectory: workingDirectory,
    // This helps on Windows with finding `command` in $PATH environment variable.
    runInShell: true,
    environment: environment,
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
  List<String> args, {
  String? workingDirectory,
}) async {
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

Future<String?> getSentryDSN(Options options) async {
  if (options.sentryDSN != null) {
    return options.sentryDSN;
  }

  if (!options.flavor.requiresSentryDSN) {
    return null;
  }

  // Get Sentry DSN from `pass`.
  final base = 'cenoers/ouisync/app/${options.flavor}';
  return await runCapture('pass', ['$base/sentry_dsn']);
}

class IconBadgeDesc {
  String fileName;
  String geometry;
  String pointsize;

  IconBadgeDesc(this.fileName, this.pointsize, this.geometry);
}

Future<void> addBadgeToIcons(String text) async {
  String binaryName;

  if (Platform.isWindows) {
    binaryName = "magick";
  } else {
    binaryName = "convert";
  }

  final descriptions = [
    IconBadgeDesc("ic_launcher.png", '40', "+16+16"),
    IconBadgeDesc("ic_launcher_foreground.png", '40', "+100+120"),
    IconBadgeDesc("ic_launcher_round.png", '40', "+16+16"),
    IconBadgeDesc("ouisync_icon.png", '40', "+16+16"),
    IconBadgeDesc("OuisyncFull.png", '40', "+300+16"),
    IconBadgeDesc("Ouisync_v1_1560x1553.png", '200', "+64+124"),
  ];

  for (final desc in descriptions) {
    // Use imagemagick's `convert` because the 'package:image/image.dart' lacks features
    // (and some things like setting a font color doesn't seem to work).
    // TODO: This overwrites the existing png files in git, which is annoying when done not
    // on CI.
    await run(binaryName, [
      'assets/${desc.fileName}',
      '-undercolor',
      'red',
      '-font',
      // Picked randomly by what is on my and the CI machines.
      'DejaVu-Sans',
      '-gravity',
      'SouthEast',
      '-pointsize',
      desc.pointsize,
      '-annotate',
      desc.geometry,
      text,
      'assets/${desc.fileName}',
    ]);
  }
}

class AndroidSecrets {
  String keystorePropertiesPath;
  Future<void> Function()? onDestroy;

  AndroidSecrets(this.keystorePropertiesPath, [this.onDestroy = null]);
  Future<void> destroy() async {
    onDestroy?.call();
  }
}

Future<AndroidSecrets> prepareAndroidSecretsFromPass(Flavor flavor) async {
  final dir = await (await Directory(
              "${Directory.systemTemp.path}/ouisync-android-secrets")
          .create())
      .createTemp();

  final deleteSecrets = () => dir.delete(recursive: true);

  try {
    final base = 'cenoers/ouisync/app/$flavor/android';

    final storePassword = await runCapture('pass', ['$base/storePassword']);
    final keyAlias = await runCapture('pass', ['$base/keyAlias']);
    final keyPassword = await runCapture('pass', ['$base/keyPassword']);

    final keystoreJks = File(dir.path + "/keystore.jks");
    final keystoreJksContent =
        await Process.run('pass', ['$base/keystore.jks'], stdoutEncoding: null);

    await keystoreJks.writeAsBytes(keystoreJksContent.stdout);

    final keystoreProperties = File(dir.path + "/key.properties");
    await keystoreProperties.writeAsString("storePassword=$storePassword\n" +
        "keyAlias=$keyAlias\n" +
        "keyPassword=$keyPassword\n" +
        "storeFile=${keystoreJks.path}\n");

    return AndroidSecrets(keystoreProperties.path, deleteSecrets);
  } catch (e) {
    await deleteSecrets();
    rethrow;
  }
}
