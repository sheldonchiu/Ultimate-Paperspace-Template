#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up preprocess ###"
log "Setting up preprocess"
TARGET_REPO_DIR=$PREPROCESS_REPO_DIR \
TARGET_REPO_BRANCH="main" \
TARGET_REPO_URL="https://github.com/sheldonchiu/paperspace-sd-auto-preprocess.git" \
bash $current_dir/../utils/prepare_repo.sh

TARGET_REPO_DIR=$TRAINER_REPO_DIR \
TARGET_REPO_BRANCH="sdxl" \
TARGET_REPO_URL="https://github.com/sheldonchiu/kohya-trainer-paperspace.git" \
UPDATE_REPO="commit" \
UPDATE_REPO_COMMIT="4b209a5b6e8d5701294bded10eae6ba98a964ac3" \
bash $current_dir/../utils/prepare_repo.sh  
if ! [[ -e "/tmp/preprocess.prepared" ]]; then
    
    
    python3 -m venv /tmp/preprocess-env
    
    source /tmp/preprocess-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $PREPROCESS_REPO_DIR/preprocess
    bash prepare_env.sh

    ln -s /storage /notebooks/storage
    ln -s /tmp /notebooks/tmp
    
    touch /tmp/preprocess.prepared
else
    
    source /tmp/preprocess-env/bin/activate
    
fi
log "Finished Preparing Environment for preprocess"


echo "### Downloading Model for preprocess ###"
log "Downloading Model for preprocess"
bash $current_dir/../utils/sd_model_download/main.sh
log "Finished Downloading Models for preprocess"


cd $current_dir/../kosmos2
bash control.sh stop

echo "### Starting preprocess ###"
log "Starting preprocess"
cd $PREPROCESS_REPO_DIR/preprocess

python main.py > $LOG_DIR/preprocess.log 2>&1 &
echo $! > /tmp/preprocess.pid

send_to_discord "preprocess Started"


echo "### Done ###"