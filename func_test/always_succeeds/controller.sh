#!/bin/bash

################################################################################
#i  ...
#ii
#ii Inputs:
#ii     env     run_suffix
#ii     env     gitlab_token
#ii     env     gitlab_url
#ii     env     git_branch
#ii     env     test_prefix
################################################################################

set -ev

source "./lib/k8s.sh"
source "./lib/util.sh"

set +v -x

################################################################################

cat "./func_test/always_succeeds/pod.yml.jinja" \
    | python "./lib/render.py" \
        -D "gitlab_token" "$gitlab_token" \
        -D "gitlab_url" "$gitlab_url" \
        -D "git_branch" "$git_branch" \
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
