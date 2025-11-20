#!/bin/bash

set -eu

host=
commit=
srcdir=
shell=

source $(dirname $0)/build-utils.sh

base_name="ouisync-runner-linux"
default_image_name="$base_name:$USER"
image_name=$default_image_name

cache=
cache_volume="$base_name-cache"

container_name=
container_id=

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
        *)
            echo "Script for building and testing Ouisync App in a Docker container"
            echo
            echo "Usage: $0 [OPTIONS] <COMMAND>"
            echo
            echo "Options:"
            echo "    -h, --help            Print help"
            echo "    --host <HOST>         IP or entry in ~/.ssh/config of machine running Docker. If omitted, runs locally"
            echo "    --commit <COMMIT>     Commit from which to build"
            echo "    --src <PATH>          Source dir from which to build"
            echo "    --container <NAME>    Assign a name to the docker container"
            echo "    --image <NAME>[:TAG]  Name (and optional tag) of the docker image to use [default: $default_image_name]"
            echo "    --cache               Cache intermediate build artifacts in a persistent docker volume"
            echo "    -s, --shell           Open a shell session in the container after the command finishes"
            echo
            echo "Commands:"
            echo "    help              Print help"
            echo "    build             Build release"
            echo "    unit-test         Run unit tests"
            echo "    integration-test  Run integration tests"
            echo "    analyze           Analyze the dart source code"
            echo
            echo "See '$0 help <command> for more information on a specific command"
            ;;
    esac
}

keep_alive_pid=

function build_container() {
    ndk_version=$(cat ndk-version.txt)
    dock build -t $image_name --build-arg NDK_VERSION=$ndk_version - < docker/Dockerfile.build-linux
}

function start_container() {

    local opts=

    if [ "$cache" = 1 ]; then
        opts="$opts --mount src=$cache_volume,dst=/opt/ouisync-app/ouisync/target,volume-subpath=cargo-target"
        opts="$opts --mount src=$cache_volume,dst=/root/.pub-cache,volume-subpath=pub-cache"
    fi

    if [ -n "$container_name" ]; then
        opts="$opts --name $container_name"
    fi

    # Run the container for as long as this script is running
    container_id=$(dock run -d --rm $opts $image_name \
        sh -c 'sleep 60; while [ -n "$(find /tmp/alive -cmin -1)" ]; do sleep 10; done')

    # Prevent the container from stopping
    while true; do exe touch /tmp/alive || true; sleep 5; done &
    keep_alive_pid=$!

    # Stop the container on exit
    trap stop_container EXIT
}

function stop_container() {
    if [ "$shell" = 1 ]; then
        echo "Entering container"
        dock exec -it $container_id bash
    fi

    echo "Stopping container"
    kill $keep_alive_pid
    dock container stop $container_id
}

function create_cache_volume() {
    dock volume create $cache_volume > /dev/null
    dock run --rm --mount src=$cache_volume,dst=/mnt/cache --workdir /mnt/cache $image_name \
        bash -c 'mkdir -p cargo-target; mkdir -p pub-cache'
}

function init() {
    if [ -z "$commit" -a -z "$srcdir" ]; then error "Missing one of --commit or --src"; fi
    if [ -n "$commit" -a -n "$srcdir" ]; then error "--commit and --src are mutually exclusive"; fi

    build_container

    if [ "$cache" = 1 ]; then
        create_cache_volume
    fi

    start_container

    if [ -n "$commit" ]; then
        get_sources_from_git $commit /opt
    else
        get_sources_from_local_dir $srcdir /opt
    fi

    # Generate bindings (TODO: This should be done automatically)
    exe -w /opt/ouisync-app/ouisync/bindings/dart dart pub get
    exe -w /opt/ouisync-app/ouisync/bindings/dart dart tool/bindgen.dart

    # Update dependencies
    exe -w /opt/ouisync-app dart pub get
}

# Build the release artifacts for linux and android
function run_build() {
    init

    local dst_dir="./releases/${container_name-default}"
    local flavor=

    while true; do
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
        function exe_i() { dock exec -i $container_id "$@"; }
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
        dock cp $container_id:$src_dir/$artifact $dst_dir/
    done
}

# Run unit tests
function run_unit_tests() {
    init

    # Build the library
    exe -w /opt/ouisync-app/ouisync -t cargo build --package ouisync-service --lib

    # Run tests
    exe -w /opt/ouisync-app -t -e OUISYNC_LIB=ouisync/target/debug/libouisync_service.so flutter test $@
}

# Analyze the dart source code
function run_analyze() {
    init

    exe -w /opt/ouisync-app/lib  -t flutter analyze
    exe -w /opt/ouisync-app/test -t flutter analyze
    exe -w /opt/ouisync-app/util -t flutter analyze
}

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
        --src|--srcdir)
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
    build|b)
        run_build ${@:2}
        ;;
    unit-test|unit-tests|ut)
        run_unit_tests ${@:2}
        ;;
    integration-test|integration-tests|it)
        run_integration_tests ${@:2}
        ;;
    analyze)
        run_analyze ${@:2}
        ;;
    shell)
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
