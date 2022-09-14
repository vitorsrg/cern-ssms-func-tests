#!/bin/bash

################################################################################
#i  Process workflow input so it can be used by the tasks.
#ii
#ii
#ii Example:
#ii     bash "./src/script/manage/render_src_cm.sh"
#ii
#ii Inputs:
#ii     file    "./src/k8s/cm/func_tests_src.yml"
#ii
#ii Outputs:
#ii     file    "./data/func_tests_src.yml"
################################################################################

set -ex

source "./src/script/util.sh"

################################################################################

cp -f \
    "./src/k8s/cm/func_tests_src.yml" \
    "./data/func_tests_src.yml"

git ls-tree \
    -r HEAD --name-only \
    | while read relpath; do
    yq -Y \
        --arg key "$relpath" \
        --arg val "$(cat $relpath)" \
        ".data[\$key] = \$val" \
        "./data/func_tests_src.yml" \
        > "./data/func_tests_src.yml.tmp"
    mv -f \
        "./data/func_tests_src.yml.tmp" \
        "./data/func_tests_src.yml"
done

################################################################################


cp -f \
    "./src/k8s/cm/func_tests_mount.yml" \
    "./data/func_tests_mount.yml"

git ls-tree \
    -r HEAD --name-only \
    | while read relpath; do
    yq -Y \
        --arg relpath "$relpath" \
        ".configMap.items |= . + [{\"key\": \$relpath, \"path\": \$relpath}]" \
        "./data/func_tests_mount.yml" \
        > "./data/func_tests_mount.yml.tmp"
    mv -f \
        "./data/func_tests_mount.yml.tmp" \
        "./data/func_tests_mount.yml"
done
