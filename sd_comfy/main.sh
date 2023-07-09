#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Stable Diffusion Comfy ###"
log "Setting up Stable Diffusion Comfy"

TARGET_REPO_URL="https://github.com/comfyanonymous/ComfyUI.git" \
TARGET_REPO_DIR=$REPO_DIR \
UPDATE_REPO=$SD_COMFY_UPDATE_REPO \
UPDATE_REPO_COMMIT=$SD_COMFY_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh 

symlinks=(
  "$REPO_DIR/output:$IMAGE_OUTPUTS_DIR/stable-diffusion-comfy"
  "$OUTPUTS_DIR:$WORKING_DIR/storage"
  "$MODEL_DIR:$WORKING_DIR/models"
  "$MODEL_DIR/sd:$LINK_MODEL_TO"
  "$MODEL_DIR/lora:$LINK_LORA_TO"
  "$MODEL_DIR/vae:$LINK_VAE_TO"
  "$MODEL_DIR/upscaler:$LINK_UPSCALER_TO"
  "$MODEL_DIR/controlnet:$LINK_CONTROLNET_TO"
  "$MODEL_DIR/embedding:$LINK_EMBEDDING_TO"
)
bash $current_dir/../utils/prepare_link.sh "${symlinks[@]}"
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
log "Finished Preparing Environment for Stable Diffusion Comfy"


echo "### Downloading Model for Stable Diffusion Comfy ###"
log "Downloading Model for Stable Diffusion Comfy"
bash $current_dir/../utils/sd_model_download/main.sh
log "Finished Downloading Models for Stable Diffusion Comfy"


echo "### Starting Stable Diffusion Comfy ###"
log "Starting Stable Diffusion Comfy"
cd "$REPO_DIR"
PYTHONUNBUFFERED=1 nohup python main.py --dont-print-server --port $SD_COMFY_PORT ${EXTRA_SD_COMFY_ARGS} > $LOG_DIR/sd_comfy.log 2>&1 &
echo $! > /tmp/sd_comfy.pid

send_to_discord "Stable Diffusion Comfy Started"

bash $current_dir/../cloudflare_reload.sh

echo "### Done ###"