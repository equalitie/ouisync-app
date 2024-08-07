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
import 'package:ouisync_app/app/utils/mounter.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as repo_path;
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

void main() {
  // Needed for `NativeChannels`.
  WidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late ReposCubit reposCubit;
  late RepoCreationCubit repoCreationCubit;

  setUp(() async {
    final configPath = repo_path.join(
      (await getApplicationSupportDirectory()).path,
      'config',
    );

    session = Session.create(
      kind: SessionKind.unique,
      configPath: configPath,
    );

    final nativeChannels = NativeChannels(session);
    final settings = await Settings.init(MasterKey.random());

    reposCubit = ReposCubit(
      session: session,
      nativeChannels: nativeChannels,
      settings: settings,
      navigation: NavigationCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers.disabled,
      mounter: Mounter(session),
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
              isA<LocalSecretKeyAndSalt>())
          .having((s) => s.nameError, 'nameError', isNull),
    );

    repoCreationCubit.nameController.text = name;

    await repoCreationCubit
        .waitUntil((state) => state.substate is RepoCreationValid);
    expect(repoCreationCubit.state.name, equals(name));

    await repoCreationCubit.save();
    expect(repoCreationCubit.state.substate, isA<RepoCreationSuccess>());
    expect(
      reposCubit.repos.where((entry) => entry.name == name).firstOrNull,
      isA<OpenRepoEntry>(),
    );
  });

  test('attempt to create repository with existing name', () async {
    // Need to load localized strings, for the error message.
    await S.load(Locale.fromSubtags(languageCode: 'en'));

    final name = 'my repo';
    await reposCubit.createRepository(
      location: RepoLocation.fromParts(
        dir: await reposCubit.settings.getDefaultRepositoriesDir(),
        name: name,
      ),
      setLocalSecret: LocalSecretKeyAndSalt.random(),
      localSecretMode: LocalSecretMode.randomStored,
    );

    repoCreationCubit.nameController.text = name;
    await repoCreationCubit.waitUntil((state) => state.loading);
    await repoCreationCubit.waitUntil((state) => !state.loading);

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
