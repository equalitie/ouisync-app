// ignore_for_file: avoid_print

// Tests upgrading the Android app from the latest published release to the current code.
//
// 1. Download the release APK from GitHub and re-sign it with a throwaway test key.
// 2. Install it on an emulator and use Maestro to create repositories in it.
// 3. Build the current code (production flavor, signed with the same test key) and install it
//    over the old version, keeping the app data.
// 4. Use Maestro to verify the repositories created in step 2 still open.
//
// Requirements: flutter, adb, a running Android emulator, Android SDK build-tools (for
// `apksigner` and `aapt2`), `keytool` and `maestro` (https://maestro.dev).
//
// Usage: dart run test/upgrade/run.dart [--from v0.9.4] [--device emulator-5554]

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:hex/hex.dart';
import 'package:path/path.dart' as p;

import '../../util/release.dart' show run, runCapture;

const appId = 'org.equalitie.ouisync';
const gitHubRepo = 'equalitie/ouisync-app';
const flowsDir = 'test/upgrade/flows';
const keyAlias = 'upgrade-test';
const keyPassword = 'upgrade-test';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'from',
      help: 'Release tag to upgrade from (default: the latest release)',
    )
    ..addOption(
      'device',
      help: 'adb serial of the device to use (default: the only connected one)',
    )
    ..addOption(
      'work-dir',
      help: 'Directory for downloads, keys and logs',
      defaultsTo: 'build/upgrade_test',
    )
    ..addOption(
      'target-platform',
      help:
          'Comma separated list of target platforms to build the current version for, '
          'passed to `flutter build apk` (default: all). Building only for the device '
          '(e.g. android-x64 for an emulator) is much faster.',
    )
    ..addFlag(
      'skip-build',
      help: 'Reuse the previously built APK of the current code',
      defaultsTo: false,
    )
    ..addFlag(
      'allow-real-device',
      help:
          'Allow running on a non-emulator device. WARNING: this uninstalls '
          'Ouisync from the device, deleting all its data.',
      defaultsTo: false,
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final options = parser.parse(args);

  if (options['help'] as bool) {
    print(parser.usage);
    return;
  }

  final workDir = Directory(options['work-dir'] as String);
  await workDir.create(recursive: true);

  final adb = Adb(
    await selectDevice(
      options['device'] as String?,
      allowRealDevice: options['allow-real-device'] as bool,
    ),
  );
  final buildTools = await findBuildTools();
  final keystore = await prepareTestKeystore(workDir);

  // Old version
  final release = await fetchRelease(options['from'] as String?);
  print('Upgrading from ${release.tag}');

  final releasedApk = await downloadApk(release, workDir);
  final oldApk = await resignApk(releasedApk, keystore, buildTools);
  final oldVersionCode = await getVersionCode(oldApk, buildTools);

  // New version
  final newApk = (options['skip-build'] as bool)
      ? File(builtApkPath)
      : await buildCurrentApk(
          keystore,
          oldVersionCode + 1,
          targetPlatform: options['target-platform'] as String?,
        );

  final logDir = Directory(p.join(workDir.path, 'logs'));
  if (await logDir.exists()) {
    await logDir.delete(recursive: true);
  }
  await logDir.create(recursive: true);

  try {
    await prepareDevice(adb);

    print('Installing ${release.tag} ...');
    await adb.uninstall(appId);
    await adb.run(['logcat', '-c']);
    await adb.install(oldApk);
    await runMaestro(adb, 'seed.yaml', logDir);

    print('Upgrading to the current version ...');
    await adb.install(newApk, replace: true);
    await runMaestro(adb, 'verify.yaml', logDir);

    print('Upgrade test passed');
  } catch (e) {
    final logcat = File(p.join(logDir.path, 'logcat.txt'));
    await logcat.writeAsString(await adb.capture(['logcat', '-d']));
    print('Upgrade test failed: $e');
    print('Logs and screenshots are in ${logDir.path}');
    exitCode = 1;
  }
}

////////////////////////////////////////////////////////////////////////////////
//
// Device
//
////////////////////////////////////////////////////////////////////////////////

class Adb {
  Adb(this.serial);

  final String serial;

  Future<void> run(List<String> args) => _run('adb', ['-s', serial, ...args]);

  Future<String> capture(List<String> args) =>
      runCapture('adb', ['-s', serial, ...args]);

  Future<void> install(File apk, {bool replace = false}) =>
      run(['install', if (replace) '-r', apk.path]);

  Future<void> uninstall(String packageName) async {
    final installed = await capture(['shell', 'pm', 'list', 'packages']);

    if (LineSplitter.split(installed)
        .any((line) => line.trim() == 'package:$packageName')) {
      await run(['uninstall', packageName]);
    }
  }
}

Future<String> selectDevice(
  String? requested, {
  required bool allowRealDevice,
}) async {
  final output = await runCapture('adb', ['devices']);
  final devices = LineSplitter.split(output)
      .skip(1)
      .map((line) => line.split(RegExp(r'\s+')))
      .where((parts) => parts.length >= 2 && parts[1] == 'device')
      .map((parts) => parts[0])
      .toList();

  final String serial;

  if (requested != null) {
    if (!devices.contains(requested)) {
      throw 'Device $requested not found (connected: $devices)';
    }
    serial = requested;
  } else if (devices.length == 1) {
    serial = devices.single;
  } else if (devices.isEmpty) {
    throw 'No Android device connected. Start an emulator first.';
  } else {
    throw 'Multiple devices connected ($devices), select one with --device';
  }

  // The test uninstalls the app, which would delete the user's real repositories.
  if (!serial.startsWith('emulator-') && !allowRealDevice) {
    throw '$serial is not an emulator. Refusing to run because the test '
        'uninstalls Ouisync. Use --allow-real-device to override.';
  }

  return serial;
}

// Turns off system features that pop up over the app and interfere with the flows. Only done on
// emulators, to not change the settings of a real device.
Future<void> prepareDevice(Adb adb) async {
  if (!adb.serial.startsWith('emulator-')) {
    print('Not an emulator, skipping device preparation');
    return;
  }

  // Stylus handwriting: when a text field gets focus the keyboard may offer to write with a
  // stylus, and that prompt can swallow the text typed by Maestro.
  await adb.run([
    'shell',
    'settings',
    'put',
    'secure',
    'stylus_handwriting_enabled',
    '0',
  ]);
}

Future<void> runMaestro(Adb adb, String flow, Directory logDir) =>
    _run('maestro', [
      '--device',
      adb.serial,
      'test',
      '--debug-output',
      p.join(logDir.path, p.basenameWithoutExtension(flow)),
      p.join(flowsDir, flow),
    ]);

////////////////////////////////////////////////////////////////////////////////
//
// Release download
//
////////////////////////////////////////////////////////////////////////////////

class Release {
  Release(this.tag, this.apkUrl, this.checksumUrl);

  final String tag;
  final Uri apkUrl;
  final Uri checksumUrl;
}

Future<Release> fetchRelease(String? tag) async {
  final path = tag != null ? 'tags/$tag' : 'latest';

  // Unauthenticated GitHub API requests are rate limited per IP address, which may be shared with
  // other jobs (e.g. on CI). A token, if available, raises the limit.
  final token = Platform.environment['GITHUB_TOKEN'];

  final json = jsonDecode(
    await httpGetString(
      Uri.parse('https://api.github.com/repos/$gitHubRepo/releases/$path'),
      headers: {
        if (token != null && token.isNotEmpty)
          HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    ),
  ) as Map<String, dynamic>;

  final assets = (json['assets'] as List).cast<Map<String, dynamic>>();

  Uri findAsset(bool Function(String) predicate) {
    final asset = assets.firstWhere(
      (asset) => predicate(asset['name'] as String),
      orElse: () => throw 'No matching asset in release ${json['tag_name']}',
    );
    return Uri.parse(asset['browser_download_url'] as String);
  }

  bool isApk(String name) =>
      name.startsWith('ouisync_') && name.endsWith('.apk');

  return Release(
    json['tag_name'] as String,
    findAsset(isApk),
    findAsset(
      (name) => name.endsWith('.apk.sha256') && isApk(p.withoutExtension(name)),
    ),
  );
}

Future<File> downloadApk(Release release, Directory workDir) async {
  final file = File(p.join(workDir.path, 'ouisync-${release.tag}.apk'));
  final expected = (await httpGetString(release.checksumUrl))
      .split(RegExp(r'\s+'))
      .first;

  if (await file.exists() && await sha256(file) == expected) {
    print('Using cached ${file.path}');
    return file;
  }

  print('Downloading ${release.apkUrl} ...');
  await file.writeAsBytes(await httpGetBytes(release.apkUrl));

  final actual = await sha256(file);
  if (actual != expected) {
    throw 'Checksum mismatch for ${file.path}: expected $expected, got $actual';
  }

  return file;
}

Future<String> httpGetString(
  Uri url, {
  Map<String, String> headers = const {},
}) async => utf8.decode(await httpGetBytes(url, headers: headers));

Future<List<int>> httpGetBytes(
  Uri url, {
  Map<String, String> headers = const {},
}) async {
  final client = HttpClient();

  try {
    final request = await client.getUrl(url);
    request.headers.set(HttpHeaders.userAgentHeader, 'ouisync-upgrade-test');
    headers.forEach(request.headers.set);
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw 'GET $url failed with status ${response.statusCode}';
    }

    final builder = BytesBuilder(copy: false);
    await response.forEach(builder.add);
    return builder.takeBytes();
  } finally {
    client.close();
  }
}

Future<String> sha256(File file) async {
  final sink = Sha256().newHashSink();
  await file.openRead().forEach(sink.add);
  sink.close();
  return HEX.encode((await sink.hash()).bytes);
}

////////////////////////////////////////////////////////////////////////////////
//
// Signing
//
////////////////////////////////////////////////////////////////////////////////

// Android only allows upgrading in place when both APKs are signed with the same key. We don't
// want the test to need the release key, so we re-sign the released APK with a throwaway key and
// sign the build of the current code with that key too.
class TestKeystore {
  TestKeystore(this.storeFile, this.propertiesFile);

  final File storeFile;
  final File propertiesFile;
}

Future<TestKeystore> prepareTestKeystore(Directory workDir) async {
  final storeFile = File(p.absolute(workDir.path, 'upgrade-test.jks'));
  final propertiesFile = File(p.absolute(workDir.path, 'key.properties'));

  if (!await storeFile.exists()) {
    await _run('keytool', [
      '-genkeypair',
      '-keystore',
      storeFile.path,
      '-storepass',
      keyPassword,
      '-keypass',
      keyPassword,
      '-alias',
      keyAlias,
      '-keyalg',
      'RSA',
      '-keysize',
      '2048',
      '-validity',
      '10000',
      '-dname',
      // No spaces: `run` spawns the command through a shell.
      'CN=OuisyncUpgradeTest',
    ]);
  }

  // Format expected by `loadKeystorePropertiesFile` in `android/app/build.gradle`.
  await propertiesFile.writeAsString(
    'storePassword=$keyPassword\n'
    'keyPassword=$keyPassword\n'
    'keyAlias=$keyAlias\n'
    'storeFile=${storeFile.path}\n',
  );

  return TestKeystore(storeFile, propertiesFile);
}

Future<File> resignApk(
  File input,
  TestKeystore keystore,
  Directory buildTools,
) async {
  final output = File(p.setExtension(input.path, '.resigned.apk'));

  await _run(p.join(buildTools.path, 'apksigner'), [
    'sign',
    '--ks',
    keystore.storeFile.path,
    '--ks-key-alias',
    keyAlias,
    '--ks-pass',
    'pass:$keyPassword',
    '--key-pass',
    'pass:$keyPassword',
    '--out',
    output.path,
    input.path,
  ]);

  return output;
}

Future<Directory> findBuildTools() async {
  final sdk =
      Platform.environment['ANDROID_HOME'] ??
      Platform.environment['ANDROID_SDK_ROOT'];

  if (sdk == null) {
    throw 'Set ANDROID_HOME to the Android SDK location';
  }

  final versions = await Directory(p.join(sdk, 'build-tools')).list().toList();
  if (versions.isEmpty) {
    throw 'No build-tools found in the Android SDK at $sdk';
  }

  versions.sort(
    (a, b) => _compareVersions(p.basename(a.path), p.basename(b.path)),
  );
  return Directory(versions.last.path);
}

int _compareVersions(String a, String b) {
  final pa = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  final pb = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();

  for (var i = 0; i < pa.length && i < pb.length; ++i) {
    if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
  }

  return pa.length.compareTo(pb.length);
}

////////////////////////////////////////////////////////////////////////////////
//
// Build
//
////////////////////////////////////////////////////////////////////////////////

const builtApkPath = 'build/app/outputs/flutter-apk/app-production-release.apk';

Future<int> getVersionCode(File apk, Directory buildTools) async {
  final badging = await runCapture(p.join(buildTools.path, 'aapt2'), [
    'dump',
    'badging',
    apk.path,
  ]);

  final match = RegExp(r"versionCode='(\d+)'").firstMatch(badging);
  if (match == null) {
    throw 'Failed to read versionCode of ${apk.path}';
  }

  return int.parse(match.group(1)!);
}

// `adb install -r` refuses to downgrade, so the build number must be higher than the release's.
Future<File> buildCurrentApk(
  TestKeystore keystore,
  int minBuildNumber, {
  String? targetPlatform,
}) async {
  final pubspecBuildNumber = await _pubspecBuildNumber();
  final buildNumber = pubspecBuildNumber > minBuildNumber
      ? pubspecBuildNumber
      : minBuildNumber;

  print('Building the current version (build number $buildNumber) ...');

  await _run(
    'flutter',
    [
      'build',
      'apk',
      '--release',
      '--flavor=production',
      '--build-number',
      '$buildNumber',
      if (targetPlatform != null) '--target-platform=$targetPlatform',
    ],
    environment: {'STORE_FILE': keystore.propertiesFile.path},
  );

  return File(builtApkPath);
}

Future<int> _pubspecBuildNumber() async {
  final pubspec = await File('pubspec.yaml').readAsString();
  final match = RegExp(
    r'^version:\s*\S+\+(\d+)',
    multiLine: true,
  ).firstMatch(pubspec);
  return match != null ? int.parse(match.group(1)!) : 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Utils
//
////////////////////////////////////////////////////////////////////////////////

// Like `run` from `release.dart` but prints the command first so the log is easier to follow.
Future<void> _run(
  String command,
  List<String> args, {
  Map<String, String>? environment,
}) {
  print('\$ $command ${args.join(' ')}');
  return run(command, args, environment: environment);
}
