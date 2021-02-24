//
// Created by Jorge Pabon on 12/20/20.
//

#ifndef OUISYNC_APP_LOCALREPOSITORY_H
#define OUISYNC_APP_LOCALREPOSITORY_H

#include <CallbackManager.h>
#include <string>

#ifdef __cplusplus
extern "C" {
#endif
    void readDir(Dart_Port callbackPort, const char* dir);
#ifdef __cplusplus
}
#endif

#endif //OUISYNC_APP_LOCALREPOSITORY_H
