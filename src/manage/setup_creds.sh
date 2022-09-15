#!/usr/bin/env bash

################################################################################
#i  Configure OpenStack and Kubernetes local env.
#ii
#ii Example:
#ii     source "./src/manage/setup_creds.sh"
#ii
#ii Inputs:
#ii     file    "./.secrets/openstack_token.txt"
#ii     file    "./.secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      setup_creds
################################################################################

set -ev

source "./src/openstack/setup_token.sh" \
    $(cat "./.secrets/openstack_token.txt")

set +v
set -x

export KUBECONFIG="./.secrets/kubeconfig.yml"
