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
    // repo_dir is the repository identifier
    void initializeOuisyncRepository(const char* repo_dir);
    void createDir(const char* repo_dir, const char* c_new_directory);
    void getAttributes(const char* repo_dir, const char* c_path);
    void readDir(Dart_Port callbackPort, const char* repo_dir, const char* directory_to_read);
#ifdef __cplusplus
}
#endif

#endif //OUISYNC_APP_LOCALREPOSITORY_H
