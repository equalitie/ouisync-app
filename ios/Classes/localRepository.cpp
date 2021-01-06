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

#include <boost/asio.hpp>
#include <boost/filesystem.hpp>

#include <iostream>

using namespace std;
using namespace ouisync;

void readDir(Dart_Port callbackPort, string dir) {
    fs::path p = dir;
    for (auto f:p) {
        cout << f;
    }
    /*net::io_context ioc;

    Options options;

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

    co_spawn(ioc, [&] () -> net::awaitable<void> {
        vector<string> files = co_await repo.readdir(path_range(path));
        callbackToDartStrArray(callbackPort, files);
    }, net::detached);*/
}