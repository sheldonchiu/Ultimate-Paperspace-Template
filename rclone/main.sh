#!/bin/bash
set -e

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

current_dir=$(dirname "$(realpath "$0")")
echo "### Setting up Rclone ###"



if ! [[ -e "/tmp/rclone.prepared" ]]; then
    
    curl https://rclone.org/install.sh | sudo bash
    mkdir -p /root/.config/rclone

    touch /tmp/rclone.prepared
else
    
    pass
    
fi
echo "Finished Preparing Environment for Rclone"



echo "### Starting Rclone ###"
rclone serve $RCLONE_SERVE_PROTOCOL --addr :$RCLONE_PORT --copy-links --user $RCLONE_USERNAME --pass $RCLONE_PASSWORD $RCLONE_SERVE_PATH > /tmp/rclone.log 2>&1 &
echo $! > /tmp/rclone.pid
echo "Rclone Started"
echo "### Done ###"