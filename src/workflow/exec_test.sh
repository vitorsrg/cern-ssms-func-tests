#!/bin/bash

################################################################################
#i  ...
#ii
#ii
#ii Example:
#ii     bash "./src/workflow/exec_test.sh"
#ii
#ii Inputs:
#ii     env     run_suffix
#ii     env     openstack_token
#ii     env     cluster_name
#ii     env     test_name
#ii     env     test_key
################################################################################

set -ev

source "./lib/util.sh"
source "./src/openstack/setup_token.sh" \
    "$openstack_token"
source "./src/openstack/setup_k8s.sh" \
    "$cluster_name" \
    "/root/kubeconfig.yml"

set +v -x

kubectl config set-context \
    --current \
    --namespace=default

export test_prefix="test-$test_key-${test_name//[\/_]/-}$run_suffix"

mkdir -p "/root/output/"

################################################################################

exit_code=$(
    util::status \
        bash "./func_test/${test_name//__/\/}/controller.sh"
)

################################################################################

if [[ "$exit_code" == "0" ]]; then
    util::log "Test succeeded."
else
    util::log "Test failed."
fi

printf "$exit_code" \
    > "/root/output/exit_code.txt"
