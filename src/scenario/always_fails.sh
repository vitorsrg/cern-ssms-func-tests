#!/bin/bash

################################################################################
#i  ...
#ii
#ii Inputs:
#ii     env     source_path
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/helper/util.sh"

sleep 10  # prevent pod from finishing too fast

################################################################################

util::log "This test always fails."
exit -1
