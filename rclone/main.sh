#!/bin/bash
set -e

echo "Setting up Rclone..."
if ! [[ -e "/tmp/rclone.prepared" ]]; then
    curl https://rclone.org/install.sh | sudo bash
    mkdir -p /root/.config/rclone
    touch /tmp/rclone.prepared
fi
echo "Rclone setup complete."

rclone serve $RCLONE_SERVE_PROTOCOL --addr :$RCLONE_PORT --copy-links --user $RCLONE_USERNAME --pass $RCLONE_PASSWORD $RCLONE_SERVE_PATH > /tmp/rclone.log 2>&1 &
echo $! > /tmp/rclone.pid

echo "Rclone serve started"