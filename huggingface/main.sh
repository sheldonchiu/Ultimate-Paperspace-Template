#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


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
echo "Finished Preparing Environment for HuggingFace Hub"



echo "### Starting HuggingFace Hub ###"
python $current_dir/upload.py
log "HuggingFace Hub Started"
echo "### Done ###"