#!/bin/bash

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/process_input.sh"
#ii
#ii Inputs:
#ii     env     source_path
#ii     env     test_names
#ii     env     max_test_count
################################################################################

set -ex
pwd

cd "$source_path"

source "./src/script/util.sh"

################################################################################

mkdir -p "/root/output/"

# export test_names='k8s_eos k8s_eos always_succeeds always_fails'
# export max_test_count=5
echo $test_names
echo $max_test_count

declare -a test_names_arr=(
    $(
        printf "%s" "${test_names[@]}" \
            | tr -c "[:lower:][:digit:]_" " "
    )
)
test_count_input="${#test_names_arr[@]}"
test_count=$((
    test_count_input > max_test_count ? max_test_count : test_count_input
))

for i in $(seq 0 $((test_count - 1))); do
    test_key="test_name_$(printf "%02d" $((i + 1)))"
    printf "${test_names_arr[i]}" \
        > "/root/output/$test_key.txt"
done

for i in $(seq $test_count $((max_test_count - 1))); do
    test_key="test_name_$(printf "%02d" $((i + 1)))"
    printf "null" \
        > "/root/output/$test_key.txt"
done