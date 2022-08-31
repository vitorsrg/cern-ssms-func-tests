#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/clean_source.sh"
#ii
#ii Inputs:
#ii     env     run_key
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/script/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"
bash "./src/script/openstack/setup_k8s.sh" \
    "$cluster_name" \
    "/root/kubeconfig.yml"
export KUBECONFIG="/root/kubeconfig.yml"

kubectl config set-context \
    --current \
    --namespace=default

################################################################################

kubectl delete pod \
    "func-tests-src-port-$run_key" \
    --force \
    --timeout=60s \
    || true
kubectl delete pvc \
    "func-tests-src-$run_key" \
    --force \
    --timeout=60s \
    || true
kubectl delete sc \
    "manila-ephemeral-$run_key" \
    --force \
    --timeout=60s \
    || true