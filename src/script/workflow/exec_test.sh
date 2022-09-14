#!/bin/bash

################################################################################
#i  ...
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/exec_test.sh"
#ii
#ii Inputs:
#ii     env     run_suffix
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
#ii     env     test_name
#ii     env     test_key
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

pod_suffix=$(
    cat /dev/urandom \
        | base64 \
        | tr -cd '[:lower:][:digit:]' \
        | head -c 4 \
        | xargs -i printf '-%s' {}
)

pod_name="test-$test_key-${test_name//_/-}$run_suffix$pod_suffix"
test_prefix="test-$test_key-${test_name//_/-}$run_suffix"

mkdir -p "/root/output/"

################################################################################

bash "./src/scenario/controller/$test_name.sh"
exit_code="$!"

################################################################################

if [[ "$exit_code" == "0" ]]; then
    util::log "Test succeeded."
else
    util::log "Test failed."
fi

printf "$exit_code" \
    > "/root/output/exit_code.txt"
