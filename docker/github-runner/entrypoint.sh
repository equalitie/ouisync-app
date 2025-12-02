#!/bin/bash

set -euo pipefail

if [ -z "${GITHUB_REPO-}" ]; then
    echo "The environment variable GITHUB_REPO is missing. It needs to be set to the 'owner/repo' of a Github repository for which to start the runner."
    exit 1
fi

if [ -z "${GITHUB_TOKEN-}" ]; then
    echo "The environment variable GITHUB_TOKEN is missing. It needs to be set to the Github personal access token with sufficient permissions to manage runners in $GITHUB_REPO."
    exit 1
fi

function gh() {
    curl -L \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/$GITHUB_REPO/$1
}

function remove() {
    local token=$(gh actions/runners/remove-token | jq --raw-output '.token')
    ./config.sh remove --token $token
}

trap remove EXIT

token=$(gh actions/runners/registration-token | jq --raw-output '.token')

if [ -z "$token" ]; then
    echo "Failed to get registration token" >&2
    exit 1
fi

./config.sh --unattended --replace --url https://github.com/$GITHUB_REPO --token $token
./run.sh
