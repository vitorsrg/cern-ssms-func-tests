#!/usr/bin/env bash

################################################################################
#i  Configure OpenStack and Kubernetes local env.
#ii
#ii Example:
#ii     bash "./src/script/manage/dispatch_argo.sh"
#ii
#ii Inputs:
#ii     file    "./secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      setup_creds
################################################################################

set -e

export KUBECONFIG="./secrets/kubeconfig.yml"

./argo.bin \
    submit -n argo ./src/workflow/sample.yml \
    -p "openstack_token=$(cat ./secrets/openstack_token.txt)" \
    -p "gitlab_token=$(cat ./secrets/gitlab_token.txt)" \
    -p "test_name=k8s-eos"
