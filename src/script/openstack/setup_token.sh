#!/usr/bin/env bash

export OS_AUTH_URL="https://keystone.cern.ch/v3"
export OS_REGION_NAME="cern"
export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"
export OS_PROJECT_DOMAIN_ID="default"

export OS_USERNAME="vsantaro"

if [ "$#" -gt 0 ]; then
    export OS_TOKEN="$1"
fi

export OS_AUTH_TYPE="token"
export OS_VOLUME_API_VERSION="2"
export OS_IDENTITY_API_VERSION="3"
