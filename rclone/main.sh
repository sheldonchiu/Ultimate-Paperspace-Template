#!/bin/bash


if ! [ -e "/tmp/rclone.prepared" ]; then
    curl https://rclone.org/install.sh | sudo bash
    mkdir -p /root/.config/rclone
    touch /tmp/rclone.prepared
fi

rclone serve $RCLONE_SERVE_PROTOCOL --addr :$RCLONE_PORT --copy-links --user $RCLONE_USERNAME --pass $RCLONE_PASSWORD $RCLONE_SERVE_PATH > /tmp/rclone_serve.log 2>&1 &
echo $! > /tmp/rclone_serve.pid

bash $SCRIPT_ROOT_DIR/utils/discord/send.sh "Rclone serve started"