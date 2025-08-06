#!/bin/bash

set -e

source $(dirname $0)/build-utils.sh

function print_help() {
    echo "Script for building Ouisync App in a Docker container"
    echo "Usage: $0 --host <HOST> (--commit <COMMIT> | --srcdir <SRCDIR>) [--out <OUTPUT_DIRECTORY>]"
    echo "  HOST:             IP or entry in ~/.ssh/config of machine running Docker"
    echo "  COMMIT:           Commit from which to build"
    echo "  OUTPUT_DIRECTORY: Directory where artifacts will be stored"
}

build_exe="--exe"
build_msix="--msix"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) print_help; exit ;;
        --host) host="$2"; shift ;;
        --commit) commit="$2"; shift ;;
        --srcdir) srcdir="$2"; shift ;;
        --no-exe) build_exe='' ;;
        --no-msix) build_msix='' ;;
        --out) out_dir="$2"; shift ;;
        *) error "Unknown argument: $1" ;;
    esac
    shift
done

if [ -z "$host"   ]; then error "Missing --host"; fi
if [ -z "$commit" -a -z "$srcdir" ]; then error "Missing one of --commit or --srcdir"; fi
if [ -n "$commit" -a -n "$srcdir" ]; then error "--commit and --srcdir are mutually exclusive"; fi

image_name=ouisync.windows-builder.$USER
container_name="ouisync.windows-builder.$(date +'%Y-%m-%dT%H-%M-%S')"

# BuildKit is not supported on Windows yet
export DOCKER_BUILDKIT=0

out_dir=${out_dir:=./releases/$container_name}

# Collect secrets (only sentry DSN on Windows)
if [ -n "$commit" ]; then
    check_dependency git
    secretSentryDSN=$(pass cenoers/ouisync/app/production/sentry_dsn)
    flavor=production
else
    check_dependency rsync
    flavor=unofficial
fi

# Build image
dock build -t $image_name $isolation -m 15G - < docker/Dockerfile.build-windows

host_core_count=$(ssh $host 'cmd /s /c echo %NUMBER_OF_PROCESSORS%' | tr -d '[:space:]')

# Start container; Auto destroy on this script exit
dock run -d --rm --name $container_name --cpus $host_core_count -p 22 $image_name \
    sh -c 'sleep 60; while [ -n "$(find /tmp/alive -cmin -10)" ]; do sleep 10; done'

# Prevent the container from stopping
while true; do exe / touch /tmp/alive || true; sleep 14; done &
keep_alive_pid=$!

# Enter the container on exit
trap on_exit EXIT
function on_exit() {
    echo "Entering container $container_name"
    dock exec -it $container_name bash
    echo "Stopping the container"
    kill $keep_alive_pid
    dock container stop $container_name
}

# Prepare secrets
if [ "$flavor" = "production" ]; then
    exe / mkdir c:\\secrets
    exe / powershell -Command "Add-Content -Force -Path c:/secrets/sentry_dsn -Value \"$secretSentryDSN\""
    sentry_arg='--sentry=C:/secrets/sentry_dsn'
fi

# Checkout or copy Ouisync sources
if [ -n "$commit" ]; then
    get_sources_from_git $commit c:
else
    get_sources_from_local_dir $srcdir  /c
fi

# Generate bindings
exe c:/ouisync-app/ouisync/bindings/dart dart pub get
exe c:/ouisync-app/ouisync/bindings/dart dart tool/bindgen.dart

# Build Ouisync
exe c:/ouisync-app dart pub get
exe c:/ouisync-app dart run util/release.dart --flavor=$flavor $sentry_arg $build_exe $build_msix

function dock_rsync() {
    rsync -e "docker -H ssh://$host exec -i" "$@"
}

mkdir -p $out_dir
for asset in $(exe c:/ouisync-app/releases/latest ls); do
    dock_rsync -av $container_name:/c/ouisync-app/releases/latest/$asset $out_dir
done
