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

struct Repo {
    net::io_context _ioc;
    Repository _ouisync_repo;
    thread _thread;

    Repo(Options options) :
        _ouisync_repo(_ioc.get_executor(), options)
    {
        _thread = thread([=] {
            _ioc.run();
        });
    }
};

map<string, unique_ptr<Repo>> g_repos;

void initializeOuisyncRepository(const char* repo_dir)
{
    // TODO: Don't terminate the program on error, let the caller know
    // what happened.

    vector<const char*> args = { "./ouisync", "--basedir", repo_dir };

    Options options;

    try {
        options.parse(args.size(), (char**) args.data());

        if (options.help) {
            options.write_help(cout);
            exit(0);
        }
    }
    catch (const std::exception& e) {
        ALOG(LOG_TAG, "Failed to parse options:\n%s at %s:%s:%d", e.what(), __FILE__,__FUNCTION__, __LINE__);
        
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

    bool inserted = g_repos.insert({repo_dir, make_unique<Repo>(move(options))}).second;

    if (!inserted)
    {
        ALOG(LOG_TAG, "Failed to initialize the repo because repository %s has been already initialized", repo_dir);
        exit(0);
    }
}

void readDir(Dart_Port callbackPort, const char* repo_dir, const char* c_directory_to_read) {
    // TODO: Don't terminate the program on error, let the caller know
    // what happened.

    auto repo_i = g_repos.find(repo_dir);

    if (repo_i == g_repos.end()) {
        ALOG(LOG_TAG, "No such repo %s has been initialized", repo_dir);
        exit(0);
    }

    auto& repo = *repo_i->second;
    fs::path directory_to_read = c_directory_to_read;

    net::post(repo._ioc, [
        callbackPort,
        &repo,
        directory_to_read = move(directory_to_read)
    ] {
        co_spawn(repo._ioc, [
            callbackPort,
            &repo,
            directory_to_read = move(directory_to_read)
        ] () -> net::awaitable<void> {
            vector<string> files;
            try {
               files = co_await repo._ouisync_repo.readdir(path_range(directory_to_read));
               callbackToDartStrArray(callbackPort, files);
            } catch (const exception&) {
               // TODO: Convey to the caller that an error happened
               callbackToDartStrArray(callbackPort, files);
            }
        }, net::detached);
    });
}