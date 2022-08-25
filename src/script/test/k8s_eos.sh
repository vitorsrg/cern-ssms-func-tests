#!/bin/bash

sleep 15

ls_output=$(ls /eos 2>&1)
if [ $? -ne 0 ]; then
    echo "error: $ls_output"
    exit 1
fi

ls_output=$(ls /eos/user 2>&1)
if [ $? -ne 0 ]; then
    echo "error: $ls_output"
    exit 1
fi

n=$(ls /eos/user | wc  -l)
if [ $n -ne 26 ]; then
    echo "Error: wrong number of subdirectories in /eos/user, expected 26 but found ${n}."
    exit 1
fi

echo "done"