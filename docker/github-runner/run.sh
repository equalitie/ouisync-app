#!/bin/bash

set -euo pipefail

github_token=${GITHUB_TOKEN-}
name=
repo=
args=()

function help() {
    echo "Run Github Actions self-hosted runner in a docker container."
    echo
    echo "Usage: $0 [OPTIONS] [ARGS...]"
    echo
    echo "Options:"
    echo "    --name <NAME>         Name of the runner (must be unique for the given git repo)"
    echo "    --repo <OWNER/REPO>   Github repo for which to start the runner"
    echo "    --token <TOKEN>       Github access token (see below for details)"
    echo "    --help                Print help"
    echo
    echo "Arguments:"
    echo "    Any additional arguments are passed to 'docker run'"
    echo
    echo "Github token:"
    echo "    This script requires a valid Github Personal Access Token in order to register/unregister the runner. The token can be either a Fine-grained personal access token with the 'Administration (write)' permission for the given repo or a Classic Personal Access Token with the 'repo' scope."
    echo
    echo "    The token can be passed in one of three ways: with the '--token' command line argument, with the 'GITHUB_TOKEN' env variable or read from the '.github-token' file in the same directory as this script."
}

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
    --token)
        github_token=$2
        shift 2
        ;;
    --help|-h)
        help
        exit
        ;;
    *)
        args+=($1)
        shift
        ;;
    esac
done

if [ -z "$name" ]; then
    echo "Missing --name" >&2
    help
    exit 1
fi

if [ -z "$repo" ]; then
    echo "Missing --repo" >&2
    help
    exit 1
fi

workdir=$(dirname $0)
image_name=ouisync-github-runner
container_name="$image_name-$name"

if [ -z "$github_token" ]; then
    github_token=$(cat "$workdir/.github-token" 2> /dev/null)
fi

if [ -z "$github_token" ]; then
    echo "Missing token" >&2
    help
    exit 1
fi

if [ -f "$workdir/Dockerfile" ]; then
    docker build -t $image_name $workdir
fi

# The container has access to the host's docker by mounting the docker socket into it. The container
# runs under a non-root user so in order for the user to invoke docker, it needs to be added to the
# host's 'docker' group.
docker_gid=$(getent group docker | cut -d: -f3)

docker run \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --name $container_name \
    --hostname $name \
    --group-add $docker_gid \
    --env GITHUB_TOKEN=$github_token \
    --env GITHUB_REPO=$repo \
    ${args[@]} \
    $image_name
