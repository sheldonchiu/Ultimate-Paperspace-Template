#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/huggingface.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading HuggingFace Hub"
    
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting HuggingFace Hub"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping HuggingFace Hub"
        
    /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf stop huggingface
    

else
  echo "Invalid argument"
fi

echo "### Done ###"