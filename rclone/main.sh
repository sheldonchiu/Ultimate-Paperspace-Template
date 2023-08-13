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
    
    curl https://rclone.org/install.sh | sudo bash > /dev/null 2>&1
    mkdir -p /root/.config/rclone
    
    touch /tmp/rclone.prepared
else
    
    log "Environment already prepared"
    
fi
log "Finished Preparing Environment for Rclone"



echo "### Starting Rclone ###"
log "Starting Rclone"
rclone serve $RCLONE_SERVE_PROTOCOL --addr :$RCLONE_PORT --copy-links --user $RCLONE_USERNAME --pass $RCLONE_PASSWORD $RCLONE_SERVE_PATH ${EXTRA_RCLONE_ARGS} > $LOG_DIR/rclone_serve.log 2>&1 &
echo $! > /tmp/rclone.pid

send_to_discord "Rclone Started"

if env | grep -q "PAPERSPACE"; then
  send_to_discord "Link: https://$PAPERSPACE_FQDN/rclone/"
fi


if [[ -n "${CF_TOKEN}" ]]; then
  if [[ "$RUN_SCRIPT" != *"rclone"* ]]; then
    export RUN_SCRIPT="$RUN_SCRIPT,rclone"
  fi
  bash $current_dir/../cloudflare_reload.sh
fi

echo "### Done ###"