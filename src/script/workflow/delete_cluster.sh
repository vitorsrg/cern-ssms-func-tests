#!/bin/bash

################################################################################
#i  Maybe delete the test cluster.
#ii
#ii
#ii Example:
#ii     bash "./src/script/manage/cern_login.sh"
#ii
#ii Inputs:
#ii     env     openstack_token
#ii     env     source_path
#ii     env     cluster_name
#ii     env     has_created_cluster
#ii     env     should_delete_existing_cluster
#ii     # TODO: env may_delete_cluster
#ii
#ii Outputs:
#ii     file    /root/output/has_deleted_cluster.txt
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/script/util.sh"
source "./src/script/openstack/setup_token.sh" \
    "$openstack_token"

mkdir -p "/root/output/"

if \
    util::eval_bool "$has_created_cluster" \
    || util::eval_bool "$should_delete_existing_cluster"
then
    openstack coe cluster delete \
        "$cluster_name"

    printf \
        "true" \
        > "/root/output/has_deleted_cluster.txt"
else
    printf \
        "false" \
        > "/root/output/has_deleted_cluster.txt"
fi

