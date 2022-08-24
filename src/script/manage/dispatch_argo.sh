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

git commit -S -a -m 'fixup' || true
git push gitlab HEAD:vitorsrg

export KUBECONFIG="./secrets/kubeconfig.yml"

kubectl apply \
    -f "./src/workflow/storage_class.yml"

./argo.bin \
    submit -n argo ./src/workflow/sample.yml \
    -p "openstack_token=$(cat ./secrets/openstack_token.txt)" \
    -p "gitlab_token=$(cat ./secrets/gitlab_token.txt)" \
    -p "test_name=k8s-eos" \
    "$@"
