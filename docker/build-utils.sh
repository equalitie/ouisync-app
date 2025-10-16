function error() {
    echo >&2 "$1"
    echo
    print_help
    exit 1
}

function check_dependency {
    local dep=$1
    command -v $dep >/dev/null 2>&1 || { error "'$dep' is not installed"; }
}

function dock() {
    docker --host ssh://$host "$@"
}

function exe() (
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -d) local dir_opt="-w $2"; shift ;;
            -i) local interactive_opt="-i" ;;
            -l) local history_log=1 ;;
            *) break ;;
        esac
        shift
    done

    local cmd="dock exec $dir_opt $interactive_opt $container_name $@"

    if [ "$history_log" == 1 ]; then
        echo $cmd | dock exec -i $container_name dd of=/root/.bash_history oflag=append conv=notrunc
    fi

    $cmd
)

function get_sources_from_git {
    local commit=$1
    local dstdir=$2

    # Remove slash suffix if present
    dstdir=${dstdir%/}

    exe -d $dstdir/ git clone --filter=tree:0 https://github.com/equalitie/ouisync-app
    exe -d $dstdir/ouisync-app git reset --hard $commit
    exe -d $dstdir/ouisync-app git submodule update --init --recursive
}

function get_sources_from_local_dir {
    local srcdir=$1
    local dstdir=$2

    local exclude_dirs=(
        # .git is needed for release.dart script to read git commit
        ouisync/.git
        ouisync/target
        releases
        .dart_tool
        ios
        android/app/.cxx
        build
        windows/flutter/ephemeral
        linux/flutter/ephemeral
    )

    rsync -e "docker --host ssh://$host exec -i" \
        -av \
        --no-links \
        ${exclude_dirs[@]/#/--exclude=} \
        ${srcdir%/}/ $container_name:$dstdir/ouisync-app

    exe git config --global --add safe.directory /opt/ouisync-app
}
