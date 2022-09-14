#!/usr/bin/env bash

################################################################################
#i  Configure OpenStack and Kubernetes local env.
#ii
#ii Example:
#ii     bash "./src/script/manage/dispatch_argo.sh"
#ii     bash "./src/script/manage/dispatch_argo.sh" --watch
#ii     bash "./src/script/manage/dispatch_argo.sh" --log
#ii
#ii Inputs:
#ii     file    "./secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      setup_creds
################################################################################

set -ex

source "./src/script/util.sh"

export KUBECONFIG="./secrets/kubeconfig.yml"

run_suffix=$(
    cat /dev/urandom \
        | base64 \
        | tr -cd '[:lower:][:digit:]' \
        | head -c 4 \
        | xargs -i printf '-%s' {}
)

################################################################################

# NOTE: convenience for quick testing
# TODO: remove this
git add -A
git commit -S -a -m 'fixup' || true
git push gitlab HEAD:vitorsrg

################################################################################

bash "./src/script/manage/render_src_cm.sh"

cat "./data/func_tests_src.yml" \
    | yq -Y \
        ".metadata.name += \"$run_suffix\"" \
    | kubectl apply \
        -f -

################################################################################

kubectl apply \
    -f "./src/k8s/sc/manila_ephemeral.yml"

./argo.bin \
    submit \
    <(
        cat "./src/k8s/wf/func_tests.yml" \
            | yq -Y \
                ".metadata.name += \"$run_suffix\"" \
            | yq -Y \
                "(
                    .spec.volumes[]
                    | select(.name == \"func-tests-src\")
                    | .configMap.items
                ) = input.configMap.items" \
                - \
                <(yq "." "./data/func_tests_mount.yml") \
            | yq -Y \
                "(
                    .. .configMap?.name? // empty
                    | select(. == \"func-tests-src\")
                ) += \"$run_suffix\"" \
    ) \
    -p "openstack_token=$(cat ./secrets/openstack_token.txt)" \
    -p "gitlab_token=$(cat ./secrets/gitlab_token.txt)" \
    -p "test_name=k8s-eos" \
    -p "test_names=k8s_eos always_succeeds,always_fails" \
    -p "run_suffix=$run_suffix" \
    "$@"

kubectl get wf \
    "func-tests$run_suffix" \
    -o json \
    | jq -jr \
        '
        .status.nodes
        | to_entries
        | map(.value)
        | map(select(.templateName == "exec-test"))
        | map(
            {
                test_key: (
                    try (
                        .inputs.parameters
                        | map(select(.name == "test_key"))
                        | first
                        | .value
                    )
                    // null
                ),
                test_name: (
                    try (
                        .inputs.parameters
                        | map(select(.name == "test_name"))
                        | first
                        | .value
                    )
                    // null
                ),
                exit_code: (
                    try (
                        .outputs.parameters
                        | map(select(.name == "exit_code"))
                        | first
                        | .value
                    )
                    // null
                )
            }
        )
        | map(select(.test_key != null))
        | sort_by(.test_key)
        '

################################################################################

kubectl delete cm \
    "func-tests-src$run_suffix" \
    --force \
    --timeout=60s \
    || true
