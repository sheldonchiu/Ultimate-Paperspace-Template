#!/bin/bash

current_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cd $current_dir/..
# Loop through all folders in the current directory
for folder in */; do
    # Check if template.py exists in the current folder
    if [[ -f "${folder}template.yaml" ]]; then
        # Run python template.py in the current folder
        cd "${folder}"
        echo "Generating files for ${folder}"
        python3 ../template/template.py --yaml_file template.yaml --output_path ./
        cd ..
    fi
done

cd $current_dir
python3 nginx.py