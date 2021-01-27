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

void readDir(Dart_Port callbackPort, string dir) {
    net::io_context ioc;

    Options options;

    ALOG(LOG_TAG, "dir=%s at %s:%s:%d", "directory", __FILE__,__FUNCTION__, __LINE__);

    string basedir = "/";
    vector<const char*> args = { "ouisync", "--basedir", basedir.c_str() };

    try {
        options.parse(args.size(), (char**) args.data());

        if (options.help) {
            options.write_help(cout);
            exit(0);
        }
    }
    catch (const std::exception& e) {
        cerr << "Failed to parse options:\n";
        cerr << e.what() << "\n\n";
        options.write_help(cerr);
        exit(1);
    }

    Repository repo(ioc.get_executor(), options);
    Path path = fs::path(dir);
    vector<string> files;

    ALOG(LOG_TAG, "path=%s at %s:%s:%d", "path", __FILE__,__FUNCTION__, __LINE__);

    co_spawn(ioc, [&] () -> net::awaitable<void> {
        files = co_await repo.readdir(path_range(path));

    if (!files.empty()){
        ostringstream vts;

        copy(files.begin(), files.end()-1, ostream_iterator<string>(vts, ", "));
        vts << files.back();

        string files_string = vts.str();
        ALOG(LOG_TAG, "files in %s at %s:%s:%d", "file contents", __FILE__,__FUNCTION__, __LINE__);
    }

    callbackToDartStrArray(callbackPort, files);
    }, net::detached);
}