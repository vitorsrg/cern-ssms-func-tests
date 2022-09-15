#!/bin/bash

################################################################################
#i  ...
#ii
#ii Inputs:
#ii     env     source_path
################################################################################

set -ev
pwd

cd "$source_path"

source "./lib/util.sh"

set +v
set -x

sleep 10  # prevent pod from finishing too fast

################################################################################

util::log "This test always succeeds."
exit 0
