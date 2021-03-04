//
// Created by Jorge Pabon on 11/26/20.
//

#include "CallbackManager.h"
#include <stdlib.h>
#include <string>
#include <vector>

using namespace std;

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

void callbackToDartStr(Dart_Port callbackPort, const string& value) {
    Dart_CObject dart_object;

    dart_object.type = Dart_CObject_kString;
    const string& from = value;
    char* to = new char[from.size() + 1];
    memcpy(to, from.data(), from.size() + 1);
    dart_object.value.as_string = to;

    bool result = dartPostCObject(callbackPort, &dart_object);
    if (!result) {
        printf("call from native to Dart failed, result was: %d\n", result);
    }
}

void callbackToDartStrArray(Dart_Port callbackPort, const vector<string>& strings) {
    Dart_CObject **valueObjects = new Dart_CObject *[strings.size()];
    for (size_t i = 0; i < strings.size(); i++) {
        Dart_CObject *valueObject = new Dart_CObject;
        valueObject->type = Dart_CObject_kString;
        const string& from = strings[i];
        char* to = new char[from.size() + 1]; // +1 for \0
        memcpy(to, from.data(), from.size() + 1);
        valueObject->value.as_string = to;
        valueObjects[i] = valueObject;
    }

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kArray;
    dart_object.value.as_array.length = strings.size();
    dart_object.value.as_array.values = valueObjects;

    bool result = dartPostCObject(callbackPort, &dart_object);
    if (!result) {
        printf("call from native to Dart failed, result was: %d\n", result);
    }
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