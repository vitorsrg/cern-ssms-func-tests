#!/bin/bash

################################################################################
#i  ...
#ii
#ii Inputs:
#ii     env     run_suffix
#ii     env     source_path
#ii     env     test_prefix
################################################################################

set -ex

source "./src/script/helper/k8s.sh"
source "./src/script/helper/util.sh"

################################################################################

cat "./src/scenario/k8s/always_fails.yml" \
    | yq -Y \
        ".metadata.name = \"$test_prefix\"" \
    | yq -Y \
        "(
            .spec.volumes[]
            | select(.name == \"func-tests-src\")
            | .configMap.items
        ) = input.configMap.items" \
        - \
        <(yq "." "./data/func_tests_mount.yml") \
    | yq -Y \
        "(
            .. .configMap?.name? // empty
            | select(. == \"func-tests-src\")
        ) += \"$run_suffix\"" \
    | k8s::render_var \
        "source_path" \
        "$source_path" \
        -
    | kubectl apply \
        -f -

k8s::follow_pod \
    "$test_prefix"

exit_code=$(
    k8s::get_pod_exit_code \
        "$test_prefix"
)

kubectl delete pod \
    "$test_prefix" \
    --timeout=60s \

exit "$exit_code"
