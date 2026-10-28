#!/bin/bash

set -e

function error() {
    echo "❌ Error: $@"
    exit 1
}

host_root=$(dirname $0)/windows
host_ssh_port=2222

### Utils

# Utility to check if first argument is in rest of the arguments
function is_in (
    item=$1; shift
    list="$@"
    for i in ${list[@]}; do
        if [ "$item" == "$i" ]; then return 0; fi
    done
    return 1
)

# Adds prefix to lines from piped input
function prefix (
    p=$1
    while IFS= read -r line; do
        echo "$p$line"
    done
)

### VM

function vm_ctx_image_name() (
    echo $1 | jq -r '.image_name'
)

function vm_ctx_container_name() (
    echo $1 | jq -r '.container_name'
)

function vm_ctx_volume_name() (
    echo $1 | jq -r '.volume_name'
)

function vm_ctx_sharedir() (
    echo $1 | jq -r '.sharedir'
)

function start_vm() (
    # https://github.com/dockur/windows

    ctx=$1

    if [ -n "$(container_id "$ctx")" ]; then
        error "The container is already running"
    fi

    image_name=$(vm_ctx_image_name "$ctx")
    container_name=$(vm_ctx_container_name "$ctx")
    volume_name=$(vm_ctx_volume_name "$ctx")

    docker build --progress plain -t $image_name - < $host_root/Dockerfile

    docker volume create $volume_name || true

    docker_run_args=(
        --rm 
        --name $container_name 
        -p 8006:8006 
        # RDP (e.g. Remmina)
        # Username: Docker
        # Password: admin
        -p 3389:3389/tcp
        -p 3389:3389/udp
        # SSH, after it is installed, add you'r public key to
        # C:/ProgramData/ssh/administrators_authorized_keys
        # and connect using `ssh ssh@localhost -p $host_ssh_port`
        -p $host_ssh_port:22/tcp
        --device=/dev/kvm 
        --device=/dev/net/tun 
        --cap-add NET_ADMIN 
        -v "$volume_name:/storage" 
        -v "$host_root/oem:/oem"
        --stop-timeout 120 
        # "Windows 11 LTSC
        -e VERSION=11l
        -e RAM_SIZE="16G"
        -e CPU_CORES="6"
        # QCOW2 allows snapshotting
        # https://github.com/dockur/windows/issues/485#issuecomment-5344257600
        -e DISK_FMT="qcow2"
    )
    
    sharedir=$(vm_ctx_sharedir "$ctx")

    if [ -n "$sharedir" ]; then
        # In the VM this will be in Z:\ and C:\Users\Docker\Desktop\Shared
        docker_run_args+=(-v "$sharedir:/shared")
    fi

    docker run ${docker_run_args[@]} $image_name 2>&1 | prefix "🪟 " &
)

function stop_vm() (
    container_name=$(vm_ctx_container_name "$1")
    echo "Stopping VM"
    docker stop --timeout 120 $container_name >/dev/null
)

###

function container_id() (
    ctx="$1"
    docker ps -a -q -f name=^$(vm_ctx_container_name "$ctx")$ 2>/dev/null
)

### SSH utils

vm_ssh_options=(
    -q # quiet
    -o "StrictHostKeyChecking=no"
    -o "UserKnownHostsFile=/dev/null"
)

function vm_ssh() (
    args=(
        -p $host_ssh_port
        ssh@localhost
    )
    ssh "${vm_ssh_options[@]}" "${args[@]}" "$@"
)

function vm_scp() (
    src=$1
    dst=$2
    args=(
        -P $host_ssh_port
        $src ssh@localhost:$dst
    )
    scp "${vm_ssh_options[@]}" "${args[@]}"
)

function await_ssh_connectible() (
    while ! vm_ssh exit; do sleep 0.5; done
)

### Rsync

function vm_rsync_into () (
    local srcdir=$1
    local dstdir=$2

    local exclude_dirs=(
        .dart_tool
        android/app/.cxx
        build
        ios
        linux/flutter/ephemeral
        ouisync/.git
        ouisync/target
        releases
        tmp
        windows/flutter/ephemeral
        .git
    )

    rsync -e "ssh ${vm_ssh_options[*]} -p $host_ssh_port" \
        --archive --no-links --verbose \
        --compress \
        --rsync-path='C:\msys64\usr\bin\rsync.exe' \
        "${exclude_dirs[@]/#/--exclude=}" \
        ${srcdir%/}/ ssh@localhost:$dstdir
)

### Snapshots

# https://github.com/dockur/windows/issues/485#issuecomment-5344257600
function vm_snapshot() (
    image_name=$(vm_ctx_image_name "$1")
    volume_name=$(vm_ctx_volume_name "$1")

    action=$2
    arg=$3

    docker run -it --rm \
        -v "$volume_name:/storage" \
        --entrypoint /bin/bash \
        $image_name \
        -c "qemu-img snapshot $action $arg /storage/data.qcow2" \
        2>/dev/null
)

function snapshot_tags() (
    # `snapshot -l` prints a table like this, we're only interested in the "tags"
    #
    #   Snapshot list:
    #   ID      TAG               VM_SIZE                DATE        VM_CLOCK     ICOUNT
    #   1       foobar                0 B 2026-10-14 09:23:49  0000:00:00.000          0
    vm_snapshot "$1" -l | grep '^[0-9]\+' | tr -s ' ' ' ' | cut -d ' ' -f 2 || true
)

### Installations

function vm_ensure_os_and_ssh_installed() (
    ctx=$1

    snapshot_tag="os_installed"

    if is_in $snapshot_tag $(snapshot_tags "$ctx"); then
        echo "👍 Windows OS and OpenSSH already installed"
        return
    fi

    echo "👉 Installing Windows OS and OpenSSH"

    (
        cp ~/.ssh/id_ed25519.pub $host_root/oem/
        start_vm "$ctx"
        trap 'stop_vm "$ctx"' RETURN EXIT
        await_ssh_connectible
    )

    vm_snapshot "$ctx" -c $snapshot_tag
)

function vm_install() (
    ctx="$1"
    bat_path=$2
    bat_file=$(basename $bat_path)
    snapshot_tag="installed_${bat_file%.*}"

    if is_in $snapshot_tag $(snapshot_tags "$ctx"); then
        echo "👍 Already installed $bat_file"
        return
    fi

    echo "👉 Installing $bat_file"

    (
        start_vm "$ctx"
        trap 'stop_vm "$ctx"' RETURN EXIT

        await_ssh_connectible

        vm_scripts_path="C:\\Users\\Docker\\InstallScripts"

        vm_ssh "New-Item -ItemType Directory -Force -Path $vm_scripts_path | Out-Null"
        vm_scp $bat_path "$vm_scripts_path"
        vm_ssh "$vm_scripts_path\\$bat_file"
    )

    vm_snapshot "$ctx" -c $snapshot_tag
)
