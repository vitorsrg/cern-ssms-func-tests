#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/workflow/wait_cluster_ready.sh"
#ii
#ii Inputs:
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
################################################################################

set -ev
pwd

cd "$source_path"

source "./lib/util.sh"
source "./src/openstack/setup_token.sh" \
    "$openstack_token"

set +v
set -x

################################################################################

while true; do
    status=$(
        openstack coe cluster show \
            "$cluster_name" \
            -f json \
            | jq -jr '.status'
    )

    if [ "$status" = "CREATE_IN_PROGRESS" ]; then
        util::log "Waiting cluster creation."
        continue
    elif [ "$status" = "CREATE_COMPLETE" ]; then
        util::log "Cluster is ready."
        break
    else
        util::log "Failed to create cluster."
        exit -1
    fi

    sleep 60
done
