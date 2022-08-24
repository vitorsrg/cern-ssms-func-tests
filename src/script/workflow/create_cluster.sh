#!/bin/bash

################################################################################
#i  Maybe create and configure a cluster.
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/create_cluster.sh"
#ii
#ii Inputs:
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
#ii     env     cluster_template
#ii     env     cluster_node_count
#ii     env     cluster_labels
#ii     env     may_create_cluster
#ii     env     may_fail_if_exists
#ii     # TODO: env should_wait_cluster_ready
#ii
#ii Outputs:
#ii     file    /root/output/has_created_cluster.txt
#ii     file    /root/output/cluster_uuid.txt
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/script/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"

mkdir -p "/root/output/"

cluster_exists=!$(
    openstack coe cluster show \
        "$cluster_name" \
        2>&1 > /dev/null \
    || printf "$?"
)

if ! util::eval_bool "$cluster_exists"; then

    if util::eval_bool "$may_create_cluster"; then
        openstack coe cluster create \
            "$cluster_name" \
            --cluster-template "$cluster_template" \
            --node-count "$cluster_node_count" \
            --labels "$cluster_labels"

        printf \
            "true" \
            > "/root/output/have_created_cluster.txt"
    else
        util::log "Cluster doesn't exist and may not create one."
        exit -1
    fi

    if util::eval_bool "$may_fail_if_exists"; then
        util::log "Cluster name already exists."
        exit -1
    fi
else
    printf \
        "false" \
        > "/root/output/have_created_cluster.txt"
fi

openstack coe cluster show \
    "$cluster_name" \
    -f json \
    | jq -jr '.uuid' \
    > "/root/output/cluster_uuid.txt"

################################################################################
# Wait cluster to be ready
################################################################################

while true; do
    status=$(
        openstack coe cluster show \
            "$cluster_name" \
            -f json \
            | jq -jr '.status'
    )

    if [[ "$status" == "CREATE_IN_PROGRESS" ]]; then
        printf "Waiting cluster creation.\n"
        continue
    elif [[ "$status" == "CREATE_COMPLETE" ]]; then
        printf "Cluster is ready.\n"
        break
    else
        printf "Failed to create cluster.\n"
        exit -1
    fi

    sleep 10
done
