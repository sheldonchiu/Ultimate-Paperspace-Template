#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Flowise ###"
log "Setting up Flowise"

if ! [[ -e "/tmp/flowise.prepared" ]]; then
    
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
    apt-get install -y nodejs

    npm install -g flowise
    
    touch /tmp/flowise.prepared
else
    
    log "Environment already prepared"
    
fi
log "Finished Preparing Environment for Flowise"



echo "### Starting Flowise ###"
log "Starting Flowise"
nohup PORT=$FLOWISE_PORT npx flowise start > /tmp/flowise.log 2>&1 &
echo $! > /tmp/flowise.pid

send_to_discord "Flowise Started"
echo "### Done ###"