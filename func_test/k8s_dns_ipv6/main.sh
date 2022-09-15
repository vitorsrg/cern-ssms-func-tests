#!/bin/bash

################################################################################
#i  ...
################################################################################

set -ex

sleep 10  # prevent pod from finishing too fast

################################################################################

# Check external IPv6 DNS.
output=$(nslookup -timeout=10 -type=AAAA gitlab.cern.ch)
# Errors from nslookup start with '**' or ';;'.
external_error_ipv6=$(echo "$output" | grep -E '^\*\*|^;;' | head -n 1)
# Remove the '** ' or ';; ' prefix.
external_error_ipv6="${external_error_ipv6#\*\* }"
external_error_ipv6="${external_error_ipv6#;; }"

# Check internal IPv6 DNS.
output=$(nslookup -timeout=10 -type=AAAA kube-dns.kube-system.svc.cluster.local)
# Errors from nslookup start with '**' or ';;'.
internal_error_ipv6=$(echo "$output" | grep -E '^\*\*|^;;' | head -n 1)
# Remove the '** ' or ';; ' prefix.
internal_error_ipv6="${internal_error_ipv6#\*\* }"
internal_error_ipv6="${internal_error_ipv6#;; }"

server_version=$(kubectl version -ojson | jq '.serverVersion.minor' --raw-output)
if [ $server_version -ge 22 ]; then
    if [ -n "$external_error_ipv6" ] && [ -n "$internal_error_ipv6" ]; then
    echo "error: external and internal ipv6 nslookups failed: ${external_error_ipv6}, ${internal_error_ipv6}"
    exit 1
    fi

    if [ -n "$external_error_ipv6" ]; then
    echo "error: external ipv6 nslookup failed: $external_error_ipv6"
    exit 1
    fi

    if [ -n "$internal_error_ipv6" ]; then
    echo "error: internal ipv6 nslookup failed: $internal_error_ipv6"
    exit 1
    fi
fi
