#!/bin/bash

################################################################################
#i  ...
################################################################################

if [ -n "$_script__helper__k8s__guard" ]; then return; fi
_script__helper__k8s__guard=$(date)

source "./lib/util.sh"

################################################################################


function k8s::wait_pod_ready () {
    pod_name="$1"

    if ! kubectl wait pod \
        --for=condition=ready \
        --timeout=30s \
        "$pod_name"; then
        kubectl describe pod \
            "$pod_name"

        kubectl logs "$pod_name" -c clone-source

        util::log "Pod took too long to start."
        return -1
    fi
}


function k8s::follow_pod () {
    pod_name="$1"

    k8s::wait_pod_ready \
        "$pod_name"

    kubectl logs \
        "$pod_name" \
        --follow
}


function k8s::get_pod_exit_code () {
    pod_name="$1"

    exit_code=$(
        kubectl get pod \
            "$pod_name" \
            -o json \
            | jq -jr \
                '
                .status.containerStatuses
                | map(select(.name == "main"))
                | first
                | .state.terminated.exitCode
                '
    )

    if ! (
        [[ "$exit_code" -ge "0" ]] \
        && [[ "$exit_code" -le "255" ]]
    ); then
        util::log "Unexpected exit code."
        return -1
    fi

    printf "$exit_code"
}
