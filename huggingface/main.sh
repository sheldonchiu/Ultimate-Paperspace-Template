#!/bin/bash
set -e

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

echo "### Setting up HuggingFace Hub ###"
if ! [[ -e "/tmp/huggingface.prepared" ]]; then
    python3.10 -m venv /tmp/huggingface-env
    source /tmp/huggingface-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    pip install --upgrade huggingface_hub
    touch /tmp/huggingface.prepared
else
    source /tmp/huggingface-env/bin/activate
fi

echo "### Starting uploading to HuggingFace Hub ###"
python $current_dir/upload.py

echo "### Done ###"