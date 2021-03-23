import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:isolate/ports.dart';
import 'package:ffi/ffi.dart';

final DynamicLibrary ouisyncLib = 
Platform.isAndroid
    ? DynamicLibrary.open("libnativeapp.so")
    : DynamicLibrary.executable();

final nRegisterPostCObject = 
  ouisyncLib.lookupFunction<
    Void Function(
      Pointer<NativeFunction<Int8 Function(
        Int64, 
        Pointer<Dart_CObject>
      )>>functionPointer
    ),
    void Function(
      Pointer<NativeFunction<Int8 Function(
        Int64, 
        Pointer<Dart_CObject>
      )>>functionPointer
    )
  >('RegisterDart_PostCObject');

final nInitializeOuisyncRepository = 
  ouisyncLib.lookupFunction<
    Void Function(
      Pointer<Utf8>
    ),
    void Function(
      Pointer<Utf8>
    )
  >('initializeOuisyncRepository');

final nReadDirAsync = 
  ouisyncLib.lookupFunction<
    Void Function(
      Int64, 
      Pointer<Utf8>,
      Pointer<Utf8>
    ),
    void Function(
      int, 
      Pointer<Utf8>,
      Pointer<Utf8>
    )
  >('readDir');

final nGetAttributesAsync =
    ouisyncLib.lookupFunction<
      Void Function(
        Pointer<Utf8>,
        Pointer<Utf8>
      ),
      void Function(
        Pointer<Utf8>,
        Pointer<Utf8>
      )
    >('getAttributes');

final nCreateDirAsync = 
  ouisyncLib.lookupFunction<
    Int32 Function(
      Int64,
      Pointer<Utf8>,
      Pointer<Utf8>
    ),
    int Function(
      int,
      Pointer<Utf8>,
      Pointer<Utf8>
    )
  >('createDir');

class NativeCallbacks {
  static doSetup() {
    nRegisterPostCObject(NativeApi.postCObject);
    print('Native callbacks setup done');
  }

  static void initializeOuisyncRepository(String repoDir) async {
    nInitializeOuisyncRepository.call(repoDir.toNativeUtf8());
  } 

  static Future<int> createDirAsync(String repoPath, String newFolderPath) {
    return singleResponseFuture((port) => nCreateDirAsync.call(port.nativePort, repoPath.toNativeUtf8(), newFolderPath.toNativeUtf8()));
  }

  static Future<dynamic> getAttributesAsync(String repoPath, String path) {
    return singleResponseFuture((port) => nGetAttributesAsync.call(repoPath.toNativeUtf8(), path.toNativeUtf8()));
  }

  static Future<List<dynamic>> readDirAsync(String repoPath, String folderPath) async {
    return singleResponseFuture((port) => nReadDirAsync(port.nativePort, repoPath.toNativeUtf8(), folderPath.toNativeUtf8()));
  }
}