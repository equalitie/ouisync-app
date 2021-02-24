//
// Created by Jorge Pabon on 12/20/20.
//

#include "localRepository.h"
#include "CallbackManager.h"
#include "string"
#include "vector"
#include "repository.h"
#include "network.h"
#include "shortcuts.h"
#include "options.h"
#include "path.h"

#include "androidlog.h"
#define  LOG_TAG "LOCAL_REPOSITORY"

#include <boost/asio.hpp>
#include <boost/filesystem.hpp>

#include <iostream>
#include <iterator>

using namespace std;
using namespace ouisync;

void readDir(Dart_Port callbackPort, const char* dir) {
    ALOG(LOG_TAG, "directory: %s at s%:%s:%d", dir, __FILE__,__FUNCTION__, __LINE__);

    net::io_context ioc;
    Options options;
    
    string basedir = dir;
    vector<const char*> args = { "./ouisync", "--basedir", basedir.c_str() };

    try {
        options.parse(args.size(), (char**) args.data());

        if (options.help) {
            options.write_help(cout);
            exit(0);
        }
    }
    catch (const std::exception& e) {
        ALOG(LOG_TAG, "Failed to parse options:\n%s at s%:%s:%d", e.what(), __FILE__,__FUNCTION__, __LINE__);
        
        if (options.help) {
            std::stringstream ss;
            options.write_help(ss);
            ALOG(LOG_TAG, ss.str().c_str(), __FILE__,__FUNCTION__, __LINE__);
            exit(0);
        }
    }

    fs::create_directories(options.branchdir);
    fs::create_directories(options.objectdir);
    fs::create_directories(options.remotes);
    fs::create_directories(options.snapshotdir);

    vector<string> files;

    try {
        Repository repo(ioc.get_executor(), options);
        Path path = fs::path(basedir);

        co_spawn(ioc, [&] () -> net::awaitable<void> {
            files = co_await repo.readdir(path_range(path));
            callbackToDartStrArray(callbackPort, files);
        }, net::detached);

        callbackToDartStrArray(callbackPort, files);   
    } catch (const exception& e) {
        ALOG(LOG_TAG, e.what(), __FILE__,__FUNCTION__, __LINE__);
        files.push_back(e.what());
        
        callbackToDartStrArray(callbackPort, files); 
    }
}