#!/bin/bash

################################################################################
#i  ...
#ii
#ii Inputs:
#ii     env     run_suffix
#ii     env     gitlab_token
#ii     env     gitlab_url
#ii     env     source_path
#ii     env     test_prefix
################################################################################

set -ex

source "./src/helper/k8s.sh"
source "./src/helper/util.sh"

################################################################################

cat "./src/k8s/pod/always_fails.yml.jinja" \
    | python "./src/manage/render.py" \
        -D "gitlab_token" "$gitlab_token" \
        -D "gitlab_url" "$gitlab_url" \
        -D "source_path" "$source_path" \
    | yq -Y \
        ".metadata.name = \"$test_prefix\"" \
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
