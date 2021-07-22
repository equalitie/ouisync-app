import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/models/item/baseitem.dart';
import 'package:ouisync_app/app/models/item/folderitem.dart';


class MockNavigationBloc 
  extends MockBloc<NavigationEvent, NavigationState> 
  implements NavigationBloc {}

class NavigationStateFake extends Fake implements NavigationEvent {}

late FolderItem dummyFolderItem ;
void main() {
  setUpAll(() {
    registerFallbackValue(NavigationStateFake());

    dummyFolderItem = FolderItem(
      name: 'test',
      path: '/test',
      creationDate: DateTime.now(),
      lastModificationDate: DateTime.now(),
      items: <BaseItem>[]
    );
  });

  navigationBloc();
}

void navigationBloc() {
  group('NavigationBloc', () {
    blocTest<NavigationBloc, NavigationState>(
      'Emits a navigation event to /uno from /',
      build: () => NavigationBloc(rootPath: '/'),
      act: (bloc) => bloc.add(NavigateTo(Navigation.folder, '/', '/uno', dummyFolderItem)),
      expect: () => [NavigationLoadSuccess(navigation: Navigation.folder, parentPath: '/', destinationPath: '/uno', data: dummyFolderItem)],
    );
  });
}