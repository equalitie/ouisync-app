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
