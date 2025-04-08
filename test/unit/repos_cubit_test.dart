import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/navigation.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/random.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

void main() {
  // Needed for `NativeChannels`.
  WidgetsFlutterBinding.ensureInitialized();

  late Session session;
  late ReposCubit reposCubit;

  setUp(() async {
    final appDir = await getApplicationSupportDirectory();
    await appDir.create(recursive: true);

    session = await Session.create(configPath: join(appDir.path, 'config'));
    await session.setStoreDir(join(appDir.path, 'store'));

    final settings = await Settings.init(MasterKey.random());

    reposCubit = ReposCubit(
      session: session,
      nativeChannels: NativeChannels(),
      settings: settings,
      navigation: NavigationCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers(session),
    );
  });

  tearDown(() async {
    await reposCubit.close();
    await session.close();
  });

  test('current repo', () async {
    expect(reposCubit.state.current, isNull);

    final location =
        RepoLocation(dir: (await session.getStoreDir())!, name: 'foo');
    final entry = await reposCubit.createRepository(
      location: location,
      setLocalSecret: SetLocalSecretKeyAndSalt(
        key: randomSecretKey(),
        salt: randomSalt(),
      ),
      localSecretMode: LocalSecretMode.randomStored,
    );

    expect(reposCubit.state.current, isNull);

    await reposCubit.setCurrent(entry);

    expect(reposCubit.state.current, equals(entry));

    await reposCubit.deleteRepository(location);

    expect(reposCubit.state.current, isNull);
  });
}
