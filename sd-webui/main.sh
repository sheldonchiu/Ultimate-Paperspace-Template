#!/bin/bash
export MODEL_DIR="/tmp/stable-diffusion-models"
export REPO_DIR="/storage/stable-diffusion"
export WEBUI_DIR="$REPO_DIR/stable-diffusion-webui"

apt-get install -qq aria2 -y > /dev/null

pip install --upgrade pip
pip install --upgrade wheel setuptools
pip install requests gdown bs4
pip uninstall -y torch torchvision torchaudio protobuf lxml

bash prepare_repo.sh
python download_model.py

export PYTHONPATH="$PYTHONPATH:$WEBUI_DIR"
python preinstall.py

if [ -n "${ACTIVATE_XFORMERS}" ]; then
    pip install xformers==0.0.17rc482 triton==2.0.0
fi

bash start.sh