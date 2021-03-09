#pragma once

#include <unistd.h> // dup2
#include <android/log.h>
#include <thread>

#define debug(...) __android_log_print(ANDROID_LOG_VERBOSE, "OuiSyncStdIo", __VA_ARGS__);

class StdScopedRedirect {
public:
    StdScopedRedirect();

    ~StdScopedRedirect();

private:
    // [0] for reading; [1] for writing
    int _cout_pipe [2] = {0, 0};
    int _cerr_pipe [2] = {0, 0};
    int _close_pipe[2] = {0, 0};

    std::thread _thread;
};

inline
StdScopedRedirect::StdScopedRedirect()
{
    if (pipe(_close_pipe) == -1) {
        debug("Failed to set up closing pipe");
        _close_pipe[0] = 0;
        _close_pipe[1] = 0;
        return;
    }

    if (pipe(_cout_pipe) == -1) {
        debug("Failed to set up stdout redirect pipes");
        _cout_pipe[0] = 0;
        _cout_pipe[1] = 0;
    }
    else {
        ::dup2(_cout_pipe[1], 1 /* stdout */); // redirect stdout
    }

    if (pipe(_cerr_pipe) == -1) {
        debug("Failed to set up stderr redirect pipes");
        _cerr_pipe[0] = 0;
        _cerr_pipe[1] = 0;
    }
    else {
        ::dup2(_cerr_pipe[1], 2 /* stderr */); // redirect stderr
    }

    if (!_cout_pipe[0] && !_cerr_pipe[0]) return;

    _thread = std::thread([=] {
        std::string line[2];

        fd_set fds;

        int pipe[3] = { _cout_pipe[0], _cerr_pipe[0], _close_pipe[0] };

        while (pipe[0] || pipe[1]) {
            FD_ZERO(&fds);

            for (size_t i = 0; i < 3; ++i) {
                if (pipe[i]) { FD_SET(pipe[i], &fds); }
            }

            int nfds = std::max({pipe[0], pipe[1], pipe[2]}) + 1;

            errno = 0;
            int r = select(nfds, &fds, NULL, NULL, NULL);

            if (r == -1) {
                debug("Error in select %s", strerror(errno));
                return;
            } else if (r == 0) {
                debug("Select timeout");
                continue;
            } else if (FD_ISSET(pipe[2], &fds)) {
                // Destructor was called and is waiting for this sthread to
                // finish.
                return;
            }

            for (size_t i = 0; i < 2; ++i) {
                if (!FD_ISSET(pipe[i], &fds)) continue;

                char read_buf[512];

                int size = read(pipe[i], read_buf, sizeof(read_buf));

                if (size <= 0) {
                    // TODO: Print error if size == -1.
                    pipe[i] = 0;
                    continue;
                }

                for (size_t j = 0; j < size; ++j) {
                    char c = read_buf[j];

                    if (read_buf[j] == '\n') {
                        debug("%s", line[i].c_str());
                        line[i].clear();
                    }
                    else {
                        line[i].push_back(c);
                    }
                }
            }
        }
    });
}

inline
StdScopedRedirect::~StdScopedRedirect()
{
    if (_close_pipe[1]) {
        // Break from select
        char c = 0;
        write(_close_pipe[1], &c, 1);
    }

    if (_thread.get_id() != std::thread::id()) {
        _thread.join();
    }

    if (_cout_pipe[0])  close(_cout_pipe[0]);
    if (_cout_pipe[1])  close(_cout_pipe[1]);
    if (_cerr_pipe[0])  close(_cerr_pipe[0]);
    if (_cerr_pipe[1])  close(_cerr_pipe[1]);
    if (_close_pipe[0]) close(_close_pipe[0]);
    if (_close_pipe[1]) close(_close_pipe[1]);
}

