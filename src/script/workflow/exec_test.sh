#!/bin/bash

################################################################################
#i  ...
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/exec_test.sh"
#ii
#ii Inputs:
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
#ii     env     test_name
#ii     env     test_key
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/script/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"
source "./src/script/openstack/setup_k8s.sh" \
    "$cluster_name" \
    "/root/kubeconfig.yml"

kubectl config set-context \
    --current \
    --namespace=default

pod_suffix=$(
    cat /dev/urandom \
        | base64 \
        | tr -cd '[:lower:][:digit:]' \
        | head -c 4 \
        | xargs -i printf '-%s' {}
)

pod_name="test-$test_key-${test_name//_/-}$run_suffix$pod_suffix"

mkdir -p "/root/output/"

################################################################################

cat "./src/k8s/test/$test_name.yml" \
    | yq -Y \
        ".metadata.name = \"$pod_name\"" \
    | yq -Y \
        "(
            .. .claimName? // empty 
            | select(. == \"func-tests-src\")
        ) += \"$run_suffix\"" \
    | yq -Y \
        "(
            .. .value? // empty 
            | select(. == \"{{workflow.parameters.source_path}}\")
        ) = \"$source_path\"" \
    | kubectl apply \
        -f -

if ! kubectl wait pod \
    --for=condition=ready \
    --timeout=300s \
    "$pod_name"; then
    kubectl describe pod \
        "$pod_name"

    util::log "Pod took too long to start."
    exit -1
fi

kubectl logs \
    "$pod_name" \
    --follow

################################################################################

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

kubectl delete pod \
    "$pod_name" \
    --force \
    --timeout=60s \
    || true

if ! (
    [[ "$exit_code" -ge "0" ]] \
    && [[ "$exit_code" -le "255" ]]
); then
    util::log "Unexpected exit code."
    # TODO: rename to exit_code.txt
    printf "255" \
        > "/root/output/exit_code.txt"
    exit -1
else
    if [[ "$exit_code" == "0" ]]; then
        util::log "Test succeeded."
    else
        util::log "Test failed."
    fi
    printf "$exit_code" \
        > "/root/output/exit_code.txt"
fi
