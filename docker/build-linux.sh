#!/bin/bash

set -e

function print_help() {
    echo "Script for building Ouisync App in a Docker container"
    echo "Usage: $0 --host <HOST> --commit <COMMIT> [--out <OUTPUT_DIRECTORY>]"
    echo "  HOST:             IP or entry in ~/.ssh/config of machine running Docker"
    echo "  COMMIT:           Commit from which to build"
    echo "  OUTPUT_DIRECTORY: Directory where artifacts will be stored"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) print_help; exit ;;
        --host) host="$2"; shift ;;
        --commit) commit="$2"; shift ;;
        --out) dst_dir="$2"; shift ;;
        *) echo "Unknown argument: $1"; print_help; exit 1 ;;
    esac
    shift
done

if [ -z "$host"   ]; then echo "Missing --host";   print_help; exit 1; fi
if [ -z "$commit" ]; then echo "Missing --commit"; print_help; exit 1; fi

image_name=ouisync.linux-builder.$USER
container_name="ouisync.linux-builder.$(date +'%Y-%m-%dT%H-%M-%S')"

dst_dir=${dst_dir:=./releases/$container_name}

# Collect secrets
secretSentryDsn=$(pass cenoers/ouisync/app/production/sentry_dsn)
secretStorePassword=$(pass cenoers/ouisync/app/production/android/storePassword)
secretKeyAlias=$(pass cenoers/ouisync/app/production/android/keyAlias)
secretKeyPassword=$(pass cenoers/ouisync/app/production/android/keyPassword)
secretKeystoreHex=$(pass cenoers/ouisync/app/production/android/keystore.jks | xxd -p)

# Define shortcuts
function dock() {
    docker --host ssh://$host "$@"
}

function exe() {
    local dir=$1; shift
    dock exec -w $dir $container_name "$@"
}

function exe_i() {
    dock exec -i $container_name "$@"
}

# Build docker image
dock build -t $image_name - < docker/Dockerfile.build-linux

# Run the container for as long as this script is running
dock run -d --rm --name $container_name $image_name \
    sh -c 'sleep 60; while [ -n "$(find /tmp/alive -cmin -10)" ]; do sleep 10; done'

# Prevent the container from stopping
(while true; do exe / touch /tmp/alive || true; sleep 14; done) &

# Enter the container on exit
trap on_exit EXIT
function on_exit() {
    echo "Entering container $container_name"
    dock exec -it $container_name bash
    echo "Stopping the container"
    dock container stop $container_name
}

# Set up secrets inside the container
exe / mkdir -p /opt/secrets
echo "$secretKeystoreHex" | xxd -p -r      | exe_i dd of=/opt/secrets/keystore.jks
echo "storePassword=$secretStorePassword"  | exe_i dd of=/opt/secrets/key.properties
echo "keyPassword=$secretKeyPassword"      | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
echo "keyAlias=$secretKeyAlias"            | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
echo "storeFile=/opt/secrets/keystore.jks" | exe_i dd of=/opt/secrets/key.properties oflag=append conv=notrunc
echo "$secretSentryDsn"                    | exe_i dd of=/opt/secrets/sentry_dsn

# Checkout Ouisync sources
exe /opt git clone --filter=tree:0 https://github.com/equalitie/ouisync-app
exe /opt/ouisync-app git reset --hard $commit
exe /opt/ouisync-app git submodule update --init --recursive

# Generate bindings (TODO: This should be done automatically)
exe /opt/ouisync-app/ouisync/bindings/dart dart pub get
exe /opt/ouisync-app/ouisync/bindings/dart dart tool/bindgen.dart

# Build Ouisync app
exe /opt/ouisync-app dart pub get
exe /opt/ouisync-app dart run util/release.dart \
    --android-key-properties=/opt/secrets/key.properties \
    --flavor=production \
    --sentry=/opt/secrets/sentry_dsn \
    --apk --aab --deb-gui --deb-cli

# Collect artifacts
mkdir -p $dst_dir
src_dir=/opt/ouisync-app/releases/latest
for artifact in $(exe $src_dir ls); do
    dock cp $container_name:$src_dir/$artifact $dst_dir/
done
