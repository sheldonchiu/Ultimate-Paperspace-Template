#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Command Server ###"
log "Setting up Command Server"

if ! [[ -e "/tmp/command.prepared" ]]; then
    
    
    python3 -m venv /tmp/command-env
    
    source /tmp/command-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    pip install fastapi uvicorn[standard] psutil
    
    touch /tmp/command.prepared
else
    
    source /tmp/command-env/bin/activate
    
fi
log "Finished Preparing Environment for Command Server"



echo "### Starting Command Server ###"
log "Starting Command Server"
PYTHONUNBUFFERED=1 nohup uvicorn main:app --host 0.0.0.0 --port $COMMAND_PORT > $LOG_DIR/command.log 2>&1 &
echo $! > /tmp/command.pid

send_to_discord "Command Server Started"

if [[ "$RUN_SCRIPT" != *"command"* ]]; then
  export RUN_SCRIPT="$RUN_SCRIPT,command"
fi
bash $current_dir/../cloudflare_reload.sh

echo "### Done ###"