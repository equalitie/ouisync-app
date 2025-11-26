#!/bin/bash

set -euo pipefail

source $(dirname $0)/utils.sh

host=
commit=
srcdir=
shell=

base_name="ouisync-runner-linux"
default_image_name="$base_name:$USER"
image_name=$default_image_name

default_container_name="$base_name.$USER"
container_name=$default_container_name

cache_volume="$base_name-cache"
cache=

emulator_port=5554
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
        "start")
            echo "Explicitly start the container"
            echo
            echo "Usage: $0 start"
            echo
            echo "Subsequent commands run on this container instead of starting a new one."
            ;;
        "stop")
            echo "Explicitly stop the container"
            echo
            echo "Usage: $0 stop"
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
            echo "    --cache               Cache some dependencies and intermediate build artifacts"
            echo "    -s, --shell           Open a shell session in the container after the command finishes"
            echo
            echo "Commands:"
            echo "    help              Print help"
            echo "    build             Build release"
            echo "    unit-test         Run unit tests"
            echo "    integration-test  Run integration tests"
            echo "    analyze           Analyze the dart source code"
            echo "    start             Explicitly start the container"
            echo "    stop              Explicitly stop the container"
            echo
            echo "See '$0 help <command> for more information on a specific command"
            ;;
    esac
}

function build_container() {
    log_group_begin "Building image $image_name"

    ndk_version=$(cat ndk-version.txt)
    dock build -t $image_name --build-arg NDK_VERSION=$ndk_version - < docker/Dockerfile.linux

    log_group_end
}

function create_cache_volume() {
    log_group_begin "Create cache volume $cache_volume"

    dock volume create $cache_volume > /dev/null
    dock run --rm --mount src=$cache_volume,dst=/mnt/cache --workdir /mnt/cache $image_name \
        bash -c 'mkdir -p cargo/bin;
                 mkdir -p cargo/git/db;
                 mkdir -p cargo/registry/cache;
                 mkdir -p cargo/registry/index;
                 mkdir -p cargo-target;
                 mkdir -p pub-cache;
                 mkdir -p android-system-images;
                 mkdir -p gradle;'

    log_group_end
}

function cache_mount_options() {
    # Cargo global
    echo "--mount src=$cache_volume,dst=/root/.cargo/bin,volume-subpath=cargo/bin"
    echo "--mount src=$cache_volume,dst=/root/.cargo/registry/index,volume-subpath=cargo/registry/index"
    echo "--mount src=$cache_volume,dst=/root/.cargo/registry/cache,volume-subpath=cargo/registry/cache"
    echo "--mount src=$cache_volume,dst=/root/.cargo/git/db,volume-subpath=cargo/git/db"

    # Cargo per project
    echo "--mount src=$cache_volume,dst=/opt/ouisync-app/ouisync/target,volume-subpath=cargo-target"

    # Dart
    echo "--mount src=$cache_volume,dst=/root/.pub-cache,volume-subpath=pub-cache"

    # Android system images
    echo "--mount src=$cache_volume,dst=/opt/android-sdk/system-images,volume-subpath=android-system-images"

    # Gradle
    echo "--mount src=$cache_volume,dst=/root/.gradle,volume-subpath=gradle"
}

function start_container() {
    if [ -z "$commit" -a -z "$srcdir" ]; then error "Missing one of --commit or --srcdir"; fi
    if [ -n "$commit" -a -n "$srcdir" ]; then error "--commit and --src are mutually exclusive"; fi

    build_container

    if [ "$cache" = 1 ]; then
        create_cache_volume
    fi

    echo "Start container $container_name"

    local opts="-d --rm"

    # Sync localtime with host
    opts="$opts --mount type=bind,src=/etc/timezone,dst=/etc/timezone,ro"
    opts="$opts --mount type=bind,src=/etc/localtime,dst=/etc/localtime:ro"

    # Mount cache volume (if enabled)
    if [ "$cache" = 1 ]; then
        opts="$opts $(cache_mount_options)"
    fi

    # Needed for android emulator
    opts="$opts --device /dev/kvm"

    # HACK: Sharing gradle cache between multiple containers doesn't work because the gradle daemons
    # running in those containers can't talk to each other over a localhost TCP socket in order to
    # coordinate the locking. Using a host network is a quick and dirty way around that.
    opts="$opts --network host"

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

    # Run cargo sweep to delete all cargo artifacts older than 30 days (prevents unbounded cache grow)
    if [ "$cache" = 1 ]; then
        log_group_begin "Prune cached cargo artifacts"
        exe -t bash -c 'command -v cargo-sweep 2>&1 > /dev/null || cargo install cargo-sweep'
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
    (
        # First wait until the container is started...
        while true; do
            if is_container_running; then
                break
            fi

            sleep 5
        done

        # ...then keep poking the file until the container stops.
        while true; do
            if is_container_running; then
                exe touch /tmp/alive || true
            else
                break
            fi

            sleep 5
        done
    ) &

    # Run the container for as long as this script is running
    start_container sh -c 'sleep 60; while [ -n "$(find /tmp/alive -cmin -1)" ]; do sleep 10; done'

    # Stop the container on exit
    trap auto_stop_container EXIT
}

function auto_stop_container() {
    if [ "$shell" = 1 ]; then
        echo "Enter container $container_name"
        dock exec -it $container_name bash
    fi

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

function init() {
    # Auto-start the container unless already running
    is_container_running || auto_start_container
}

####################################################################################################
# Build the release artifacts for linux and android
function build() {
    init

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

    # Collect secrets
    if [ "$flavor" != unofficial ]; then
        local secretSentryDsn=$(pass cenoers/ouisync/app/$flavor/sentry_dsn)
        local secretStorePassword=$(pass cenoers/ouisync/app/$flavor/android/storePassword)
        local secretKeyAlias=$(pass cenoers/ouisync/app/$flavor/android/keyAlias)
        local secretKeyPassword=$(pass cenoers/ouisync/app/$flavor/android/keyPassword)
        local secretKeystoreHex=$(pass cenoers/ouisync/app/$flavor/android/keystore.jks | xxd -p)
    fi

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
        arg_android_key_properties="--android-key-properties=/opt/secrets/key.properties"
        arg_sentry="--sentry=/opt/secrets/sentry_dsn"
    fi

    # Build Ouisync app
    exe -w /opt/ouisync-app dart run util/release.dart \
        --flavor=$flavor \
        $arg_android_key_properties \
        $arg_sentry \
        --apk --aab --deb-gui --deb-cli

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

function start_emulator() {
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

    log_group_begin "Create AVD"
    exe sdkmanager --install "$system_image"
    echo "no" | exe -i avdmanager create avd --force --name $avd --package "$system_image" --sdcard $emulator_sdcard
    log_group_end

    #-----------------------------

    log_group_begin "Launch emulator"

    exe -t \
        -e ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL=1 \
        emulator -no-metrics -no-window -no-audio -avd $avd -port $emulator_port &

    # Wait for the emulator to boot
    while true; do
        local result=$(exe adb -s "emulator-$emulator_port" shell getprop sys.boot_completed 2> /dev/null)

        if [ "$result" = "1" ]; then
            break
        else
            echo "Waiting for the emulator to boot"
            sleep 1
        fi
    done

    log_group_end

    log_group_begin "Format sdcard"
    echo "yes" | exe -w /opt/ouisync-app -i ./util/adb-format-sdcard.sh -s "emulator-$emulator_port"
    log_group_end
}

function stop_emulator() {
    log_group_begin "Stop emulator"
    exe adb -s "emulator-$emulator_port" emu kill
    log_group_end
}

function integration_test_android() {
    local api=

    while true; do
        case ${1-} in
            --api)
                api="${2-}"
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

    log_group_begin "Pre-build the app for tests"
    exe -w /opt/ouisync-app -t flutter build apk --debug --flavor itest --target-platform android-x64
    log_group_end

    start_emulator --api $api

    log_group_begin "Run tests"
    exe -w /opt/ouisync-app -t flutter test integration_test --flavor itest --ignore-timeouts $@
    log_group_end

    stop_emulator
}

function integration_test_linux() {
    exe -w /opt/ouisync-app -t flutter test -d linux integration_test $@
}

# Run integration tests
function integration_test() {
    init

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

# Handle common options
while true; do
    case $1 in
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
case "$1" in
    help|h)
        print_help ${@:2}
        exit
        ;;
    start)
        start_container tail -f /dev/null
        ;;
    stop)
        stop_container
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
    shell|sh)
        init
        shell=1
        ;;
    "")
        error "Missing command"
        ;;
    *)
        error "Unknown command: $1"
        ;;
esac
