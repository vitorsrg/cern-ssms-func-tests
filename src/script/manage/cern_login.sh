#!/usr/bin/env bash

################################################################################
#i  Login to CERN lxplus8.
#ii
#ii
#ii Example:
#ii     bash "./src/script/manage/cern_login.sh"
#ii
#ii Inputs:
#ii     stdin   CERN SSO vsantaro password
#ii
#ii Outputs:
#ii     file    ./secrets/cern_keytab.krb
#ii     file    ./secrets/lxplus8_host.txt
#ii     file    ./secrets/openstack_token.txt
#ii     file    ./secrets/kubeconfig.yml
###
### Returns:
##?     openstack_token
##?     source_path
##?     cluster_name
##?     cluster_template
##?     cluster_node_count
##?     cluster_labels
##?     may_create_cluster
##?     may_fail_if_exists
##?       --help     Show help options.
##?       --version  Print program version.
#?  release 0.0.0
#?  license...
################################################################################

set -e

################################################################################
# CERN kerberos login
################################################################################

kdestroy -A
rm -rf "./secrets/cern_keytab.krb"

read -s -p "Password: " cern_password
printf "\n"
ktutil \
    -k "./secrets/cern_keytab.krb" \
    add \
        -p "vsantaro@CERN.CH" \
        -e arcfour-hmac-md5 \
        --password=$cern_password \
        -V 3 \
        --no-salt

kinit \
    --afslog -f -kt \
    "./secrets/cern_keytab.krb" \
    "vsantaro@CERN.CH"
klist -Af

################################################################################
# Fetch tokens
################################################################################

ssh \
    "vsantaro@lxplus8.cern.ch" \
    "hostname -I" \
    | awk '{print $1}' \
    | xargs -I {} host {} \
    | perl -0777 -e 'print <> =~ s/b/d/gr' \
    > "./secrets/lxplus8_host.txt"

ssh \
    "vsantaro@$(cat lxplus8_host.txt)" \
    <(
        util::dedent '
            export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"
            openstack token issue -f json
            ' \
    ) \
    | jq -r '.id' \
    > "./secrets/openstack_token.txt"

source "./src/script/openstack/setup_krb.sh"

bash "./src/openstack/setup_k8s.sh" \
    "vsantaro-func-tests" \
    "./secrets/kubeconfig.yml"

################################################################################
# CERN harbor login
################################################################################

open https://registry.cern.ch/
