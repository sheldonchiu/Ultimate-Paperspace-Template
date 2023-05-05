#!/bin/bash
cd ..
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