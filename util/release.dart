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
  final suffix = createFileSuffix(version);

  final workDir = await createWorkDir(suffix);
  final aab = await buildAab(suffix, workDir);
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
  String tag,
  Directory workDir, {
  String flavor = "vanilla",
}) async {
  final inputPath =
      'build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab';
  final outputPath = '${workDir.path}/ouisync-$tag.aab';
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
    final commit = await getGitCommit();
    final tagName = buildTagName(version);

    print('Creating release $tagName ($commit) ...');

    final releaseNotes = await client.repositories.generateReleaseNotes(
      CreateReleaseNotes(
        slug.owner,
        slug.name,
        // Using commit instead of tag name here because the tag doesn't exist yet.
        commit,
      ),
    );

    final release = await client.repositories.createRelease(
      slug,
      CreateRelease(tagName)
        ..name = 'Ouisync $tagName'
        ..body = releaseNotes.body
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

    print('Release $tagName ($commit) successfully created');

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

String buildTagName(Version version) {
  final pre = version.preRelease.join('.');
  final v = Version(
    version.major,
    version.minor,
    version.patch,
    pre: pre.isNotEmpty ? pre : null,
  ).canonicalizedVersion;

  return 'v$v';
}

Future<Directory> createWorkDir(String tag) async {
  final dir = Directory('$rootWorkDir/$tag');
  await dir.create(recursive: true);
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

Future<String> getGitCommit() async {
  final result = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
  return result.stdout.trim();
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
