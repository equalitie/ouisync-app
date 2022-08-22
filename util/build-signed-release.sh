#!/bin/bash

set -e

function usage {
    echo "Usage: cd <ouisync-app> && ./util/$(basename $0) <build-name> <build-number> <keystore> <storepass>"
    echo "    <build-name>    a version triple such as 0.0.1 or 0.0.1-rc1"
    echo "    <build-number>  the build number (use 'flutter build appbundle -h' for more info)"
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
build_number="$2"
keystore="$3"
storepass="$4"

if [ -z "$build_number" ]; then
    echo "The build number argument can't be an empty string"
    exit 1
fi

if [ ! -f "$keystore" ]; then
    echo "No such <keystore> file '$keystore'"
    exit 1
fi

if [ ! -f "$storepass" ]; then
    echo "No such <storepass> file '$storepass'"
    exit 1
fi

dirty=""
#if [[ "$ignore_git_dirty" == 'n']] then
#    if [[ $(git diff --stat) != '' ]]; then
#        while true; do
#            echo "Git is dirty. Continue anyway? (y/N/d=diff/s=status)"
#            read answer
#            case "$answer" in
#                y)
#                    dirty="-dirty"
#                    break
#                    ;;
#                d)
#                    git diff
#                    ;;
#                s)
#                    git status
#                    ;;
#                *)
#                    exit
#                    ;;
#            esac
#        done
#    fi
#fi

# https://stackoverflow.com/a/1248795/273348
date_tag=$(date -u "+%Y-%m-%d--%H-%M-%S--UTC")
git_commit="$(git rev-parse --short HEAD)"

tags="release--$(printf '%05d' $build_number)--v${build_name}--${date_tag}--${git_commit}${dirty}"
release_dir="./releases/$tags"

if [ -d "$release_dir" ]; then
  echo "The release \"$tags\" already exists"
  exit 1
fi

input_bundle=./build/app/outputs/bundle/release/app-release.aab

# I noticed that when the apk/aab is created, the process adds libraries for platforms that were not
# specified below (created while debugging), so better clean the build first.
# TODO: Consider doing this in a clean container.
flutter clean

## These are the default targets/platforms, uncomment and edit if needed.
#platforms_flag="--target-platform android-arm,android-arm64,android-x64"

NO_SIGN="true" \
    flutter build appbundle \
    --release \
    $platforms_flag \
    --build-number=$build_number \
    --build-name=$build_name-$git_commit

jarsigner -keystore "$keystore" -storepass:file $storepass $input_bundle upload


bundletool_version="1.8.2"
bundletool="bundletool-all-$bundletool_version.jar"

mkdir -p $release_dir

output_bundle=$release_dir/ouisync-$tags.aab
echo "Moving signed bundle to $output_bundle"
mv $input_bundle $output_bundle

if [ ! -f "./releases/$bundletool" ]; then
  echo "Downloading bundletool to generate apk"
  wget --directory-prefix ./releases \
    https://github.com/google/bundletool/releases/download/$bundletool_version/$bundletool
fi

java -jar ./releases/$bundletool \
  build-apks \
  --bundle=$output_bundle \
  --mode=universal \
  --ks=$keystore \
  --ks-pass=file:$storepass \
  --ks-key-alias=upload \
  --key-pass=file:$storepass \
  --output=$release_dir/ouisync-$tags.apks

cd $release_dir;
mv ouisync-$tags.apks ouisync-$tags.zip
unzip ouisync-$tags.zip;
rm toc.pb # created by unzip
rm ouisync-$tags.zip;
mv universal.apk ouisync-$tags.apk
