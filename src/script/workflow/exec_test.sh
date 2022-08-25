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

job_name="test-$test_key-$test_name"

################################################################################

mkdir -p "/root/output/"

pip3 install yq

yq -Y \
    ".metadata.name = \"$job_name\"" \
    "./src/job/$test_name.yml" \
    | kubectl apply \
        -f -

while true; do
    sleep 10
    active=$(
        kubectl get job $job_name -o json \
        | jq -jr '.status | has("active")'
    )
    succeeded=$(
        kubectl get job $job_name -o json \
        | jq -jr '.status | has("succeeded")'
    )

    if util::eval_bool "$active"; then
        util::log "Waiting job to finish."
        continue
    elif util::eval_bool "$succeeded"; then
        util::log "Job succeeded."
        printf "success" > "/root/output/test_result.txt"
        break
    else
        util::log "Job failed."
        printf "failure" > "/root/output/test_result.txt"
        break
    fi
done


kubectl logs \
    "job/$job_name"

kubectl delete job \
    "$job_name" \
    --force \
    --timeout=60s \
    || true
