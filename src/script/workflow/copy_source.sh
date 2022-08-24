#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/copy_source.sh"
#ii
#ii Inputs:
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
source "./src/script/openstack/setup_k8s.sh" \
    "$cluster_name" \
    "/root/kubeconfig.yml"

kubectl apply \
    -f "./src/workflow/source_volume.yml" 

kubectl wait \
    --for=condition=ready \
    pod "func-tests-port"

kubectl cp \
    "$source_path" \
     "func-tests-port:/mnt/func-tests"
