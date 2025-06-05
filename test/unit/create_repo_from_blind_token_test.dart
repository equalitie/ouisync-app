import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/ouisync.dart' show SetLocalSecretKeyAndSalt;
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/utils/share_token.dart';

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDependencies deps;
  late RepoCreationCubit repoCreationCubit;

  final String tokenString =
      'https://ouisync.net/r#AwAgTmm8jPQuimEWzqVcM17M2-3GXIULZQ1tbQRVsBgj9PY?name=uno';

  setUp(() async {
    deps = await TestDependencies.create();
    repoCreationCubit = RepoCreationCubit(reposCubit: deps.reposCubit);
  });

  tearDown(() async {
    await repoCreationCubit.close();
    await deps.dispose();
  });

  test('create repository with blind token', () async {
    final token = await parseShareToken(deps.reposCubit, tokenString);
    expect(
        token,
        isA<ShareTokenValid>()
            .having((t) => t.value, 'value', isNotNull)
            .having((t) => t.error, 'error', isNull));

    final tokenAccessMode = await deps.session
        .getShareTokenAccessMode((token as ShareTokenValid).value);
    expect(tokenAccessMode, equals(AccessMode.blind));

    final suggestedRepoName =
        await deps.session.getShareTokenSuggestedName(token.value);

    expect(
      repoCreationCubit.state.substate,
      isA<RepoCreationPending>()
          .having((s) => s.location, 'location', isNull)
          .having((s) => s.setLocalSecret, 'setLocalSecret',
              isA<SetLocalSecretKeyAndSalt>())
          .having((s) => s.nameError, 'nameError', isNull),
    );

    await repoCreationCubit.setToken(token.value);

    repoCreationCubit.nameController.text = suggestedRepoName;
    await repoCreationCubit
        .waitUntil((state) => state.substate is RepoCreationValid);

    expect(repoCreationCubit.state.substate, isA<RepoCreationValid>());
    expect(repoCreationCubit.state.name, equals(suggestedRepoName));

    await repoCreationCubit.save();

    expect(repoCreationCubit.state.substate, isA<RepoCreationSuccess>());
    expect(
      deps.reposCubit.state.repos.values
          .where((entry) => entry.name == suggestedRepoName)
          .firstOrNull,
      isA<OpenRepoEntry>()
          .having((e) => e.accessMode, 'accessMode', AccessMode.blind)
          .having(
            (e) => e.cubit.state.authMode,
            'cubit.state.authMode',
            isA<AuthModeBlindOrManual>(),
          ),
    );
  });
}
