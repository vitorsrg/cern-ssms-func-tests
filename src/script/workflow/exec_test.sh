#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/exec_test.sh"
#ii
#ii Inputs:
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
#ii     env     test_name
#ii     env     test_key
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

pod_name="test-$test_key-${test_name//_/-}-$run_key"

mkdir -p "/root/output/"

################################################################################

cat "./src/k8s/test/$test_name.yml" \
    | yq -Y \
        ".metadata.name = \"$pod_name\"" \
    | yq -Y \
        "(
            .. .claimName? // empty 
            | select(. == \"func-tests-src\")
        ) += \"-$run_key\"" \
    | kubectl apply \
        -f -

sleep 10

kubectl describe pod "$pod_name"

kubectl wait \
    --for=condition=ready \
    --timeout=300s \
    pod \
    "$pod_name"

kubectl logs \
    "$pod_name" \
    --follow

################################################################################

kubectl get pod "$pod_name" -o json

succeeded=$(
    kubectl get job $pod_name -o json \
    | jq -jr '.status | has("succeeded")'
)


kubectl delete job \
    "$pod_name" \
    --force \
    --timeout=60s \
    || true

if util::eval_bool "$succeeded"; then
    util::log "Job succeeded."
    printf "success" > "/root/output/test_result.txt"
    # exit 0
else
    util::log "Job failed."
    printf "failure" > "/root/output/test_result.txt"
    # exit -1
fi

