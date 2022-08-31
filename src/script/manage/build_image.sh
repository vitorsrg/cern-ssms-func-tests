#!/usr/bin/env bash

################################################################################
#i  Build and push func-tests image.
#ii
#ii Example:
#ii     bash "./src/script/manage/cern_login.sh"
#ii
#ii Inputs:
#ii     file    ./secrets/harbor_token.txt
#ii
#ii Outputs:
#ii     image   registry.cern.ch/vsantaro/func-tests
################################################################################

set -ex

docker build \
    -t registry.cern.ch/vsantaro/func-tests \
    --squash \
    ./docker_image
cat ./secrets/harbor_token.txt \
    | docker login \
        registry.cern.ch \
        --username vsantaro \
        --password-stdin
docker push \
    registry.cern.ch/vsantaro/func-tests
