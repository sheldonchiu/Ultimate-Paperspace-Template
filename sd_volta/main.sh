#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Stable Diffusion Volta ###"
log "Setting up Stable Diffusion Volta"
TARGET_REPO_URL="https://github.com/VoltaML/voltaML-fast-stable-diffusion.git" \
TARGET_REPO_DIR=$REPO_DIR \
TARGET_REPO_BRANCH=main \
UPDATE_REPO=$SD_VOLTA_UPDATE_REPO \
UPDATE_REPO_COMMIT=$SD_VOLTA_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh

symlinks=(
  "$REPO_DIR/outputs:$IMAGE_OUTPUTS_DIR/stable-diffusion-volta"
  "$OUTPUTS_DIR:$WORKING_DIR/storage"
  "$MODEL_DIR:$WORKING_DIR/models"
  "$MODEL_DIR/sd:$LINK_MODEL_TO"
  "$MODEL_DIR/lora:$LINK_LORA_TO"
)
bash $current_dir/../utils/prepare_link.sh "${symlinks[@]}"
if ! [[ -e "/tmp/sd_volta.prepared" ]]; then
    
    python3.10 -m venv /tmp/sd_volta-env
    source /tmp/sd_volta-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    python main.py --install-only

    pip install xformers
    
    touch /tmp/sd_volta.prepared
else
    
    source /tmp/sd_volta-env/bin/activate
    
fi
log "Finished Preparing Environment for Stable Diffusion Volta"


echo "### Downloading Model for Stable Diffusion Volta ###"
log "Downloading Model for Stable Diffusion Volta"
bash $current_dir/../utils/sd_model_download/main.sh
log "Finished Downloading Models for Stable Diffusion Volta"


echo "### Starting Stable Diffusion Volta ###"
log "Starting Stable Diffusion Volta"
cd "$REPO_DIR"
PYTHONUNBUFFERED=1 nohup python main.py --port SD_VOLTA_PORT ${EXTRA_SD_VOLTA_ARGS} > /tmp/log/sd_volta.log 2>&1 &
echo $! > /tmp/sd_volta.pid

send_to_discord "Stable Diffusion Volta Started"
echo "### Done ###"