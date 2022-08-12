#!/bin/bash

set -ex
pwd

source /mnt/gitlab-repo/src/script/openstack/setup_token.sh

openstack coe cluster delete \
    vsantaro-func-tests--test
