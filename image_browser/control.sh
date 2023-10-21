#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/image_browser.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading Image Browser"
    
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting Image Browser"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping Image Browser"
        
    /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf stop image_browser
    

else
  echo "Invalid argument"
fi

echo "### Done ###"