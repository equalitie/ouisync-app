#!/bin/bash

set -e

source $(dirname $0)/utils.sh

function print_help() {
    echo "Script for building Ouisync App in a Docker container"
    echo "Usage: $0 (--commit <COMMIT> | --srcdir <SRCDIR>) [--out <OUTPUT_DIRECTORY>] [--flavor <FLAVOR>]"
    echo "  COMMIT:           Commit from which to build"
    echo "  SRCDIR:           Source dir from which to build"
    echo "  OUTPUT_DIRECTORY: Directory where artifacts will be stored"
    echo "  FLAVOR:           One of {production,nightly,unofficial}. The default is 'production' when '--commit'"
    echo "                    is used and 'unofficial' when '--srcdir' is used"
}

build_exe="--exe"
build_msix="--msix"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h) print_help; exit ;;
        --commit) commit="$2"; shift ;;
        --srcdir) srcdir="$2"; shift ;;
        --no-exe) build_exe='' ;;
        --no-msix) build_msix='' ;;
        --out) out_dir="$2"; shift ;;
        --flavor) flavor="$2"; shift ;;
        *) error "Unknown argument: $1" ;;
    esac
    shift
done

if [ -z "$commit" -a -z "$srcdir" ]; then error "Missing one of --commit or --srcdir"; fi
if [ -n "$commit" -a -n "$srcdir" ]; then error "--commit and --srcdir are mutually exclusive"; fi

source $(dirname $0)/windows/virtual_machine.sh

image_name=ouisync-runner-windows.$USER
container_name="ouisync.windows-builder.$(date +'%Y-%m-%dT%H-%M-%S')"

out_dir=${out_dir:=./releases/$container_name}

# Check dependencies and set flavor
if [ -n "$commit" ]; then
    check_dependency git
    flavor=${flavor:=production}
else
    check_dependency rsync
    flavor=${flavor:=unofficial}
fi

case "$flavor" in
    production|nightly|unofficial) ;;
    *) error "Invalid --flavor argument ($flavor)"
esac

# Collect secrets
if [ "$flavor" != "unofficial" ]; then
    secretSentryDSN=$(pass cenoers/ouisync/app/$flavor/sentry_dsn)
    secretCertHex=$(pass cenoers/ouisync/app/$flavor/windows/private.pfx | xxd -p)
    publicCertHex=$(pass cenoers/ouisync/app/$flavor/windows/public.cer | xxd -p)
    secretCertPassword=$(pass cenoers/ouisync/app/$flavor/windows/certificatePassword)
fi

ctx_vm=$(cat << EOF
    {
      "container_name":"$container_name",
      "image_name":"$image_name",
      "volume_name":"$image_name"
    }
EOF
)

vm_ensure_os_and_ssh_installed "$ctx_vm"

vm_install "$ctx_vm" $host_root/install/visual_studio.bat
vm_install "$ctx_vm" $host_root/install/rust.bat
vm_install "$ctx_vm" $host_root/install/git.bat
vm_install "$ctx_vm" $host_root/install/msys2.bat
vm_install "$ctx_vm" $host_root/install/inno_setup.bat
vm_install "$ctx_vm" $host_root/install/java.bat
vm_install "$ctx_vm" $host_root/install/flutter.bat

function cat_vm() (
    vm_ssh "[Console]::OpenStandardInput().CopyTo([IO.File]::Create(\"$1\"))"
)

function mkdir_vm() (
    vm_ssh "New-Item -ItemType Directory -Force -Path $1 | Out-Null"
)

####

start_vm "$ctx_vm"

# Enter the container on exit
trap on_exit EXIT
function on_exit() {
    echo "Entering VM"
    vm_ssh
    stop_vm "$ctx_vm"
}

await_ssh_connectible

mkdir_vm c:/src

if [ -n "$commit" ]; then
    vm_ssh "Remove-Item -Path 'c:/src' -Recurse -Force"
    vm_ssh "cd c:/; git clone --filter=tree:0 https://github.com/equalitie/ouisync-app src"
    vm_ssh "cd c:/src; git reset --hard $commit"
    vm_ssh "cd c:/src; git submodule update --init --recursive"
else
    vm_rsync_into $srcdir "/c/src"
fi

# Prepare secrets
if [ "$flavor" != "unofficial" ]; then
    mkdir_vm c:/secrets

    container_msix_cert_path=c:/secrets/private.pfx
    container_dsn_path=c:/secrets/sentry_dsn

    echo "$secretSentryDSN" | cat_vm $container_dsn_path
    echo $secretCertHex | xxd -p -r | cat_vm $container_msix_cert_path

    sentry_arg="--sentry=$container_dsn_path"
    msix_cert_path_arg="--msix-signing-cert-path=$container_msix_cert_path"
    msix_cert_pass_arg="--msix-signing-cert-pass=$secretCertPassword"
fi

# Generate bindings
vm_ssh "cd c:/src/ouisync/bindings/dart; dart pub get"
vm_ssh "cd c:/src/ouisync/bindings/dart; dart tool/bindgen.dart"

# Build Ouisync
vm_ssh "cd c:/src; dart pub get"
vm_ssh "cd c:/src; dart run util/release.dart --flavor=$flavor $sentry_arg $build_exe $build_msix $msix_cert_path_arg $msix_cert_pass_arg"

vm_out_dir=c:/src/releases/latest

# Add public certificate to artifacts
if [ -n "$build_msix" -a "$flavor" != "unofficial" ]; then
    echo $publicCertHex | xxd -p -r | cat_vm $vm_out_dir/public.cer
fi

# Collect artifacts
mkdir -p $out_dir
for asset in $(vm_ssh "c:/msys64/usr/bin/ls.exe $vm_out_dir"); do
    echo "Collecting artifact: $asset"
    scp "${vm_ssh_options[@]}" -P $host_ssh_port ssh@localhost:"$vm_out_dir/$asset" $out_dir
done
