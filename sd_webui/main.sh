#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Stable Diffusion WebUI ###"
log "Setting up Stable Diffusion WebUI"
symlinks=(
    "$REPO_DIR/outputs:$IMAGE_OUTPUTS_DIR/stable-diffusion-webui"
    "$REPO_DIR/log:$REPO_DIR/outputs/log"
    "$OUTPUTS_DIR:$WORKING_DIR/storage"
    "$MODEL_DIR:$WORKING_DIR/models"
)
TARGET_REPO_URL="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" \
TARGET_REPO_DIR=$REPO_DIR \
UPDATE_REPO=$SD_WEBUI_UPDATE_REPO \
UPDATE_REPO_COMMIT=$SD_WEBUI_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"

# git clone extensions that has their own model folder
if [[ ! -d "${REPO_DIR}/extensions/sd-webui-controlnet" ]]; then
    git clone https://github.com/Mikubill/sd-webui-controlnet.git "${REPO_DIR}/extensions/sd-webui-controlnet"
fi
if [[ ! -d "${REPO_DIR}/extensions/sd-webui-additional-networks" ]]; then
    git clone https://github.com/kohya-ss/sd-webui-additional-networks.git  "${REPO_DIR}/extensions/sd-webui-additional-networks"
fi
if ! [[ -e "/tmp/sd_webui.prepared" ]]; then
    
    python3.10 -m venv /tmp/sd_webui-env
    source /tmp/sd_webui-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    # fix install issue with pycairo, which is needed by sd-webui-controlnet
    apt-get install -y libcairo2-dev libjpeg-dev libgif-dev
    pip uninstall -y torch torchvision torchaudio protobuf lxml

    export PYTHONPATH="$PYTHONPATH:$REPO_DIR"
    # must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
    cd $REPO_DIR
    python $current_dir/preinstall.py
    cd $current_dir

    pip install xformers
    
    touch /tmp/sd_webui.prepared
else
    
    source /tmp/sd_webui-env/bin/activate
    
fi
log "Finished Preparing Environment for Stable Diffusion WebUI"


echo "### Downloading Model for Stable Diffusion WebUI ###"
log "Downloading Model for Stable Diffusion WebUI"
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
log "Finished Downloading Models for Stable Diffusion WebUI"


echo "### Starting Stable Diffusion WebUI ###"
log "Starting Stable Diffusion WebUI"
bash start.sh

send_to_discord "Stable Diffusion WebUI Started"
echo "### Done ###"