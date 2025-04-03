import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/navigation.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_entry.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/random.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

void main() {
  // Needed for `NativeChannels`.
  WidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late ReposCubit reposCubit;
  late RepoCreationCubit repoCreationCubit;

  setUp(() async {
    final appDir = await getApplicationSupportDirectory();
    await appDir.create(recursive: true);

    session = await Session.create(configPath: p.join(appDir.path, 'config'));
    await session.setStoreDir(p.join(appDir.path, 'store'));

    final settings = await Settings.init(MasterKey.random());

    reposCubit = ReposCubit(
      session: session,
      nativeChannels: NativeChannels(),
      settings: settings,
      navigation: NavigationCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers(session),
    );

    repoCreationCubit = RepoCreationCubit(reposCubit: reposCubit);
  });

  tearDown(() async {
    await repoCreationCubit.close();
    await reposCubit.close();
    await session.close();
  });

  test('create repository with default local secret', () async {
    final name = 'my repo';

    expect(
      repoCreationCubit.state.substate,
      isA<RepoCreationPending>()
          .having((s) => s.location, 'location', isNull)
          .having((s) => s.setLocalSecret, 'setLocalSecret',
              isA<SetLocalSecretKeyAndSalt>())
          .having((s) => s.nameError, 'nameError', isNull),
    );

    repoCreationCubit.nameController.text = name;

    await repoCreationCubit
        .waitUntil((state) => state.substate is RepoCreationValid);
    expect(repoCreationCubit.state.name, equals(name));

    await repoCreationCubit.save();
    expect(repoCreationCubit.state.substate, isA<RepoCreationSuccess>());
    expect(
      reposCubit.state.repos.values
          .where((entry) => entry.name == name)
          .firstOrNull,
      isA<OpenRepoEntry>(),
    );
  });

  test('attempt to create repository with existing name', () async {
    // Need to load localized strings, for the error message.
    await S.load(Locale.fromSubtags(languageCode: 'en'));

    final name = 'my repo';
    await reposCubit.createRepository(
      location: RepoLocation(
        dir: (await session.getStoreDir())!,
        name: name,
      ),
      setLocalSecret: SetLocalSecretKeyAndSalt(
        key: randomSecretKey(),
        salt: randomSalt(),
      ),
      localSecretMode: LocalSecretMode.randomStored,
    );

    repoCreationCubit.nameController.text = name;

    await repoCreationCubit.waitUntil((state) {
      final substate = state.substate;
      return substate is RepoCreationPending && substate.nameError != null;
    });

    expect(
      repoCreationCubit.state.substate,
      isA<RepoCreationPending>().having(
          (s) => s.nameError,
          'nameError',
          equals(
            'There is already a repository with this name',
          )),
    );
  });

  // TODO: more tests
}
