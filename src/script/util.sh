#!/bin/bash


if [ -n "$_script__util__guard" ]; then return; fi
_script__util__guard=$(date)


if [[ $OSTYPE == 'darwin'* ]]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi


function util::status () {
    local optstate="$(set +o)"
    set +e
    "$@" 1>&2
    printf "$?"
    eval "$optstate"
}


function util::log () {
    printf "$(date +'%Y-%m-%dT%H:%M:%S%z')\t$*\n" >&2
}


function util::lowercase () {
    tr "[:upper:]" "[:lower:]" <<< $1
}


function util::parse_bool () {
    case $(util::lowercase "${1:-false}") in
        1|y|yes|true)
            printf "true"
        ;;
        0|n|no|false)
            printf "false"
        ;;
        *)
            return -1
        ;;
    esac
}


function util::eval_bool () {
    case $(util::lowercase "${1:-false}") in
        1|y|yes|true)
            return 0
        ;;
        0|n|no|false)
            return 1
        ;;
        *)
            util::log "Failed to eval bool."
            return -1
        ;;
    esac
}


function util::dedent () {
    python -c \
        "import sys, textwrap; \
        sys.stdout.write(textwrap.dedent(sys.stdin.read()))
        " \
        <<< "$1"
}


# function util::src_path () {
#     src_caller="$1"
#     src_own="$0"

#     declare -A arr=(
#         [src_file_relpath]="$src_caller"
#         [src_file_abspath]=$(realpath "$src_caller")
#         [src_root_abspath]=$(realpath "$(realpath $(dirname "$src_own"))/../../..")
#     )

#     declare -p arr \
#         | cut -d "=" -f 2-
# }
