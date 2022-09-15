#!/usr/bin/env bash

################################################################################
#i  Login to CERN lxplus8.
#ii
#ii Example:
#ii     bash "./src/manage/cern_login.sh"
#ii
#ii Inputs:
#ii     stdin   CERN SSO vsantaro password
#ii
#ii Outputs:
#ii     file    ./secrets/cern_keytab.krb
#ii     file    ./secrets/lxplus8_host.txt
#ii     file    ./secrets/openstack_token.txt
#ii     file    ./secrets/kubeconfig.yml
################################################################################

set -e

source "./src/helper/util.sh"

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
    | perl -0777 -e 'print <> =~ s/^.*? name pointer (.*?).\n/\1/gr' \
    > "./secrets/lxplus8_host.txt"

ssh \
    "vsantaro@$(cat "./secrets/lxplus8_host.txt")" \
    $(
        util::dedent '
            export OS_PROJECT_NAME="IT Cloud Infrastructure Developers";
            openstack token issue -f json;
            ' \
    ) \
    | jq -jr '.id' \
    > "./secrets/openstack_token.txt"

# source "./src/openstack/setup_krb.sh"
source "./src/openstack/setup_token.sh" \
    $(cat "./secrets/openstack_token.txt")

bash "./src/openstack/setup_k8s.sh" \
    "vsantaro-func-tests" \
    "./secrets/kubeconfig.yml"

################################################################################
# CERN harbor login
################################################################################

open https://registry.cern.ch/
