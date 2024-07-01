import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/power_control.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/app/widgets/widgets.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../utils.dart';

void main() {
  late Session session;
  late Settings settings;
  late NativeChannels nativeChannels;
  late PowerControl powerControl;
  late StreamController<List<SharedMediaFile>> mediaReceiverController;

  setUp(() async {
    final configPath = join(
      (await getApplicationSupportDirectory()).path,
      'config',
    );

    session = Session.create(
      kind: SessionKind.unique,
      configPath: configPath,
    );

    settings = await Settings.init(MasterKey.random());
    nativeChannels = NativeChannels(session);
    powerControl = PowerControl(
      session,
      settings,
      connectivity: FakeConnectivity(),
    );

    mediaReceiverController = StreamController();
  });

  tearDown(() async {
    await mediaReceiverController.close();
    await powerControl.close();
    await session.close();
  });

  MainPage makeMainPage() => MainPage(
        cacheServers: CacheServers.disabled,
        nativeChannels: nativeChannels,
        packageInfo: fakePackageInfo,
        powerControl: powerControl,
        receivedMedia: mediaReceiverController.stream,
        session: session,
        settings: settings,
        windowManager: FakeWindowManager(),
      );

  testWidgets(
    'receive file when no repos',
    (tester) => tester.runAsync(
      () async {
        final content = 'Hello world';
        final file =
            io.File(join((await getTemporaryDirectory()).path, 'file.txt'));
        await file.create(recursive: true);
        await file.writeAsString(content);

        await tester.pumpWidget(testApp(makeMainPage()));
        await tester.pumpAndSettle();

        mediaReceiverController.add([
          SharedMediaFile(
            path: file.path,
            type: SharedMediaType.file,
          ),
        ]);

        await tester.pumpAndSettle();

        expect(find.text('Add file to Ouisync'), findsOne);

        // Verify the save button is disabled
        final saveButton = find.widgetWithText(PositiveButton, 'SAVE');
        expect(saveButton, findsOne);
        expect(tester.widget<PositiveButton>(saveButton).onPressed, isNull);

        // Cancel adding the file
        final cancelButton = find.widgetWithText(NegativeButton, 'CANCEL');
        expect(cancelButton, findsOne);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.text('Add file to Ouisync'), findsNothing);
      },
    ),
  );
}
