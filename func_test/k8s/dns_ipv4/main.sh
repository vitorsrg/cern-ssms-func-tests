#!/bin/bash

################################################################################
#i  ...
################################################################################

set -ex

sleep 10  # prevent pod from finishing too fast

################################################################################

# Check external DNS.
output=$(nslookup -timeout=10 -type=A gitlab.cern.ch)
# Errors from nslookup start with '**' or ';;'.
external_error=$(echo "$output" | grep -E '^\*\*|^;;' | head -n 1)
# Remove the '** ' or ';; ' prefix.
external_error="${external_error#\*\* }"
external_error="${external_error#;; }"

# Check internal DNS.
output=$(nslookup -timeout=10 -type=A kube-dns.kube-system.svc.cluster.local)
# Errors from nslookup start with '**' or ';;'.
internal_error=$(echo "$output" | grep -E '^\*\*|^;;' | head -n 1)
# Remove the '** ' or ';; ' prefix.
internal_error="${internal_error#\*\* }"
internal_error="${internal_error#;; }"

if [ -n "$external_error" ] && [ -n "$internal_error" ]; then
    echo "error: external and internal nslookups failed: ${external_error}, ${internal_error}"
    exit 1
fi

if [ -n "$external_error" ]; then
    echo "error: external nslookup failed: $external_error"
    exit 1
fi

if [ -n "$internal_error" ]; then
    echo "error: internal nslookup failed: $internal_error"
    exit 1
fi
