#!/bin/bash

if ! [ -e "/tmp/huggingface.prepared" ]; then
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/huggingface-env
    source /tmp/huggingface-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    pip install --upgrade huggingface_hub
    touch /tmp/huggingface.prepared
else
    source /tmp/huggingface-env/bin/activate
fi

current_dir=$(dirname "$(realpath "$0")")
python $current_dir/upload.py

bash $DISCORD_PATH "Command server started"