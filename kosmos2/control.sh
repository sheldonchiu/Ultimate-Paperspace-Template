#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/kosmos2.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading Kosmos2"
    
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting Kosmos2"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping Kosmos2"
        
    /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf stop kosmos2
    

else
  echo "Invalid argument"
fi

echo "### Done ###"