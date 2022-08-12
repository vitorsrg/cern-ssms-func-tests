#!/bin/bash

set -ex
pwd

source /mnt/gitlab-repo/src/script/openstack/setup_token.sh

while true; do
    status=$(openstack coe cluster show vsantaro-func-tests--test -f json | jq -r '.status')
    echo $status

    if [ "$status" = "CREATE_IN_PROGRESS" ]; then
        printf "Waiting cluster creation.\n"
        continue
    elif [ "$status" = "CREATE_COMPLETE" ]; then
        printf "Cluster is ready.\n"
        break
    else
        printf "Failed to create cluster.\n"
        exit -1
    fi

    sleep 10
done
