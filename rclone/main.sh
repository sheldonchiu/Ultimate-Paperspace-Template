#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Rclone ###"
log "Setting up Rclone"

if ! [[ -e "/tmp/rclone.prepared" ]]; then
    
    curl https://rclone.org/install.sh | sudo bash
    mkdir -p /root/.config/rclone
    
    touch /tmp/rclone.prepared
else
    
    log "Environment already prepared"
    
fi
log "Finished Preparing Environment for Rclone"



echo "### Starting Rclone ###"
log "Starting Rclone"
rclone serve $RCLONE_SERVE_PROTOCOL --addr :$RCLONE_PORT --copy-links --user $RCLONE_USERNAME --pass $RCLONE_PASSWORD $RCLONE_SERVE_PATH > /tmp/rclone_serve.log 2>&1 &
echo $! > /tmp/rclone.pid

send_to_discord "Rclone Started"
echo "### Done ###"