#!/bin/bash

set -euo pipefail

name=
repo=
args=()

while [ $# -gt 0 ]; do
    case $1 in
    --name)
        name=$2
        shift 2
        ;;
    --repo)
        repo=$2
        shift 2
        ;;
    *)
        args+=($1)
        shift
        ;;
    esac
done

if [ -z "$name" ]; then
    echo "Missing --name" >&2
    exit 1
fi

if [ -z "$repo" ]; then
    echo "Missing --repo" >&2
    exit 1
fi

workdir=$(dirname $0)
image_name=ouisync-github-runner
container_name="$image_name-$name"

if [ -f "$workdir/Dockerfile" ]; then
    docker build -t $image_name $workdir
fi

docker_gid=$(getent group docker | cut -d: -f3)

docker run \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --name $container_name \
    --hostname $name \
    --group-add $docker_gid \
    --env GITHUB_TOKEN=$(cat "$workdir/.github-token") \
    --env GITHUB_REPO=$repo \
    ${args[@]} \
    $image_name
