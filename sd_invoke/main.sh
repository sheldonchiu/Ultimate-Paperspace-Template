#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Stable Diffusion InvokeAI ###"
log "Setting up Stable Diffusion InvokeAI"
symlinks=(
    "$REPO_DIR:$WORKING_DIR/stable-diffusion-invokeai"
    "$OUTPUTS_DIR:$WORKING_DIR/storage"
    "$REPO_DIR/output:$IMAGE_OUTPUTS_DIR/stable-diffusion-invokeai"
    "$MODEL_DIR:$WORKING_DIR/models"
)

mkdir -p $INVOKEAI_ROOT

bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"
if ! [[ -e "/tmp/sd_invoke.prepared" ]]; then
    
    python3.10 -m venv /tmp/sd_invoke-env
    source /tmp/sd_invoke-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    apt-get install -qq build-essential -y > /dev/null
    apt-get install -qq python3-opencv libopencv-dev -y > /dev/null
    pip install pypatchmatch

    pip install "InvokeAI[xformers]" --use-pep517
    invokeai-configure -y
    
    touch /tmp/sd_invoke.prepared
else
    
    source /tmp/sd_invoke-env/bin/activate
    
fi
log "Finished Preparing Environment for Stable Diffusion InvokeAI"


echo "### Downloading Model for Stable Diffusion InvokeAI ###"
log "Downloading Model for Stable Diffusion InvokeAI"
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
log "Finished Downloading Models for Stable Diffusion InvokeAI"


echo "### Starting Stable Diffusion InvokeAI ###"
log "Starting Stable Diffusion InvokeAI"
cd "$REPO_DIR"
nohup invokeai --web --autoconvert $MODEL_DIR > /tmp/sd_invoke.log 2>&1 &
echo $! > /tmp/sd_invoke.pid

send_to_discord "Stable Diffusion InvokeAI Started"
echo "### Done ###"