#!/usr/bin/env bash

################################################################################
#i  Save kubeconfig to file.
#ii
#ii Example:
#ii     bash "./src/openstack/setup_k8s.sh" \
#ii         "vsantaro-func-tests" \
#ii         "./.secrets/kubeconfig.yml"
#ii
#u  Usage:
#u      setup_k8s <cluster_name> <kubeconfig_path>
################################################################################

cluster_name="$1"
kubeconfig_path="$2"
tmpdir=$(mktemp -d)

openstack coe cluster config \
    "$cluster_name" \
    --dir "$tmpdir" \
    --force \
    || true  # TODO: revisit this
mv \
    "$tmpdir/config" \
    "$2"
export KUBECONFIG="$2"
