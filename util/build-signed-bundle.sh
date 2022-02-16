#!/bin/bash

set -e

function usage {
    echo "Usage: cd <ouisync-app> && ./util/$(basename $0) <build-name> <keystore> <storepass>"
    echo "    <build-name>    a version triple such as 0.0.1 or 0.0.1-rc1"
    echo "    <keystore>      path to the keystore (.jks) file"
    echo "    <storepass>     path to the containing the password for unlocking the keystore"
}

if [ "$1" = "-h" ]; then
    usage $0
    exit
fi

if [ ! -f ./pubspec.yaml ]; then
    echo "This script must be run from the root of the ouisync-app repository"
    usage $0
    exit 1
fi

build_name="$1" #e.g. "0.0.1-rc1"
keystore="$2"
storepass="$3"

if [ ! -f "$keystore" ]; then
    echo "No such <keystore> file '$keystore'"
    exit 1
fi

if [ ! -f "$storepass" ]; then
    echo "No such <storepass> file '$storepass'"
    exit 1
fi

if [[ $(git diff --stat) != '' ]]; then
    while true; do
        echo "Git is dirty:"
        echo "Continue anyway? (y/N/d=diff/s=status)"
        read answer
        case "$answer" in
            y)
                break
                ;;
            d)
                git diff
                ;;
            s)
                git status
                ;;
            *)
                exit
                ;;
        esac
    done
fi


# https://stackoverflow.com/a/1248795/273348
date_tag=$(date -u "+%Y-%m-%d--%H-%M-%S--UTC")
git_commit="$(git rev-parse --short HEAD)"
input_bundle=./build/app/outputs/bundle/release/app-release.aab

NO_SIGN="true" flutter build appbundle --release --build-name=$build_name-$git_commit
jarsigner -keystore "$keystore" -storepass:file $storepass $input_bundle upload

mkdir -p ./build/releases/

output_bundle=./build/releases/ouisync-release--v${build_name}--${date_tag}--$git_commit.aab
echo "Moving signed bundle to $output_bundle"
mv $input_bundle $output_bundle
