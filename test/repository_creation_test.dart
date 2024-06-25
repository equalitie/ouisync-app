import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/navigation.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/models/repo_entry.dart';
import 'package:ouisync_app/app/pages/repository_creation_page.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

void main() {
  late Session session;
  late ReposCubit reposCubit;

  setUp(() async {
    final configPath = join(
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
    );

    await reposCubit.init();
  });

  tearDown(() async {
    await reposCubit.close();
    await session.close();
  });

  testWidgets('create repository', (tester) async {
    final navigatorObserver = TestNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: RepositoryCreation(reposCubit: reposCubit),
      localizationsDelegates: const [S.delegate],
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final nameField = find.byKey(ValueKey('name'));
    final useCacheServersField = find.descendant(
      of: find.byKey(ValueKey('use-cache-servers')),
      matching: find.byType(Switch),
    );

    await tester.enterText(nameField, 'my repo');
    await tester.tap(useCacheServersField);
    await tester.pumpAndSettle();

    // Verify that use cache servers is off:
    // TODO: Disable cache servers in tests
    expect(tester.widget<Switch>(useCacheServersField).value, isFalse);

    // Verify we are not in the root route.
    expect(navigatorObserver.cubit.state, equals(1));

    // NOTE: It seems we need to use `runAsync` because tapping the "create" button invokes an async
    // callback. Not sure this is the correct way to do it though...
    await tester.runAsync(() async {
      await tester.tap(find.text('CREATE'));
      // Wait until we return to the root route.
      await navigatorObserver.cubit.stream
          .where((stack) => stack == 0)
          .timeout(Duration(seconds: 10))
          .first;
    });

    final repoEntry =
        reposCubit.repos.where((entry) => entry.name == 'my repo').firstOrNull;

    expect(
      repoEntry,
      isA<OpenRepoEntry>().having(
        (e) => e.cubit.state.accessMode,
        'accessMode',
        equals(AccessMode.write),
      ),
    );
  });
}

/// Observes the current navigation route stack depth.
class TestNavigatorObserver extends NavigatorObserver {
  final cubit = TestNavigatorCubit();

  @override
  void didPop(Route route, Route? previousRoute) {
    cubit.pop();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    cubit.push();
  }
}

class TestNavigatorCubit extends Cubit<int> {
  TestNavigatorCubit() : super(0);

  void push() {
    emit(state + 1);
  }

  void pop() {
    emit(state - 1);
  }
}
