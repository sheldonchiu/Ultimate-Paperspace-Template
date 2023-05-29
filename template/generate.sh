#!/bin/bash

current_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cd $current_dir/..
# Loop through all folders in the current directory
for folder in */; do
    # Check if template.py exists in the current folder
    if [[ -f "${folder}template.py" ]]; then
        # Run python template.py in the current folder
        cd "${folder}"
        python template.py
        cd ..
    fi
done