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
echo "### Setting up Stable Diffusion Comfy ###"
symlinks=(
    "$REPO_DIR:/notebooks/stable-diffusion-comfy"
    "/storage:/notebooks/storage"
    "$REPO_DIR/output:$IMAGE_OUTPUTS_DIR/stable-diffusion-comfy"
    "$MODEL_DIR:/notebooks/models"
)

TARGET_REPO_URL="https://github.com/comfyanonymous/ComfyUI.git" \
TARGET_REPO_DIR=$REPO_DIR \
UPDATE_REPO=$SD_COMFY_UPDATE_REPO \
UPDATE_REPO_COMMIT=$SD_COMFY_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"
if ! [[ -e "/tmp/sd_comfy.prepared" ]]; then
    
    python3.10 -m venv /tmp/sd_comfy-env
    source /tmp/sd_comfy-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    pip install xformers
    pip install torchvision torchaudio --no-deps
    pip install -r requirements.txt
    
    touch /tmp/sd_comfy.prepared
else
    
    source /tmp/sd_comfy-env/bin/activate
    
fi
echo "Finished Preparing Environment for Stable Diffusion Comfy"


echo "### Downloading Model for Stable Diffusion Comfy ###"
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
echo "Finished Downloading Models for Stable Diffusion Comfy"


echo "### Starting Stable Diffusion Comfy ###"
cd "$REPO_DIR"
nohup python main.py --dont-print-server > /tmp/{{ name }}.log 2>&1 &
echo $! > /tmp/{{ name }}.pid
echo "Stable Diffusion Comfy Started"
echo "### Done ###"