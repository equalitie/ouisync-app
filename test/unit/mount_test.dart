import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/entry_selection.dart';
import 'package:ouisync_app/app/cubits/mount.dart';
import 'package:ouisync_app/app/cubits/navigation.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies deps;
  late RepoCubit repoCubit;

  setUp(() async {
    deps = await TestDependencies.create();

    final repo = await deps.session.createRepository(
      path: randomAsciiString(32),
      readSecret: null,
      writeSecret: null,
    );

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});

    repoCubit = await RepoCubit.create(
      repo: repo,
      session: deps.session,
      navigation: NavigationCubit(),
      entrySelection: EntrySelectionCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers(deps.session),
    );
  });

  tearDown(() async {
    await repoCubit.close();
    await deps.dispose();
  });

  test('read mounted file', () async {
    final path = '/hello.txt';
    final content = 'hello world';
    final contentBytes = utf8.encode(content);

    // Upload the file to the repo
    await repoCubit.saveFile(
      filePath: path,
      length: contentBytes.length,
      fileByteStream: Stream.value(contentBytes),
    );

    // Mount it and try to read the mounted file
    deps.mountCubit.init();
    await deps.mountCubit.waitUntil((state) => state is MountStateSuccess);

    final mountRoot = await repoCubit.mountPoint;
    expect(mountRoot, isNotEmpty);

    final mountPath = '$mountRoot$path';
    final mountContent = await io.File(mountPath).readAsString();

    expect(mountContent, equals(content));
  }, tags: ['mount']);
}
