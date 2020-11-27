import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:isolate/ports.dart';

final DynamicLibrary nativeAddLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_add.so")
    : DynamicLibrary.process();

final int Function(int x, int y) nativeAdd =
nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();

final nRegisterPostCObject = nativeAddLib.lookupFunction<
    Void Function(
        Pointer<NativeFunction<Int8 Function(Int64, Pointer<Dart_CObject>)>>
        functionPointer),
    void Function(
        Pointer<NativeFunction<Int8 Function(Int64, Pointer<Dart_CObject>)>>
        functionPointer)>('RegisterDart_PostCObject');

final nRunTaskAsync = nativeAddLib
    .lookupFunction<Int32 Function(Int64, Int8), int Function(int, int)>('native_add');

class NativeCallbacks {
  static doSetup() {
    nRegisterPostCObject(NativeApi.postCObject);
  }

  static Future<int> runAsyncTask(int taskId) async {
    return singleResponseFuture((port) => nRunTaskAsync(port.nativePort, taskId));
  }
}