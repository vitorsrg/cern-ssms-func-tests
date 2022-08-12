#!/bin/bash

set -ex

pwd

source /mnt/gitlab-repo/src/script/openstack/setup_token.sh

cluster_exists="$(openstack coe cluster show vsantaro-func-tests--test >&2 || echo $?)"
if [[ "$cluster_exists" -ne 0 ]]; then
    openstack coe cluster create \
        vsantaro-func-tests--test \
        --cluster-template kubernetes-1.22.9-1 \
        --node-count 2
fi
