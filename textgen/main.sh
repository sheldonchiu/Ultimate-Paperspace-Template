#!/bin/bash

current_dir=$(dirname "$(realpath "$0")")

# Install Python 3.10
if ! [ -e "/tmp/sd-volta.prepared" ]; then
    apt-get install -y python3.10 python3.10-dev python3.10-venv
    python3.10 -m venv /tmp/textgen-env
    source /tmp/textgen-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools


  
# bash $current_dir/../utils/model_download/main.sh
# python $current_dir/../utils/model_download/link_model.py


# cd "$REPO_DIR"
# nohup python main.py > /tmp/sd-volta.log 2>&1 &
# echo $! > /tmp/sd-volta.pid