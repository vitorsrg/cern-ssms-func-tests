#!/bin/bash

################################################################################
#i  Maybe create and configure a cluster.
#ii
#ii
#ii Example:
#ii     bash "./src/script/manage/cern_login.sh"
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
#ii
#ii Outputs:
#ii     file    ./secrets/cern_keytab.krb
#ii     file    ./secrets/lxplus8_host.txt
#ii     file    ./secrets/openstack_token.txt
#ii     file    ./secrets/kubeconfig.yml
#ii
#ii Returns:
#ii     openstack_token
#ii     source_path
#ii     cluster_name
#ii     cluster_template
#ii     cluster_node_count
#ii     cluster_labels
#ii     may_create_cluster
#ii     may_fail_if_exists
################################################################################

set -ex
pwd

prev_path=$(pwd)
cd "$source_path"

source "./src/script/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"

mkdir -p "/root/output/"


cluster_exists="$(
    openstack coe cluster show \
        $cluster_name >&2 \
    || echo $?
)"

if [[ "$cluster_exists" -ne 0 ]]; then

    if [[ "$(util::parse_bool "$may_create_cluster")" = "true" ]]; then
        openstack coe cluster create \
            "$cluster_name" \
            --cluster-template "$cluster_template" \
            --node-count "$cluster_node_count" \
            --labels "$cluster_labels"

        printf \
            "true" \
            > "/root/output/created_cluster.txt"
    else
        util::log "Cluster doesn't exist and may not create one."
        exit -1
    fi

    if [[ "$(util::parse_bool $may_fail_if_exists)" = "true" ]]; then
        util::log "Cluster name already exists."
        exit -1
    fi
else
    printf \
        "false" \
        > "/root/output/created_cluster.txt"
fi

openstack coe cluster show \
    "$cluster_name" \
    -f json \
    | jq -jr '.uuid' \
    > "/root/output/cluster_uuid.txt"
