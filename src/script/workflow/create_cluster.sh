#!/bin/bash

################################################################################
# Maybe create and configure a cluster.
# Globals (in):
#   openstack_token
#   source_path
#   cluster_name
#   cluster_template
#   cluster_node_count
#   cluster_labels
#   may_create_cluster
#   may_fail_if_exists
################################################################################

set -ex
pwd

prev_path=$(pwd)
cd $source_path

source "$source_path/src/script/util.sh"
source "$source_path/src/script/openstack/setup_token.sh" $openstack_token


cluster_exists="$(
    openstack coe cluster show \
        $cluster_name >&2 \
    || echo $?
)"
if [[ "$cluster_exists" -ne 0 ]]; then

    if [[ "$(util::parse_bool $may_create_cluster)" = "true" ]]; then
        openstack coe cluster create \
            $cluster_name \
            --cluster-template $cluster_template \
            --node-count $cluster_node_count \
            --labels $cluster_labels
    else
        util::log "Cluster doesn't exist and may not create one."
        exit -1
    fi

    if [[ "$(util::parse_bool $may_fail_if_exists)" = "true" ]]; then
        util::log "Cluster name already exists."
        exit -1
    fi
fi
