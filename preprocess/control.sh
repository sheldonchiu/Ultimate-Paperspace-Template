#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/preprocess.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading preprocess"
    
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting preprocess"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping preprocess"
        
    /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf stop preprocess
    

else
  echo "Invalid argument"
fi

echo "### Done ###"