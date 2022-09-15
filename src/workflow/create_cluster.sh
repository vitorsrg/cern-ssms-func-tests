#!/bin/bash

################################################################################
#i  Maybe create and configure a cluster.
#ii
#ii
#ii Example:
#ii     bash "./src/workflow/create_cluster.sh"
#ii
#ii Inputs:
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
#ii     env     cluster_template
#ii     env     cluster_node_count
#ii     env     cluster_labels_json
#ii     env     may_create_cluster
#ii     env     may_fail_if_exists
#ii
#ii Outputs:
#ii     file    /root/output/has_created_cluster.txt
#ii     file    /root/output/cluster_uuid.txt
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/helper/util.sh"
source "./src/openstack/setup_token.sh" \
    "$openstack_token"

################################################################################

mkdir -p "/root/output/"

cluster_exists=$((
    ! $(
        util::status \
            openstack coe cluster show \
                "$cluster_name" \
                2> "/dev/null"
    )
))

if ! util::eval_bool "$cluster_exists"; then

    if util::eval_bool "$may_create_cluster"; then
        declare -a cluster_labels_args=(
            $(
                echo "$cluster_labels_json" \
                | jq -c '
                    .
                    | to_entries
                    | map(["--labels", .key + "=" + .value])
                    | flatten
                    | .[]' \
                | perl -pe 's/^"(.*?)"$/\1/g'
            )
        )

        openstack coe cluster create \
            "$cluster_name" \
            --cluster-template "$cluster_template" \
            --node-count "$cluster_node_count" \
            "${cluster_labels_args[@]}" \
            --merge-labels

        printf "true" \
            > "/root/output/has_created_cluster.txt"
    else
        util::log "Cluster doesn't exist and may not create one."
        exit -1
    fi

    if util::eval_bool "$may_fail_if_exists"; then
        util::log "Cluster name already exists."
        exit -1
    fi
else
    printf "false" \
        > "/root/output/has_created_cluster.txt"
fi

openstack coe cluster show \
    "$cluster_name" \
    -f json \
    | jq -jr '.uuid' \
    > "/root/output/cluster_uuid.txt"
