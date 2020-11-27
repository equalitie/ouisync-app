//
// Created by Jorge Pabon on 11/26/20.
//

#include "CallBackManager.h"
#include <stdlib.h>

Dart_PostCObjectType dartPostCObject = NULL;

void RegisterDart_PostCObject(Dart_PostCObjectType _dartPostCObject) {
    dartPostCObject = _dartPostCObject;
}

void callbackToDartInt32(Dart_Port callbackPort, int32_t value) {
    Dart_CObject dart_object;

    dart_object.type = Dart_CObject_kInt32;
    dart_object.value.as_int32 = value;

    bool result = dartPostCObject(callbackPort, &dart_object);
    if (!result) {
        printf("call from native to Dart failed, result was: %d\n", result);
    }
}

void callbackToDartStrArray(Dart_Port callbackPort, int length, char** values) {
    Dart_CObject **valueObjects = new Dart_CObject *[length];
    int i;
    for (i = 0; i < length; i++) {
        Dart_CObject *valueObject = new Dart_CObject;
        valueObject->type = Dart_CObject_kString;
        valueObject->value.as_string = values[i];

        valueObjects[i] = valueObject;
    }

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kArray;
    dart_object.value.as_array.length = length;
    dart_object.value.as_array.values = valueObjects;

    bool result = dartPostCObject(callbackPort, &dart_object);
    if (!result) {
        printf("call from native to Dart failed, result was: %d\n", result);
    }

    for (i = 0; i < length; i++) {
        delete valueObjects[i];
    }
    delete[] valueObjects;
}

void callbackToDartInt32Array(Dart_Port callbackPort, int length, int** values) {
     Dart_CObject **valueObjects = new Dart_CObject *[length];
     int i;
     for (i = 0; i < length; i++) {
         Dart_CObject *valueObject = new Dart_CObject;
         valueObject->type = Dart_CObject_kInt32;
         valueObject->value.as_int32 = *values[i];

         valueObjects[i] = valueObject;
     }

     Dart_CObject dart_object;
     dart_object.type = Dart_CObject_kArray;
     dart_object.value.as_array.length = length;
     dart_object.value.as_array.values = valueObjects;

     bool result = dartPostCObject(callbackPort, &dart_object);
     if (!result) {
         printf("call from native to Dart failed, result was: %d\n", result);
     }

     for (i = 0; i < length; i++) {
         delete valueObjects[i];
     }
     delete[] valueObjects;
 }