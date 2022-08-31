#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/copy_source.sh"
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

yq -Y \
    ".metadata.name += \"-$run_key\"" \
    "./src/k8s/sc/manila_ephemeral.yml" \
    | kubectl apply \
        -f -
yq -Y \
    ".metadata.name += \"-$run_key\"" \
    "./src/k8s/pvc/func_tests_src.yml" \
    | kubectl apply \
        -f -
yq -Y \
    ".metadata.name += \"-$run_key\"" \
    "./src/k8s/pod/func_tests_src_port.yml" \
    | kubectl apply \
        -f -

kubectl wait \
    --for=condition=Ready \
    --timeout=300s \
    pod "func-tests-src-port-$run_key"

# TODO: remove this
# kubectl exec \
#      "func-tests-src-port" \
#      -- \
#      sh -c 'rm -rf /tmp/test'
kubectl cp \
    "$source_path" \
     "func-tests-src-port:/mnt/func-tests"
