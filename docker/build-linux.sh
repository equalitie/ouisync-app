#!/bin/bash

set -e

source $(dirname $0)/build-utils.sh

function print_help() {
    echo "Script for building Ouisync App in a Docker container"
    echo "Usage: $0 --host <HOST> (--commit <COMMIT> | --srcdir <SRCDIR>) [--out <OUTPUT_DIRECTORY>]"
    echo "  HOST:             IP or entry in ~/.ssh/config of machine running Docker"
    echo "  COMMIT:           Commit from which to build"
    echo "  SRCDIR:           Source dir from which to build"
    echo "  OUTPUT_DIRECTORY: Directory where artifacts will be stored"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) print_help; exit ;;
        --host) host="$2"; shift ;;
        --commit) commit="$2"; shift ;;
        --srcdir) srcdir="$2"; shift ;;
        --out) dst_dir="$2"; shift ;;
        *) error "Unknown argument: $1" ;;
    esac
    shift
done

if [ -z "$host"   ]; then error "Missing --host"; fi
if [ -z "$commit" -a -z "$srcdir" ]; then error "Missing one of --commit or --srcdir"; fi
if [ -n "$commit" -a -n "$srcdir" ]; then error "--commit and --srcdir are mutually exclusive"; fi

if [ -n "$commit" ]; then
    flavor=production
elif [ -n "$srcdir" ]; then
    flavor=unofficial
fi

image_name=ouisync.linux-builder.$USER
container_name="ouisync.linux-builder.$(date +'%Y-%m-%dT%H-%M-%S')"

dst_dir=${dst_dir:=./releases/$container_name}

# Collect secrets
if [ "$flavor" != unofficial ]; then
    secretSentryDsn=$(pass cenoers/ouisync/app/$flavor/sentry_dsn)
    secretStorePassword=$(pass cenoers/ouisync/app/$flavor/android/storePassword)
    secretKeyAlias=$(pass cenoers/ouisync/app/$flavor/android/keyAlias)
    secretKeyPassword=$(pass cenoers/ouisync/app/$flavor/android/keyPassword)
    secretKeystoreHex=$(pass cenoers/ouisync/app/$flavor/android/keystore.jks | xxd -p)
fi

# Build docker image
dock build -t $image_name - < docker/Dockerfile.build-linux

# Run the container for as long as this script is running
dock run -d --rm --name $container_name $image_name \
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
    dock container rm -f $container_name
}

# Set up secrets inside the container
if [ "$flavor" != unofficial ]; then
    function exe_i() { dock exec -i $container_name "$@"; }
    exe / mkdir -p /opt/secrets
    echo "$secretKeystoreHex" | xxd -p -r      | exe_i dd of=/opt/secrets/keystore.jks
    echo "storePassword=$secretStorePassword"  | exe_i dd of=/opt/secrets/key.properties
    echo "keyPassword=$secretKeyPassword"      | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
    echo "keyAlias=$secretKeyAlias"            | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
    echo "storeFile=/opt/secrets/keystore.jks" | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
    echo "$secretSentryDsn"                    | exe_i dd of=/opt/secrets/sentry_dsn
    arg_android_key_properties="--android-key-properties=/opt/secrets/key.properties"
    arg_sentry="--sentry=/opt/secrets/sentry_dsn"
fi

# Checkout or copy Ouisync sources
if [ -n "$commit" ]; then
    get_sources_from_git $commit /opt
else
    get_sources_from_local_dir $srcdir /opt
fi

# Generate bindings (TODO: This should be done automatically)
exe /opt/ouisync-app/ouisync/bindings/dart dart pub get
exe /opt/ouisync-app/ouisync/bindings/dart dart tool/bindgen.dart

# Build Ouisync app
exe /opt/ouisync-app dart pub get
exe /opt/ouisync-app dart run util/release.dart \
    --flavor=$flavor \
    $arg_android_key_properties \
    $arg_sentry \
    --apk --aab --deb-gui --deb-cli

# Collect artifacts
mkdir -p $dst_dir
src_dir=/opt/ouisync-app/releases/latest
for artifact in $(exe $src_dir ls); do
    dock cp $container_name:$src_dir/$artifact $dst_dir/
done
