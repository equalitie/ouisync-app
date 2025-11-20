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
    if [ -n "$host" ]; then
        docker --host ssh://$host "$@"
    else
        docker "$@"
    fi
}

function exe() (
    local opts=
    local history_log=

    while true; do
        case $1 in
            -w|--workdir) opts="$opts --workdir $2"; shift ;;
            -i|--interactive) opts="$opts --interactive" ;;
            -e|--env) opts="$opts --env $2"; shift ;;
            -t|--tty) opts="$opts --tty" ;;
            -l) history_log=1 ;;
            -*) echo "exe: unknown option: $1" >&2; exit ;;
            *) break ;;
        esac
        shift
    done

    local cmd="dock exec $opts $container_name $@"

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

    exe -w $dstdir/ git clone --filter=tree:0 https://github.com/equalitie/ouisync-app
    exe -w $dstdir/ouisync-app git reset --hard $commit
    exe -w $dstdir/ouisync-app git submodule update --init --recursive
}

function get_sources_from_local_dir {
    local srcdir=$1
    local dstdir=$2

    local exclude_dirs=(
        # .git is needed for release.dart script to read git commit
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
    )

    local host_opt=
    if [ -n "$host" ]; then
        host_opt="--host ssh://$host"
    fi

    rsync -e "docker $host_opt exec -i" \
        -av \
        --no-links \
        --quiet \
        ${exclude_dirs[@]/#/--exclude=} \
        ${srcdir%/}/ $container_name:$dstdir/ouisync-app

    exe git config --global --add safe.directory /opt/ouisync-app
}
