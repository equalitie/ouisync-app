import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/data/data.dart';
import 'package:ouisync_app/app/pages/pages.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/lifecycle.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'start_ouisync_test.mocks.dart';


@GenerateMocks([Session, DirectoryRepository, NavigationBloc, DirectoryBloc, RouteBloc, BasicResult])
void main() {
  late MockSession session;
  late MockDirectoryRepository directoryRepository;

  setUp(() async {
    session = MockSession();
    directoryRepository = MockDirectoryRepository();

    Bloc.observer = SimpleBlocObserver();

    registerFallbackValue(MockNavigationBloc());
    registerFallbackValue(MockDirectoryBloc());
    registerFallbackValue(MockRouteBloc());
  });
  

  testWidgets('load root folder contents on start', 
    (WidgetTester tester) async {
      await tester
      .pumpWidget(OuiSyncApp(
        session: session,
        foldersRepository: directoryRepository
      ));

      expect(find.byType(RootOuiSync), findsOneWidget);

      await tester.pumpAndSettle();
  });
}