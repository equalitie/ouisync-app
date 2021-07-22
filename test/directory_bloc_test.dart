import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ouisync_app/app/bloc/directory/directorybloc.dart';
import 'package:ouisync_app/app/bloc/directory/directoryevent.dart';
import 'package:ouisync_app/app/bloc/directory/directorystate.dart';
import 'package:ouisync_app/app/data/data.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'start_ouisync_test.mocks.dart';

class FakeFile extends Fake implements File {}
class FakeFileStream extends Fake implements Stream<List<int>> {}
void main() {
  group('DirectoryBloc', () {
    late Session session;

    late DirectoryRepository directoryRepository;
    late DirectoryBloc directoryBloc;

    late FolderItem dummyFolderItem;
    late FileItem dummyFileItem;

    late Stream<List<int>> stream;

    setUp(() {
      session = MockSession();

      directoryRepository = MockDirectoryRepository();
      directoryBloc = DirectoryBloc(blocRepository: directoryRepository);

      dummyFolderItem = FolderItem(
        name: 'test',
        path: '/test',
        creationDate: DateTime.now(),
        lastModificationDate: DateTime.now(),
        items: <BaseItem>[]
      );

      dummyFileItem = FileItem(
        name: 'testFile.txt',
        path: '/testFile.txt',
        extension: 'txt',
        creationDate: DateTime.now(),
        lastModificationDate: DateTime.now()
      );

      stream = FakeFileStream();
    });

    tearDown(() {
      directoryBloc.close();
    });

    group('CreateFolder', () {
        blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when CreateFolder is added and createFolder succeeds',
        build: () {
          when(directoryRepository.createFolder(session, '/test')).thenAnswer( 
            (_) => Future<BasicResult>.value(
              CreateFolderResult(
                functionName: 'createFolder',
                result: true
              )
            ));

          when(directoryRepository.getFolderContents(session, '/')).thenAnswer(
            (_) {
              var result = GetContentResult(
                functionName: 'getFolderContents',
                result: <BaseItem>[
                  dummyFolderItem
                ]
              );
              
              result.errorMessage = '';

              return Future.value(result);  
            });

          return directoryBloc;
        },
        act: (DirectoryBloc bloc) => bloc.add(CreateFolder(session: session, parentPath: '/', newFolderPath: '/test')),
        expect: () => [
          DirectoryLoadInProgress(),
          DirectoryLoadSuccess(contents: <BaseItem>[dummyFolderItem])
        ]);

        blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] with message when CreateFolder is added'
        'and createFolder fails',
        build: () {
          when(directoryRepository.createFolder(session, '//')).thenAnswer(
            (_) => Future<BasicResult>.value(
              CreateFolderResult(
                functionName: 'createFolder',
                result: false
              )
            ));

          when(directoryRepository.getFolderContents(session, '/')).thenAnswer(
            (_) {
              var result = GetContentResult(
                functionName: 'getFolderContents',
                result: <BaseItem>[]
              );
              
              result.errorMessage = 'Error, route folder';

              return Future.value(result);  
            });

          return directoryBloc;
        },
        act: (DirectoryBloc bloc) => bloc.add(CreateFolder(session: session, parentPath: '/', newFolderPath: '//')),
        expect: () => [
          DirectoryLoadInProgress(),
          DirectoryLoadFailure()
        ]);
    });

    group('RequestContent', () {
      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when RequestContent is added'
      'and getFolderContents succeeds', 
      build: () {
        when(directoryRepository.getFolderContents(session, '/')).thenAnswer(
          (_) => Future.value(
            GetContentResult(
              functionName: 'getFolderContents',
              result: <BaseItem>[]
            )
          ));

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(RequestContent(session: session, path: '/', recursive: false)),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(contents: <BaseItem>[])
      ]);

      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] with message when RequestFolder is added and getFolderContents fails',
      build: () {
        when(directoryRepository.getFolderContents(session, '')).thenAnswer(
          (_) {
            var result = GetContentResult(
              functionName: 'getFolderContents',
              result: <BaseItem>[]
            );
            
            result.errorMessage = 'Error, route folder';

            return Future.value(result);  
          });

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(RequestContent(session: session, path: '', recursive: false)),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);
    });

    group('DeleteFolder', () {
      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when DeleteFolder is added and deleteFolder succeeds', 
      build: () {
        when(directoryRepository.deleteFolder(session, '/testFolder')).thenAnswer(
          (_) => Future.value(
            DeleteFolderResult(
              functionName: 'deleteFolder', 
              result: 'OK'
            )
          ));

        when(directoryRepository.getFolderContents(session, '/')).thenAnswer(
          (_) => Future.value(
            GetContentResult(
              functionName: 'getFolderContents',
              result: <BaseItem>[]
            )
          ));

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(DeleteFolder(session: session, parentPath: '/', path: '/testFolder')),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(contents: <BaseItem>[])
      ]);

      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] when DeleteFolder is added and deleteFolder fails',
      build: () {
        when(directoryRepository.deleteFolder(session, '/testFolder')).thenAnswer(
          (_) {
            var result = DeleteFolderResult(
              functionName: 'deleteFolder',
              result: ''
            );

            result.errorMessage = 'Error, delete folder';

            return Future.value(result);
          });

          return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(DeleteFolder(session: session, parentPath: '/', path: '/testFolder')),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);
    });

    group('CreateFile', () {
      blocTest('emit [DirectoryLoadInProgress, DirectoryLoadSuccess] when CreateFile is added, createFile is called, '
       'if successful, then writeFile is called and getFolderContents success',
      build: () {
        when(directoryRepository.createFile(session, '/testFile.txt')).thenAnswer(
          (_) => Future.value(
            CreateFileResult(
              functionName: 'createFile',
              result: FakeFile()
            ) 
          ));
        
        when(directoryRepository.writeFile(session, '/testFile.txt', stream)).thenAnswer(
          (_) => Future.value(
            WriteFileResult(
              functionName: 'writeFile',
              result: FakeFile()
            )   
          ));

        when(directoryRepository.getFolderContents(session, '/')).thenAnswer(
          (_) => Future.value(
            GetContentResult(
              functionName: 'writeFile', 
              result: <BaseItem>[ dummyFileItem ]
            )
          ));

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        CreateFile(
          session: session,
          parentPath: '/',
          newFilePath: '/testFile.txt',
          fileByteStream: stream
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(contents: <BaseItem>[ dummyFileItem ])
      ]);

      blocTest('emit [DirectoryLoadInProgress, DirectoryLoadFailure] when CreateFile is added, createFile is called, '
       'and createrFile fails.',
      build: () {
        when(directoryRepository.createFile(session, '/testFile.txt')).thenAnswer(
          (_) { 
            var result = CreateFileResult(
              functionName: 'createFile',
              result: null
            );  

            result.errorMessage = 'Error, create file';

            return Future.value(result);
          });

          return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        CreateFile(
          session: session,
          parentPath: '/',
          newFilePath: '/testFile.txt',
          fileByteStream: stream
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);

      blocTest('emit [DirectoryLoadInProgress, DirectoryLoadFailure] when CreateFile is added, createFile is called and succeds, '
       'then writeFile is called and fails.',
      build: () {
        when(directoryRepository.createFile(session, '/testFile.txt')).thenAnswer(
          (_) => Future.value(
            CreateFileResult(
              functionName: 'createFile',
              result: FakeFile()
            ) 
          ));
        
        when(directoryRepository.writeFile(session, '/testFile.txt', stream)).thenAnswer(
          (_) {
            var result = WriteFileResult(
              functionName: 'writeFile',
              result: null
            );

            result.errorMessage = 'Error, write file';
          
            return Future.value(result);
          });

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        CreateFile(
          session: session,
          parentPath: '/',
          newFilePath: '/testFile.txt',
          fileByteStream: stream
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);

    });

    group('ReadFile', () {
      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when ReadFile is added, action is empty (read) '
      'and readFile succeds',
      build: () {
        when(directoryRepository.readFile(session, '/testFile.txt')).thenAnswer(
          (_) => Future.value(
            ReadFileResult(
              functionName: 'readFile', 
              result: <int>[1,2,3,4,5]
            )
          ));
          
        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        ReadFile(
          session: session,
          parentPath: '/',
          filePath: '/testFile.txt',
          action: ''
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(contents: <int>[1,2,3,4,5])
      ]);

      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] when ReadFile is added, action is empty (read) '
      'and readFile fails',
      build: () {
        when(directoryRepository.readFile(session, '/testFile.txt', action: '')).thenAnswer(
          (_) {
            var result = ReadFileResult(
              functionName: 'readFile', 
              result: <int>[]
            );

            result.errorMessage = 'Error, read file';

            return Future.value(result);
          });

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        ReadFile(
          session: session,
          parentPath: '/',
          filePath: '/testFile.txt',
          action: ''
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);
    });  

    group('DeleteFile', () {
      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadSuccess] when DeleteFile is added,'
      'deleteFile is called and if successful, then getContentFolder is called and succeeds ',
      build: () {
        when(directoryRepository.deleteFile(session, '/testFile.txt')).thenAnswer(
          (_) => Future.value(
            DeleteFileResult(
              functionName: 'deleteFile', 
              result: 'OK'
            )
          ));

        when(directoryRepository.getFolderContents(session, '/')).thenAnswer(
          (_) => Future.value(
            GetContentResult(
              functionName: 'getFolderContents', 
              result: <BaseItem>[]
            )
          ));

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        DeleteFile(
          session: session, 
          parentPath: '/', 
          filePath: '/testFile.txt'
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadSuccess(contents: <BaseItem>[])
      ]);

      blocTest('emits [DirectoryLoadInProgress, DirectoryLoadFailure] when DeleteFile is added,'
      'deleteFile is called and fails',
      build: () {
        when(directoryRepository.deleteFile(session, '/testFile.txt')).thenAnswer(
          (_) {
            var result = DeleteFileResult(
              functionName: 'deleteFile', 
              result: ''
            );

            result.errorMessage = 'Error, delete file';

            return Future.value(result);
          });

        return directoryBloc;
      },
      act: (DirectoryBloc bloc) => bloc.add(
        DeleteFile(
          session: session, 
          parentPath: '/', 
          filePath: '/testFile.txt'
        )),
      expect: () => [
        DirectoryLoadInProgress(),
        DirectoryLoadFailure()
      ]);
    });

  });
}
