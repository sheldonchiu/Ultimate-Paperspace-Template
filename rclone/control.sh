#!/bin/bash
set -e

# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")

cd $DIR
source .env
file="/tmp/rclone_serve.pid"

if [ "$1" == "reload" ]; then
    if [ -e "$file" ]; then
        echo "Reloading rclone serve"
        pid=$(cat $file)
        kill -TERM $pid
        bash main.sh
    else
        echo "No rclone serve is running, installing..."
        bash main.sh
    fi
elif [ "$1" == "start" ]; then
    echo "Starting rclone serve..."
    bash main.sh
elif [ "$1" == "stop" ]; then
    if [ -e "$file" ]; then
        echo "Stopping rclone serve"
        pid=$(cat $file)
        kill -TERM $pid
    fi
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi