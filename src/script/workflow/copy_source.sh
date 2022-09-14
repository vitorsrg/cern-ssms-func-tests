#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/copy_source.sh"
#ii
#ii Inputs:
#ii     env     run_suffix
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/script/helper/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"
source "./src/script/openstack/setup_k8s.sh" \
    "$cluster_name" \
    "/root/kubeconfig.yml"

kubectl config set-context \
    --current \
    --namespace=default

################################################################################

cat "./data/func_tests_src.yml" \
    | yq -Y \
        ".metadata.name += \"$run_suffix\"" \
    | kubectl apply \
        -f -
