#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/command.pid"
if [[ $1 == "reload" ]]; then
    log "Reloading Command Server"
    
    bash main.sh
    
elif [[ $1 == "start" ]]; then
    log "Starting Command Server"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    log "Stopping Command Server"
    
    /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf stop command
    if [[ -n "${DISCORD_BOT}" ]]; then
      /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf stop command_process
    fi
    

else
  echo "Invalid argument"
fi

echo "### Done ###"