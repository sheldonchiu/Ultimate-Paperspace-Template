#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Langflow ###"
log "Setting up Langflow"

if ! [[ -e "/tmp/langflow.prepared" ]]; then
    
    python3.10 -m venv /tmp/langflow-env
    source /tmp/langflow-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    pip install langflow
    
    touch /tmp/langflow.prepared
else
    
    source /tmp/langflow-env/bin/activate
    
fi
log "Finished Preparing Environment for Langflow"



echo "### Starting Langflow ###"
log "Starting Langflow"
mkdir -p $REPO_DIR
cd $REPO_DIR
PYTHONUNBUFFERED=1 nohup python -m langflow --port $LANGFLOW_PORT > $LOG_DIR/langflow.log 2>&1 &
echo $! > /tmp/langflow.pid

send_to_discord "Langflow Started"
echo "### Done ###"