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

source "./src/script/util.sh"

export KUBECONFIG="./secrets/kubeconfig.yml"

run_suffix=$(
    cat /dev/urandom \
        | base64 \
        | tr -cd '[:lower:][:digit:]' \
        | head -c 4 \
        | xargs -i printf '-%s' {}
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
            ".metadata.name += \"$run_suffix\"" \
            "./src/k8s/wf/func_tests.yml"
    ) \
    -o json \
    -p "openstack_token=$(cat ./secrets/openstack_token.txt)" \
    -p "gitlab_token=$(cat ./secrets/gitlab_token.txt)" \
    -p "test_name=k8s-eos" \
    -p "run_suffix=$run_suffix" \
    "$@"
