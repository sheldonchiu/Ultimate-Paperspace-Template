#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Stable Diffusion InvokeAI ###"
log "Setting up Stable Diffusion InvokeAI"
mkdir -p $DATA_DIR/sd_invoke_models
mkdir -p $INVOKEAI_ROOT/models

symlinks=(
  "$REPO_DIR/outputs:$IMAGE_OUTPUTS_DIR/stable-diffusion-invokeai"
  "$MODEL_DIR:$WORKING_DIR/models"
  "$MODEL_DIR/sd:$LINK_MODEL_TO"
  "$MODEL_DIR/lora:$LINK_LORA_TO"
  "$MODEL_DIR/controlnet:$LINK_CONTROLNET_TO"
  "$MODEL_DIR/embedding:$LINK_EMBEDDING_TO"
  "$MODEL_DIR/vae:$LINK_VAE_TO"
  "$DATA_DIR/sd_invoke_models:$INVOKEAI_ROOT/models"
)
bash $current_dir/../utils/prepare_link.sh "${symlinks[@]}"
if ! [[ -e "/tmp/sd_invoke.prepared" ]]; then
    
    
    python3.10 -m venv $VENV_DIR/sd_invoke-env
    
    source $VENV_DIR/sd_invoke-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    apt-get install -qq build-essential -y > /dev/null
    apt-get install -qq python3-opencv libopencv-dev -y > /dev/null
    pip install pypatchmatch

    pip install "InvokeAI[xformers]" --use-pep517
    invokeai-configure -y --skip-sd-weights
    
    touch /tmp/sd_invoke.prepared
else
    
    source $VENV_DIR/sd_invoke-env/bin/activate
    
fi
log "Finished Preparing Environment for Stable Diffusion InvokeAI"


echo "### Downloading Model for Stable Diffusion InvokeAI ###"
log "Downloading Model for Stable Diffusion InvokeAI"
bash $current_dir/../utils/sd_model_download/main.sh
log "Finished Downloading Models for Stable Diffusion InvokeAI"


echo "### Starting Stable Diffusion InvokeAI ###"
log "Starting Stable Diffusion InvokeAI"
cd "$REPO_DIR"
PYTHONUNBUFFERED=1 nohup invokeai-web --port $SD_INVOKE_PORT \
--autoimport_dir $REPO_DIR/autoimport/main \
--lora_dir $REPO_DIR/autoimport/lora \
--embedding_dir $REPO_DIR/autoimport/embedding \
--controlnet_dir $REPO_DIR/autoimport/controlnet \
${EXTRA_SD_INVOKE_ARGS} > $LOG_DIR/sd_invoke.log 2>&1 &
echo $! > /tmp/sd_invoke.pid

send_to_discord "Stable Diffusion InvokeAI Started"

send_to_discord "Link: https://$PAPERSPACE_FQDN/sd-invoke/"


if [[ -n "${CF_TOKEN}" ]]; then
  if [[ "$RUN_SCRIPT" != *"sd_invoke"* ]]; then
    export RUN_SCRIPT="$RUN_SCRIPT,sd_invoke"
  fi
  bash $current_dir/../cloudflare_reload.sh
fi

echo "### Done ###"