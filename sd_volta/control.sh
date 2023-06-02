#!/bin/bash
set -e

cd $(dirname "$(realpath "$0")")
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/sd_volta.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading Stable Diffusion Volta"
    
    kill_pid $file
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting Stable Diffusion Volta"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping Stable Diffusion Volta"
        
    kill_pid $file
    

else
  echo "Invalid argument"
fi

echo "### Done ###"