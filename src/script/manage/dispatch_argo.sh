#!/usr/bin/env bash

################################################################################
#i  Configure OpenStack and Kubernetes local env.
#ii
#ii Example:
#ii     bash "./src/script/manage/dispatch_argo.sh"
#ii     bash "./src/script/manage/dispatch_argo.sh" --watch
#ii     bash "./src/script/manage/dispatch_argo.sh" --log
#ii
#ii Inputs:
#ii     file    "./secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      setup_creds
################################################################################

set -ex

export KUBECONFIG="./secrets/kubeconfig.yml"

run_key=$(
    cat /dev/urandom \
        | base64 \
        | tr -cu -d '[:lower:][:digit:]' \
        | head -c 4
)

################################################################################

# NOTE: convenience for quick testing
# TODO: remove this
git add -A
git commit -S -a -m 'fixup' || true
git push gitlab HEAD:vitorsrg

################################################################################

kubectl apply \
    -f "./src/k8s/sc/manila_ephemeral.yml"

./argo.bin \
    submit \
    -n argo \
    <(
        yq -Y \
            ".metadata.name += \"-$run_key\"" \
            "./src/k8s/wf/func_tests.yml"
    ) \
    -p "openstack_token=$(cat ./secrets/openstack_token.txt)" \
    -p "gitlab_token=$(cat ./secrets/gitlab_token.txt)" \
    -p "test_name=k8s-eos" \
    -p "run_key=$run_key" \
    "$@"
