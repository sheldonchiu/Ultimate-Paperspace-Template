#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

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

python $current_dir/upload.py

bash $DISCORD_PATH "Files uploaded to HuggingFace Hub"