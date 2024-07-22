import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/cubits/cubits.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/repo_path.dart' as repo_path;
import 'package:ouisync_app/app/utils/share_token.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late ReposCubit reposCubit;
  late RepoCreationCubit repoCreationCubit;

  final String tokenString =
      'https://ouisync.net/r#AwAgTmm8jPQuimEWzqVcM17M2-3GXIULZQ1tbQRVsBgj9PY?name=uno';

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
    );

    repoCreationCubit = RepoCreationCubit(reposCubit: reposCubit);
  });

  tearDown(() async {
    await repoCreationCubit.close();
    await reposCubit.close();
    await session.close();
  });

  test('create repository with blind token', () async {
    final token = await parseShareToken(reposCubit, tokenString);
    expect(
        token,
        isA<ShareTokenValid>()
            .having((t) => t.value, 'token', isNotNull)
            .having((t) => t.error, 'error', isNull));

    final tokenAccesMode = await (token as ShareTokenValid).value.mode;
    expect(
        tokenAccesMode,
        isA<AccessMode>()
            .having((t) => t.name, 'mode', equals(AccessMode.blind.name)));

    final suggestedRepoName = await token.value.suggestedName;

    expect(
      repoCreationCubit.state.substate,
      isA<RepoCreationPending>()
          .having((s) => s.location, 'location', isNull)
          .having((s) => s.setLocalSecret, 'setLocalSecret',
              isA<LocalSecretKeyAndSalt>())
          .having((s) => s.nameError, 'nameError', isNull),
    );

    repoCreationCubit.nameController.text = suggestedRepoName;

    await repoCreationCubit
        .waitUntil((state) => state.substate is RepoCreationValid);
    expect(repoCreationCubit.state.name, equals(suggestedRepoName));

    await repoCreationCubit.setToken(token.value);

    expect(
        repoCreationCubit.state.localSecretMode,
        isA<LocalSecretMode>().having((lsm) => lsm.name, 'local_secret_mode',
            LocalSecretMode.manual.name));

    await repoCreationCubit.save();

    await repoCreationCubit
        .waitUntil((state) => state.substate is RepoCreationSuccess);

    await repoCreationCubit.save();
    expect(repoCreationCubit.state.substate, isA<RepoCreationSuccess>());
    expect(
      reposCubit.repos
          .where((entry) => entry.name == suggestedRepoName)
          .firstOrNull,
      isA<OpenRepoEntry>()
          .having((e) => e.accessMode, 'mode', AccessMode.blind)
          .having((e) => e.cubit.accessMode, 'mode', AccessMode.blind),
    );
  });
}
