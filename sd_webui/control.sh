#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/sd_webui.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading Stable Diffusion WebUI"
    
    kill_pid $file
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting Stable Diffusion WebUI"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping Stable Diffusion WebUI"
        
    kill_pid $file
    

elif [[ $1 == "download_model" ]]; then
    echo "### Downloading Models ###"
    bash $current_dir/../utils/model_download/main.sh
    python $current_dir/../utils/model_download/link_model.py
    echo "Finished Downloading Models for Stable Diffusion WebUI"

else
  echo "Invalid argument"
fi

echo "### Done ###"