#!/bin/bash

set -ex
pwd

source /mnt/gitlab-repo/src/script/openstack/setup_token.sh

mkdir -p /root/func-tests--test/
openstack coe cluster config \
    vsantaro-func-tests--test \
    --dir /root/func-tests--test/ \
    --force \
    || true

ls  /root/func-tests--test/

export KUBECONFIG="/root/func-tests--test/config"
kubectl config set-context --current --namespace=default

kubectl delete job "${test_name}" || true
kubectl apply -f "/mnt/gitlab-repo/src/job/${test_name}.yml"

while true; do
sleep 10
active=$(kubectl get job ${test_name} -o json | jq -jr '.status | has("active")')
succeeded=$(kubectl get job ${test_name} -o json | jq -jr '.status | has("succeeded")')

if [ "$active" = "true" ]; then
    printf "Waiting job to finish.\n"
    continue
elif [ "$succeeded" = "true" ]; then
    printf "Job succeeded.\n"
    kubectl logs "job/${test_name}"
    printf "success" > /root/test_result.txt
    break
else
    printf "Job failed.\n"
    kubectl logs "job/${test_name}"
    printf "failure" > /root/failure.txt
    exit -1
fi
done
