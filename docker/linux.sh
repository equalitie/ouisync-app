#!/bin/bash

set -euo pipefail

source $(dirname $0)/utils.sh

# Host to run on. If omitted, runs on the local machine.
host=

# If set, opens a shell session in the container before existing.
shell=

# How to put the source files into the container:
#
# Either checkout the given commit with git...
commit=
# ... or rsync from the given host directory.
srcdir=
# Whether to also include the .git directory when copying the source directory into the container.
# Including it is currently necessary when running the `build` command only.
rsync_include_git=

base_name="ouisync-runner-linux"
default_image_name="$base_name:$USER"
image_name=$default_image_name

default_container_name="$base_name.$USER"
container_name=$default_container_name

# Is cache enabled (see `$cache_paths` to see what's cached)?
cache=

# Name of the docker volume to put the cache on
cache_volume="$base_name-cache"

# List of paths to cache
cache_paths=(
    # Cargo global
    /root/.cargo/bin
    /root/.cargo/registry/index
    /root/.cargo/registry/cache
    /root/.cargo/git/db

    # Cargo per project
    /opt/ouisync-app/ouisync/target

    # Dart / flutter
    /root/.pub-cache
    /opt/ouisync-app/.dart_tool

    # Android system images
    /opt/android-sdk/system-images

    # Android AVDs
    /root/.android

    # Gradle
    /root/.gradle/caches
    /root/.gradle/wrapper
)

emulator_sdcard=32M

function print_help() {
    local command="${1:-}"

    case $command in
        "build")
            echo "Build release"
            echo
            echo "Usage: $0 build [OPTIONS]"
            echo
            echo "Options:"
            echo "    --out <PATH> Directory where artifacts will be stored"
            ;;
        "unit-test")
            echo "Run unit tests"
            echo
            echo "Usage: $0 unit-test [ARGS...]"
            echo
            echo Arguments:
            echo     ARGS   Additional arguments for 'flutter test'
            ;;
        "integration-test")
            echo "Run integration tests"
            echo
            echo "Usage: $0 integration-test [OPTIONS]"
            echo
            echo "Options:"
            echo "    --platform <linux|android>    Platform for which to run the tests"
            echo "    --api <API>                   Android API level to run in"
            ;;
        "analyze")
            echo "Analyze the dart source code"
            echo
            echo "Usage: $0 analyze"
            ;;
        "container")
            echo "Explicitly manage the container"
            echo
            echo "Note the commands normally build, start and stop the container automatically. This is only useful when running multiple commands on the same container."
            echo
            echo "Usage: $0 container <start|stop|build>"
            echo
            echo "Commands:"
            echo "    start Start the container"
            echo "    stop  Stop the container"
            echo "    build Build the container image"
            ;;
        "shell")
            echo "Run a shell session in the container"
            echo
            echo "Usage: $0 shell"
            ;;
        *)
            echo "Script for building and testing Ouisync App in a Docker container"
            echo
            echo "Usage: $0 [OPTIONS] <COMMAND>"
            echo
            echo "Options:"
            echo "    -h, --help            Print help"
            echo "    --host <HOST>         IP or entry in ~/.ssh/config of machine running Docker. If omitted, runs locally"
            echo "    --commit <COMMIT>     Commit from which to build"
            echo "    --srcdir <PATH>       Source dir from which to build"
            echo "    --container <NAME>    Assign a name to the docker container [default: $default_container_name]"
            echo "    --image <NAME>[:TAG]  Name (and optional tag) of the docker image to use [default: $default_image_name]"
            echo "    --cache               Cache some dependencies and intermediate build artifacts on a persistent docker volume"
            echo "    -s, --shell           Open a shell session in the container after the command finishes"
            echo
            echo "Commands:"
            echo "    help              Print help"
            echo "    build             Build release"
            echo "    unit-test         Run unit tests"
            echo "    integration-test  Run integration tests"
            echo "    analyze           Analyze the dart source code"
            echo "    container         Explicitly manage the container"
            echo
            echo "See '$0 help <command> for more information on a specific command"
            ;;
    esac
}

function build_image() {
    log_group_begin "Build image $image_name"

    ndk_version=$(cat ndk-version.txt)
    dock build -t $image_name --build-arg NDK_VERSION=$ndk_version - < docker/Dockerfile.linux

    log_group_end
}

function create_cache_volume() {
    log_group_begin "Create cache volume $cache_volume"

    dock volume create $cache_volume > /dev/null
    dock run --rm --mount src=$cache_volume,dst=/mnt/cache --workdir /mnt/cache $image_name \
        mkdir -p "${cache_paths[@]#/}"

    log_group_end
}

function start_container() {
    if [ -z "$commit" -a -z "$srcdir" ]; then error "Missing one of --commit or --srcdir"; fi
    if [ -n "$commit" -a -n "$srcdir" ]; then error "--commit and --src are mutually exclusive"; fi

    build_image

    if [ "$cache" = 1 ]; then
        create_cache_volume
    fi

    log_group_begin "Start container $container_name"

    local opts="-d --rm"

    # Sync localtime with host
    opts="$opts --mount type=bind,src=/etc/timezone,dst=/etc/timezone,ro"
    opts="$opts --mount type=bind,src=/etc/localtime,dst=/etc/localtime:ro"

    # Mount cache volume (if enabled)
    if [ "$cache" = 1 ]; then
        opts="$opts --mount src=$cache_volume,dst=/mnt/cache"

        for path in ${cache_paths[@]}; do
            opts="$opts --mount src=$cache_volume,dst=$path,volume-subpath=${path#/}"
        done
    fi

    # Needed for android emulator
    opts="$opts --device /dev/kvm"

    # Needed to run mount tests
    # TODO: The 'apparmor:unconfined' feels sketchy. Ideally we would use a more
    # fine-grained policy - one which enables fuse but keeps other restrictions in place.
    opts="$opts --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined"

    if [ -n "${container_name-}" ]; then
        opts="$opts --name $container_name"
    fi

    # Note: can't use the `dock` function here (that is, `docker --host ...`) because it doesn't
    # seem to play well with the `--device /dev/kvm` option. Running docker through ssh instead
    # which seems to work.
    if [ -n "$host" ]; then
        local args=()
        for arg; do
            args+=("'$arg'")
        done

        ssh $host docker run $opts $image_name ${args[@]}
    else
        docker run $opts $image_name "$@"
    fi

    log_group_end


    log_group_begin "Fetch app source"
    if [ -n "$commit" ]; then
        get_sources_from_git $commit /opt
    else
        get_sources_from_local_dir $srcdir /opt
    fi
    log_group_end

    # Generate bindings (TODO: This should be done automatically)
    log_group_begin "Generate bindings"
    exe -w /opt/ouisync-app/ouisync/bindings/dart -t dart pub get
    exe -w /opt/ouisync-app/ouisync/bindings/dart -t dart tool/bindgen.dart
    log_group_end

    log_group_begin "Update dart dependencies"
    exe -w /opt/ouisync-app -t dart pub get
    log_group_end

    if [ "$cache" = 1 ]; then
        # Run cargo sweep to delete all cargo artifacts older than 30 days (prevents unbounded cache grow)
        log_group_begin "Prune cached cargo artifacts"
        exe -w /opt/ouisync-app/ouisync -t cargo sweep --recursive --time 30
        log_group_end
    fi
}

function stop_container() {
    echo "Stop container $container_name"
    dock container stop $container_name
}

function auto_start_container() {
    # Prevent the container from stopping
    while true; do
        exe touch /tmp/alive 2> /dev/null || true
        sleep 5
    done &

    local keep_alive_pid=$!

    # Stop the container on exit
    trap "auto_stop_container $keep_alive_pid" EXIT

    # Run the container for as long as this script is running
    start_container sh -c 'sleep 60; while [ -n "$(find /tmp/alive -cmin -1)" ]; do sleep 10; done'
}

function auto_stop_container() {
    local keep_alive_pid=$1

    if [ "$shell" = 1 ]; then
        echo "Enter container $container_name"
        dock exec -it $container_name bash
    fi

    kill $keep_alive_pid

    stop_container
}

function is_container_running() {
    local result=$(dock container inspect -f '{{.State.Status}}' $container_name 2> /dev/null)

    if [ "$result" == "running" ]; then
        return 0
    else
        return 1
    fi
}

function manage_container() {
    case $1 in
        start)
            start_container tail -f /dev/null
            ;;
        stop)
            stop_container
            ;;
        build)
            build_image
            ;;
    esac
}

function init() {
    # Auto-start the container unless already running
    is_container_running || auto_start_container
}

####################################################################################################
# Build the release artifacts for linux and android
function build() {
    rsync_include_git=1

    local dst_dir="./releases/$container_name"
    local flavor=

    while [ $# -gt 0 ]; do
        case $1 in
            "--out")
                dst_dir="$1"
                shift
                ;;
            *)
                error "Unknown argument: $1"
                ;;
        esac
    done

    if [ -n "$commit" ]; then
        flavor=production
    elif [ -n "$srcdir" ]; then
        flavor=unofficial
    fi

    local secretSentryDsn=
    local secretStorePassword=
    local secretKeyAlias=
    local secretKeyPassword=
    local secretKeystoreHex=

    # Collect secrets
    if [ "$flavor" != unofficial ]; then
        secretSentryDsn=$(pass cenoers/ouisync/app/$flavor/sentry_dsn)
        secretStorePassword=$(pass cenoers/ouisync/app/$flavor/android/storePassword)
        secretKeyAlias=$(pass cenoers/ouisync/app/$flavor/android/keyAlias)
        secretKeyPassword=$(pass cenoers/ouisync/app/$flavor/android/keyPassword)
        secretKeystoreHex=$(pass cenoers/ouisync/app/$flavor/android/keystore.jks | xxd -p)
    fi

    init

    local opts=

    # Set up secrets inside the container
    if [ "$flavor" != unofficial ]; then
        function exe_i() { dock exec -i $container_name "$@"; }
        exe mkdir -p /opt/secrets
        echo "$secretKeystoreHex" | xxd -p -r      | exe_i dd of=/opt/secrets/keystore.jks
        echo "storePassword=$secretStorePassword"  | exe_i dd of=/opt/secrets/key.properties
        echo "keyPassword=$secretKeyPassword"      | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
        echo "keyAlias=$secretKeyAlias"            | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
        echo "storeFile=/opt/secrets/keystore.jks" | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
        echo "$secretSentryDsn"                    | exe_i dd of=/opt/secrets/sentry_dsn

        opts="$opts --android-key-properties=/opt/secrets/key.properties"
        opts="$opts --sentry=/opt/secrets/sentry_dsn"
    fi

    # Build Ouisync app
    exe -w /opt/ouisync-app dart run util/release.dart \
        --flavor=$flavor --apk --aab --deb-gui --deb-cli $opts

    # Collect artifacts
    mkdir -p $dst_dir
    src_dir=/opt/ouisync-app/releases/latest
    for artifact in $(exe -w $src_dir ls); do
        dock cp $container_name:$src_dir/$artifact $dst_dir/
    done
}

####################################################################################################
# Run unit tests
function unit_test() {
    init

    log_group_begin "Build the Ouisync library for tests"
    exe -w /opt/ouisync-app/ouisync -t cargo build --package ouisync-service --lib
    log_group_end

    log_group_begin "Run tests"
    exe -w /opt/ouisync-app -t -e OUISYNC_LIB=ouisync/target/debug/libouisync_service.so flutter test "$@"
    log_group_end
}

####################################################################################################

# Wait for the emulator to boot
function emulator_wait_boot() {
    while true; do
        local result=$(exe adb shell getprop sys.boot_completed)

        if [ "$result" = "1" ]; then
            break
        else
            echo "Waiting for the emulator to boot"
            sleep 1
        fi
    done
}

function emulator_start() {
    local api=

    while true; do
        case ${1-} in
            --api)
                api=${2-}
                shift
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    if [ -z "$api" ]; then
        error "Missing --api"
    fi

    local target=google_apis
    if [ "$api" = "27" ]; then
        target=default
    fi

    local avd=android-$api
    local system_image="system-images;android-$api;$target;x86_64"

    #-----------------------------

    if ! exe avdmanager list avd | grep "Name:\s\+$avd" > /dev/null; then
        log_group_begin "Create AVD"
        exe sdkmanager --install "$system_image"
        echo "no" | exe -i avdmanager create avd \
            --force \
            --name $avd \
            --package "$system_image" \
            --sdcard $emulator_sdcard \
            > /dev/null
        log_group_end
    fi

    #-----------------------------

    log_group_begin "Launch emulator"

    # Launch the emulator in separate process. Prefix its output with '🤖' to distinguish it from
    # other output
    exe emulator -no-metrics -no-window -no-audio -no-boot-anim -avd $avd | sed 's/^/🤖 /' &

    emulator_wait_boot

    log_group_end

    log_group_begin "Format sdcard"
    echo "yes" | exe -w /opt/ouisync-app -i ./util/adb-format-sdcard.sh
    log_group_end
}

function emulator_stop() {
    log_group_begin "Stop emulator"
    exe adb emu kill > /dev/null
    log_group_end
}

function integration_test_android() {
    init

    local api=

    while true; do
        case ${1-} in
            --api)
                api="${2-}"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    if [ -z "$api" ]; then
        error "Missing --api"
    fi


    emulator_start --api $api

    log_group_begin "Run tests"
    exe -w /opt/ouisync-app -t flutter test integration_test --flavor itest --ignore-timeouts $@
    log_group_end

    emulator_stop
}

function integration_test_linux() {
    init
    exe -w /opt/ouisync-app -t flutter test -d linux integration_test $@
}

# Run integration tests
function integration_test() {
    local platform=

    while true; do
        case ${1-} in
            --platform)
                platform=${2-}
                shift
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    case $platform in
        linux)
            integration_test_linux $@
            ;;
        android)
            integration_test_android $@
            ;;
        "")
            error "Missing --platform"
            ;;
        *)
            error "Unknown platform: $platform"
            ;;
    esac
}

####################################################################################################
# Analyze the dart source code
function analyze() {
    init

    exe -w /opt/ouisync-app/lib  -t flutter analyze
    exe -w /opt/ouisync-app/test -t flutter analyze
    exe -w /opt/ouisync-app/util -t flutter analyze
}

####################################################################################################
# Clean cache
function clean_cache() {
    dock volume rm $cache_volume
}

####################################################################################################

# Handle common options
while true; do
    case "${1-}" in
        -h|--help)
            print_help
            exit
            ;;
        --host)
            host="$2";
            shift
            ;;
        --commit)
            commit="$2";
            shift
            ;;
        --srcdir|--src)
            srcdir="$2";
            shift
            ;;
        --image|--image-name)
            image_name="$2"
            shift
            ;;
        --container|--container-name)
            container_name="$2"
            shift
            ;;
        --cache)
            cache=1
            ;;
        -s|--shell)
            shell=1
            ;;
        -*)
            error "Unknown option: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Handle command
case "${1-}" in
    help|h)
        print_help ${@:2}
        exit
        ;;
    build|b)
        build ${@:2}
        ;;
    unit-test|unit-tests|ut)
        unit_test ${@:2}
        ;;
    integration-test|integration-tests|it)
        integration_test ${@:2}
        ;;
    analyze)
        analyze ${@:2}
        ;;
    container)
        manage_container ${@:2}
        ;;
    shell|sh)
        init
        shell=1
        ;;
    clean-cache)
        clean_cache ${@:2}
        ;;
    "")
        error "Missing command"
        ;;
    *)
        error "Unknown command: $1"
        ;;
esac
