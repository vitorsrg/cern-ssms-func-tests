#!/usr/bin/env bash

set -ex

export OS_AUTH_URL="https://keystone.cern.ch/v3"
export OS_REGION_NAME="cern"
export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"
export OS_PROJECT_DOMAIN_ID="default"

export OS_USERNAME="vsantaro"

export OS_PROTOCOL="kerberos"
export OS_MUTUAL_AUTH="disabled"
export OS_INTERFACE="public"
export OS_AUTH_TYPE="v3fedkerb"
export OS_IDENTITY_PROVIDER="sssd"
export OS_VOLUME_API_VERSION="2"
export OS_IDENTITY_API_VERSION="3"
