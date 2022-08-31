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

source "./src/script/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"
source "./src/script/openstack/setup_k8s.sh" \
    "$cluster_name" \
    "/root/kubeconfig.yml"

kubectl config set-context \
    --current \
    --namespace=default

################################################################################

cat "./src/k8s/sc/manila_ephemeral.yml" \
    | yq -Y \
        ".metadata.name += \"$run_suffix\"" \
    | kubectl apply \
        -f -
cat "./src/k8s/pvc/func_tests_src.yml"\
    | yq -Y \
        ".metadata.name += \"$run_suffix\"" \
    | yq -Y \
        ".spec.storageClassName += \"$run_suffix\"" \
    | kubectl apply \
        -f -
cat "./src/k8s/pod/func_tests_src_port.yml" \
    | yq -Y \
        ".metadata.name += \"$run_suffix\"" \
    | yq -Y \
        "(
            .. .claimName? // empty
            | select(. == \"func-tests-src\")
        ) += \"$run_suffix\"" \
    | kubectl apply \
        -f -

kubectl wait \
    --for=condition=ready \
    --timeout=300s \
    pod \
    "func-tests-src-port$run_suffix"


ls -1 \
    "$source_path/" \
    | xargs -I {} \
        kubectl cp \
            "$source_path/{}" \
            "func-tests-src-port$run_suffix:/mnt/func-tests-src/{}"

# TODO: remove this
ls "$source_path/"
kubectl exec \
     "func-tests-src-port$run_suffix" \
     -- \
     ls "/mnt/func-tests-src/"
