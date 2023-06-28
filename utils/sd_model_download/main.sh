#!/bin/bash

if ! dpkg -s aria2 >/dev/null 2>&1; then
    apt-get install -qq aria2 -y > /dev/null
fi

MODULES=("requests" "gdown" "bs4")
# Loop through the modules and check if they are installed
for module in "${MODULES[@]}"; do
    if ! pip show $module >/dev/null 2>&1; then
        # Module is not installed, install it with pip
        echo "Module $module is not installed. Installing it now..."
        pip install $module
    fi
done

python $(dirname "$(realpath "$0")")/download_model.py