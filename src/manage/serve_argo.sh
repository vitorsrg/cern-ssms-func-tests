#!/usr/bin/env bash

################################################################################
#i  Configure OpenStack and Kubernetes local env.
#ii
#ii Example:
#ii     bash "./src/manage/serve_argo.sh"
#ii
#ii Inputs:
#ii     file    "./.secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      serve_argo
################################################################################

set -ev

source "./lib/util.sh"

set +v -x

export KUBECONFIG="./.secrets/kubeconfig.yml"

################################################################################

kubectl port-forward \
    deployment/argo-server \
    2746:2746
