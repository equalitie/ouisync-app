//
// Created by Jorge Pabon on 11/24/20.
//

#include "native_add.h"
#include <stdint.h>
#include <CallbackManager.h>

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t native_add(Dart_Port callbackPort, int32_t** values) {
    return *values[0] + *values[1];
}
