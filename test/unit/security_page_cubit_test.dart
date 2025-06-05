import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo_security.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/access_mode.dart';
import 'package:ouisync/ouisync.dart';

void main() {
  setUp(() async {});

  tearDown(() async {});

  test('manualStored', () async {
    final cubit = RepoSecurityCubit(
      currentLocalSecretMode: LocalSecretMode.manualStored,
      currentAccess: WriteAccess(LocalSecretPassword(Password("my password"))),
    );

    expect(cubit.state.secretWillBeStored, true);
  });

  test('randomStored', () async {
    final cubit = RepoSecurityCubit(
      currentLocalSecretMode: LocalSecretMode.randomStored,
      currentAccess: WriteAccess(LocalSecretPassword(Password("my password"))),
    );

    expect(cubit.state.secretWillBeStored, true);

    cubit.setOrigin(SecretKeyOrigin.manual);

    expect(cubit.state.secretWillBeStored, true);
  });
}
