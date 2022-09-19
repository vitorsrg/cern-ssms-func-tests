#!/usr/bin/env bash

################################################################################
#i  Configure OpenStack and Kubernetes local env.
#ii
#ii Example:
#ii     bash "./src/manage/dispatch.sh" \
#ii         "./func_test/k8s/dns_ipv6/scenario.yml"
#ii     bash "./src/manage/dispatch.sh" \
#ii         "./func_test/k8s/dns_ipv6/scenario.yml" \
#ii         --watch
#ii     bash "./src/manage/dispatch.sh" \
#ii         "./func_test/k8s/dns_ipv6/scenario.yml" \
#ii         --log
#ii
#ii Inputs:
#ii     file    "./.secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      dispatch workflow [...]
################################################################################

set -ev

source "./lib/k8s.sh"
source "./lib/util.sh"

set +v -x

export KUBECONFIG="./.secrets/kubeconfig.yml"

run_suffix=$(k8s::random 4)

################################################################################

# NOTE: convenience for quick testing
# TODO: remove this
git add -A
git commit -S -a -m 'fixup' || true
git push origin HEAD

################################################################################

echo "$1"
echo "${@:2}"

yq -Y -jn \
    'reduce inputs as $xi ({}; . * $xi)' \
    "$1" \
    "./resource/scenario/default.yml"

# ./bin/argo.bin submit \
#     <(
#         cat "./resource/k8s/wf/func_tests.yml" \
#             | yq -Y \
#                 ".metadata.name += \"$run_suffix\""
#     ) \
#     -p "openstack_token=$(cat ./.secrets/openstack_token.txt)" \
#     -p "gitlab_token=$(cat ./.secrets/gitlab_token.txt)" \
#     -p "test_names=misc__always_fails misc__always_succeeds k8s__dns_ipv4 k8s__dns_ipv6 k8s__eos" \
#     -p "run_suffix=$run_suffix" \
#     "$@"

# kubectl get wf \
#     "func-tests$run_suffix" \
#     -o json \
#     | jq -jr \
#         '
#         .status.nodes
#         | to_entries
#         | map(.value)
#         | map(select(.templateName == "exec-test"))
#         | map(
#             {
#                 test_key: (
#                     try (
#                         .inputs.parameters
#                         | map(select(.name == "test_key"))
#                         | first
#                         | .value
#                     )
#                     // null
#                 ),
#                 test_name: (
#                     try (
#                         .inputs.parameters
#                         | map(select(.name == "test_name"))
#                         | first
#                         | .value
#                     )
#                     // null
#                 ),
#                 exit_code: (
#                     try (
#                         .outputs.parameters
#                         | map(select(.name == "exit_code"))
#                         | first
#                         | .value
#                     )
#                     // null
#                 )
#             }
#         )
#         | map(select(.test_key != null))
#         | sort_by(.test_key)
#         '
