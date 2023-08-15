#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Stable Diffusion Fooocus ###"
log "Setting up Stable Diffusion Fooocus"
TARGET_REPO_URL="https://github.com/lllyasviel/Fooocus.git" \
TARGET_REPO_DIR=$REPO_DIR \
UPDATE_REPO=$SD_FOOOCUS_UPDATE_REPO \
UPDATE_REPO_COMMIT=$SD_FOOOCUS_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh 

symlinks=(
    "$REPO_DIR/outputs:$IMAGE_OUTPUTS_DIR/stable-diffusion-fooocus"
    "$MODEL_DIR:$WORKING_DIR/models"
    "$MODEL_DIR/sd:$LINK_MODEL_TO"
    "$MODEL_DIR/lora:$LINK_LORA_TO"
    "$MODEL_DIR/vae:$LINK_VAE_TO"
    "$MODEL_DIR/hypernetwork:$LINK_HYPERNETWORK_TO"
    "$MODEL_DIR/controlnet:$LINK_CONTROLNET_TO"
    "$MODEL_DIR/embedding:$LINK_EMBEDDING_TO"
)
bash $current_dir/../utils/prepare_link.sh  "${symlinks[@]}"
if ! [[ -e "/tmp/sd_fooocus.prepared" ]]; then
    
    
    python3.10 -m venv $VENV_DIR/sd_fooocus-env
    
    source $VENV_DIR/sd_fooocus-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    pip install -r requirements_versions.txt
    
    touch /tmp/sd_fooocus.prepared
else
    
    source $VENV_DIR/sd_fooocus-env/bin/activate
    
fi
log "Finished Preparing Environment for Stable Diffusion Fooocus"


echo "### Downloading Model for Stable Diffusion Fooocus ###"
log "Downloading Model for Stable Diffusion Fooocus"
bash $current_dir/../utils/sd_model_download/main.sh
log "Finished Downloading Models for Stable Diffusion Fooocus"


echo "### Starting Stable Diffusion Fooocus ###"
log "Starting Stable Diffusion Fooocus"
cd $REPO_DIR
GRADIO_ROOT_PATH="/sd_fooocus" python launch.py --port 7015

send_to_discord "Stable Diffusion Fooocus Started"

if env | grep -q "PAPERSPACE"; then
  send_to_discord "Link: https://$PAPERSPACE_FQDN/sd-fooocus/"
fi


if [[ -n "${CF_TOKEN}" ]]; then
  if [[ "$RUN_SCRIPT" != *"sd_fooocus"* ]]; then
    export RUN_SCRIPT="$RUN_SCRIPT,sd_fooocus"
  fi
  bash $current_dir/../cloudflare_reload.sh
fi

echo "### Done ###"