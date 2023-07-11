#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Kohya SD Trainer ###"
log "Setting up Kohya SD Trainer"
TARGET_REPO_DIR=$REPO_DIR \
TARGET_REPO_BRANCH="master" \
TARGET_REPO_URL="https://github.com/bmaltais/kohya_ss.git" \
UPDATE_REPO=$KOHYA_SS_UPDATE_REPO \
UPDATE_REPO_COMMIT=$KOHYA_SS_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh
if ! [[ -e "/tmp/kohya_ss.prepared" ]]; then
    
    
    python3 -m venv /tmp/kohya_ss-env
    
    source /tmp/kohya_ss-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    pip install torch==2.0.1 torchvision==0.15.2
    pip install xformers==0.0.20 bitsandbytes==0.35.0
    pip install accelerate==0.15.0 tensorboard==2.12.1 tensorflow==2.12.0
    pip install -r requirements.txt

    mkdir -p /root/.cache/huggingface/accelerate/
    cp config_files/accelerate/default_config.yaml /root/.cache/huggingface/accelerate/default_config.yaml
    
    touch /tmp/kohya_ss.prepared
else
    
    source /tmp/kohya_ss-env/bin/activate
    
fi
log "Finished Preparing Environment for Kohya SD Trainer"



echo "### Starting Kohya SD Trainer ###"
log "Starting Kohya SD Trainer"
cd $REPO_DIR
PYTHONUNBUFFERED=1 nohup python kohya_gui.py --headless --server_port=$KOHYA_SS_PORT --username $KOHYA_USERNAME --password $KOHYA_PASSWORD ${EXTRA_KOHYA_SS_ARGS} > $LOG_DIR/kohya_ss.log 2>&1 &
echo $! > /tmp/kohya_ss.pid

send_to_discord "Kohya SD Trainer Started"
echo "### Done ###"