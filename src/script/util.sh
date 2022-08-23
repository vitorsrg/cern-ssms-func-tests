#!/bin/bash


if [ -n "$_script__util__guard" ]; then return; fi
_script__util__guard=$(date)


function util::log () {
    printf "$(date +'%Y-%m-%dT%H:%M:%S%z')\t$*" >&2
}


function util::lowercase () {
    tr "[:upper:]" "[:lower:]" <<< $1
}


function util::parse_bool () {
    case lowercase "${1:-false}" in
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

function util::dedent () {
    python -c \
        "
        import sys, textwrap; \
        sys.stdout.write(textwrap.dedent(sys.stdin.read()))
        " \
        <<< $1
}
