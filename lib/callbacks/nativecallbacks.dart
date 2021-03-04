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
      Int64,
      Pointer<Utf8>
    ),
    void Function(
      int,
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

class NativeCallbacks {
  static doSetup() {
    nRegisterPostCObject(NativeApi.postCObject);
    print('Native callbacks setup done');
  }

  static Future<dynamic> initializeOuisyncRepository(String repoDir) async {
    return singleResponseFuture((port) => nInitializeOuisyncRepository(port.nativePort, Utf8.toUtf8(repoDir)));
  } 

  static Future<List<dynamic>> readDirAsync(String repoPath, String folderPath) async {
    return singleResponseFuture((port) => nReadDirAsync(port.nativePort, Utf8.toUtf8(repoPath), Utf8.toUtf8(folderPath)));
  }
}