import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:archive/archive_io.dart';
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

  final workDir = await createWorkDir(version);
  final aab = await buildAab(version, workDir);
  final apk = await extractApk(aab);

  final token = options.token;
  if (token != null) {
    await upload(version, [apk, aab], token);
  } else {
    print(
        'no GitHub API access token specified - skipping creation of GitHub release');
  }
}

class Options {
  final String? token;

  Options._({this.token});

  static Future<Options> parse(List<String> args) async {
    final parser = ArgParser();
    parser.addOption(
      'token-file',
      abbr: 't',
      help: 'Path to a file with the GitHub API access token',
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

    return Options._(token: token?.trim());
  }
}

Future<File> buildAab(
  Version version,
  Directory workDir, {
  String flavor = "vanilla",
}) async {
  final inputPath =
      'build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab';
  final outputPath = '${workDir.path}/ouisync-$version.aab';
  var outputFile = File(outputPath);

  if (await outputFile.exists()) {
    print('Not creating $outputPath - already exists');
    return outputFile;
  }

  print('Creating ${outputFile.path} ...');

  await run('flutter', [
    'build',
    'appbundle',
    '--flavor',
    flavor,
    '-t' 'lib/main_$flavor.dart',
    '--release',
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

Future<void> upload(
  Version version,
  List<File> assets,
  String token,
) async {
  final client = GitHub(auth: Authentication.withToken(token));
  final slug = RepositorySlug('equalitie', 'ouisync-app');

  try {
    final versionString = buildVersionString(version);

    print('Creating release $versionString ...');

    final createRelease = CreateRelease(versionString)
      ..name = 'Ouisync $versionString'
      ..isDraft = true;
    final release =
        await client.repositories.createRelease(slug, createRelease);

    for (final asset in assets) {
      final name = basename(asset.path);
      final content = await asset.readAsBytes();

      print('Uploading $name ...');

      final createReleaseAsset = CreateReleaseAsset(
        name: name,
        contentType: 'application/octet-stream',
        assetData: content,
      );

      await client.repositories
          .uploadReleaseAssets(release, [createReleaseAsset]);
    }

    print('Release $versionString successfully created');

    // Remove previous drafts
    await for (final oldRelease in client.repositories.listReleases(slug)) {
      if (oldRelease.id == release.id) {
        continue;
      }

      if (!(oldRelease.isDraft ?? false)) {
        continue;
      }

      print('Removing outdated draft release ${oldRelease.name}');
      await client.repositories.deleteRelease(slug, oldRelease);
    }
  } finally {
    client.dispose();
  }
}

String buildVersionString(Version version) {
  final pre = version.preRelease.join('.');
  final v = Version(
    version.major,
    version.minor,
    version.patch,
    pre: pre.isNotEmpty ? pre : null,
  ).canonicalizedVersion;

  return 'v$v';
}

Future<Directory> createWorkDir(Version version) async {
  final dir = Directory('$rootWorkDir/v$version');
  await dir.create(recursive: true);
  return dir;
}

Future<void> run(String command, List<String> args) async {
  final process = await Process.start(command, args);

  unawaited(process.stdout.transform(utf8.decoder).forEach(stdout.write));
  unawaited(process.stderr.transform(utf8.decoder).forEach(stderr.write));

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw 'Command "$command" failed with exit code $exitCode';
  }
}
