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
#include <boost/format.hpp>

#include <iostream>
#include <iterator>
#include <cstdarg>

using namespace std;
using namespace ouisync;

struct Repo {
    net::io_context _ioc;
    net::executor_work_guard<net::io_context::executor_type> _work_guard;
    Repository _ouisync_repo;
    thread _thread;

    Repo(Options options) :
        _work_guard(_ioc.get_executor()),
        _ouisync_repo(_ioc.get_executor(), options)
    {
        _thread = thread([=] { _ioc.run(); });
        _thread.detach();
    }

    template<class F>
    void post(F&& f) {
        net::post(
            _ioc, [&, f = move(f)] {
                co_spawn(_ioc, move(f), net::detached);
            }
        );
    }
};

map<string, unique_ptr<Repo>> g_repos;

void initializeOuisyncRepository(const char* repo_dir)
{
    ALOG(LOG_TAG, "Initializing OuiSync repository...\nRepository path: %s", repo_dir);

    vector<const char*> args = { "./ouisync", "--basedir", repo_dir };

    Options options;

    try {
        options.parse(args.size(), (char**) args.data());

        if (options.help) {
            options.write_help(cout);

            ALOG(LOG_TAG, "options help at %s:%s:%d", __FILE__,__FUNCTION__, __LINE__);
            return;
        }
    }
    catch (const std::exception& e) {
        ALOG(LOG_TAG, "Failed to parse options:\n%s at %s:%s:%d", e.what(), __FILE__,__FUNCTION__, __LINE__);
        
        if (options.help) {
            std::stringstream ss;
            options.write_help(ss);
            
            ALOG(LOG_TAG, ss.str().c_str(), "");
            return;
        }
    }

    auto [i, inserted] = g_repos.insert({repo_dir, nullptr});
    
    if (!inserted)
    {
        ALOG(LOG_TAG, "Failed to initialize the repo because repository %s has been already initialized\n", repo_dir);
        return;
    }

    i->second = make_unique<Repo>(move(options));
    
    ALOG(LOG_TAG, "__ok__ OuiSync repository initialized at %s", repo_dir);
}

void createDir(const char* repo_dir, const char* c_new_directory)
{
    ALOG(LOG_TAG, "Creating directory %s in repo %s", c_new_directory, repo_dir);

    auto repo_i = g_repos.find(repo_dir);
    if (repo_i == g_repos.end()) {
        string return_no_such_repo = str(boost::format("No such repo %s has been initialized") % repo_dir);

        ALOG(LOG_TAG, return_no_such_repo.c_str(), "");

        return;    
    }

    auto& repo = *repo_i->second;
    fs::path new_directory = c_new_directory;

    repo.post([
        &repo,
        new_directory = new_directory
    ] () -> net::awaitable<void> {
        try {
            mode_t mode = 0777;
            co_await repo._ouisync_repo.mkdir(path_range(new_directory), mode);       

            ALOG(LOG_TAG, "Directory created correctly");
        } catch (const exception& e) {
            ALOG(LOG_TAG, "Exception creating the directory:\n%s", e.what());
        }
    });
}

void getAttributes(const char* repo_dir, const char* c_path)
{
    ALOG(LOG_TAG, "Getting attributes for %s in repo %s", c_path, repo_dir);

    auto repo_i = g_repos.find(repo_dir);
    if (repo_i == g_repos.end()) {
        string return_no_such_repo = str(boost::format("No such repo %s has been initialized") % repo_dir);

        ALOG(LOG_TAG, return_no_such_repo.c_str(), "");

        return;    
    }

    auto& repo = *repo_i->second;

    repo.post([
        &repo,
        path = fs::path(c_path)
    ] () -> net::awaitable<void> {
        FileSystemAttrib attributes;
        try {
            attributes = co_await repo._ouisync_repo.get_attr(path_range(path));
        } catch (const exception& e) {
            string return_exception_getatt = str(
                boost::format(
                    "There was an exception getting the attributes from %s: %s\nat %s:%s:%d"
                ) % path % e.what() % __FILE__ % __FUNCTION__ % __LINE__
            );

            ALOG(LOG_TAG, return_exception_getatt.c_str(), "");
        }
    });
}

void readDir(Dart_Port callbackPort, const char* repo_dir, const char* c_directory_to_read) 
{
    ALOG(LOG_TAG, "Reading directory %s in repo %s", c_directory_to_read, repo_dir);

    auto repo_i = g_repos.find(repo_dir);

    if (repo_i == g_repos.end()) {
        string return_no_such_repo = str(boost::format("No such repo %s has been initialized") % repo_dir);

        ALOG(LOG_TAG, return_no_such_repo.c_str(), "");
        callbackToDartStr(callbackPort, return_no_such_repo);

        return;
    }

    auto& repo = *repo_i->second;

    repo.post([
        callbackPort,
        &repo,
        directory_to_read = fs::path(c_directory_to_read)
    ] () -> net::awaitable<void> {
        vector<string> files;
        try {
            files = co_await repo._ouisync_repo.readdir(path_range(directory_to_read));
            callbackToDartStrArray(callbackPort, files);
        } catch (const exception& e) {
            string return_exception_reddir = str(
                boost::format(
                    "There was an exception while reading the directory %s contents: %s at %s:%s:%d"
                ) % directory_to_read % e.what() % __FILE__ % __FUNCTION__ % __LINE__
            );

            ALOG(LOG_TAG, return_exception_reddir.c_str(), "");

            files.push_back("__error__");
            files.push_back(return_exception_reddir);
            callbackToDartStrArray(callbackPort, files);
        }
    });
}
