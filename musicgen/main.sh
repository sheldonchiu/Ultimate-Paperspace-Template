#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Musicgen ###"
log "Setting up Musicgen"
TARGET_REPO_DIR=$REPO_DIR \
TARGET_REPO_BRANCH="main" \
TARGET_REPO_URL="https://github.com/facebookresearch/audiocraft.git" \
UPDATE_REPO=$MUSICGEN_UPDATE_REPO \
UPDATE_REPO_COMMIT=$MUSICGEN_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh
if ! [[ -e "/tmp/musicgen.prepared" ]]; then
    
    python3.10 -m venv /tmp/musicgen-env
    source /tmp/musicgen-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    pip install 'torch>=2.0'
    pip install -r requirements.txt
    
    touch /tmp/musicgen.prepared
else
    
    source /tmp/musicgen-env/bin/activate
    
fi
log "Finished Preparing Environment for Musicgen"



echo "### Starting Musicgen ###"
log "Starting Musicgen"
cd $REPO_DIR
PYTHONUNBUFFERED=1 nohup python app.py --server_port MUSICGEN_PORT  ${EXTRA_MUSICGEN_ARGS} > $LOG_DIR/musicgen.log 2>&1 &
echo $! > /tmp/musicgen.pid

send_to_discord "Musicgen Started"

bash $current_dir/../cloudflare_reload.sh

echo "### Done ###"