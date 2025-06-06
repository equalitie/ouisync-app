#!/bin/bash

set -e

function print_help() {
    echo "Script for building Ouisync App in a Docker container"
    echo "Usage: $0 --host <HOST> --commit <COMMIT>"
    echo "  HOST:   IP or entry in ~/.ssh/config of machine running Docker"
    echo "  COMMIT: Commit from which to build"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) print_help; exit ;;
        --host) host="$2"; shift ;;
        -c|--commit) commit="$2"; shift ;;
        *) echo "Unknown argument: $1"; print_help; exit 1 ;;
    esac
    shift
done

if [ -z "$host"   ]; then echo "Use --host";   print_help; exit 1; fi
if [ -z "$commit" ]; then echo "Use --commit"; print_help; exit 1; fi

image_name=ouisync.windows-builder.$USER
container_name="ouisync.windows-builder.$(date +"%Y-%m-%dT%H-%M-%S")"

# Collect secrets
secretSentryDSN=$(pass cenoers/ouisync/app/production/sentry_dsn)

# Define shortcuts
function dock() {
    docker --host ssh://$host "$@"
}

function exe {
    local dir=$1; shift
    dock exec -w $dir $container_name "$@"
}

# Build image
dock build -t $image_name - < docker/Dockerfile.build-windows

# Start container; Auto destroy on this script exit
dock run -d --rm --name $container_name -p 22 ouisync.windows-builder \
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

# Determine container's SSH port
function container_ssh_port() {
    dock port $container_name | while read port_map; do
        ssh_port=${port_map#'22/tcp -> 0.0.0.0:'}
        [[ "$ssh_port" =~ ^[0-9]+$ ]] && echo $ssh_port && break || true
    done
}

ssh_port=$(container_ssh_port)
if [ -z "$ssh_port" ]; then
    echo "Failed to determine container's SSH port"
    exit 1
fi

# Prepare secrets
exe / mkdir c:\\secrets
exe / powershell -Command "Add-Content -Force -Path c:/secrets/sentry_dsn -Value \"$secretSentryDSN\""

# Clone Ouisync sources
exe / git clone --filter=tree:0 https://github.com/equalitie/ouisync-app
exe c:/ouisync-app git reset --hard $commit
exe c:/ouisync-app git submodule update --init --recursive

# Generate bindings
exe c:/ouisync-app/ouisync/bindings/dart dart pub get
exe c:/ouisync-app/ouisync/bindings/dart dart tool/bindgen.dart

# Build Ouisync
exe c:/ouisync-app dart pub get
exe c:/ouisync-app dart run util/release.dart --flavor=production --sentry=C:/secrets/sentry_dsn --exe --msix

# Collect artifacts. Hyper-V doesn't allow `docker cp` from a running container, so using scp
function setup_ssh() {
    local public_key=$(cat ~/.ssh/id_ed25519.pub)
    exe / powershell Add-Content -Force -Path C:\ProgramData\ssh\administrators_authorized_keys -Value "$public_key"
    exe / powershell Start-Service sshd
}

mkdir -p ./releases/$container_name
scp -P $ssh_port -r \
    -o "ProxyJump ${host}" \
    -o 'UserKnownHostsFile /dev/null' \
    -o 'StrictHostKeyChecking no' \
    ssh@localhost:c:/ouisync-app/releases ./releases/$container_name/
