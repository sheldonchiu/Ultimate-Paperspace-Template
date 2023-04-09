#!/bin/bash
set -e

# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")

cd $DIR
source .env
file="/tmp/sd-webui.pid"

# if [ "$1" == "reload" ]; then
#     if [ -e "$file" ]; then
#         echo "Reloading Stable Diffusion WebUI"
#         pid=$(cat $file)
#         env -i $(cat /proc/$pid/environ | tr '\0' '\n') xargs -0 -L 1 export
#         kill -TERM $pid
#         export $ENVIRON
#         bash main.sh
#     else
#         echo "No Stable Diffusion WebUI is running, installing..."
#         bash main.sh
#     fi
if [ "$1" == "reload" ]; then
    if [ -e "$file" ]; then
        echo "Reloading Stable Diffusion WebUI"
        pid=$(cat $file)
        kill -TERM $pid
        bash main.sh
    else
        echo "No Stable Diffusion WebUI is running, installing..."
        bash main.sh
    fi
elif [ "$1" == "reload_all" ]; then
    if [ -e "$file" ]; then
        echo "Reinstalling Stable Diffusion WebUI"
        pid=$(cat $file)
        kill -TERM $pid
        rm /tmp/sd-webui.prepared
        bash main.sh
    else
        echo "No Stable Diffusion WebUI is running, installing..."
        bash main.sh
    fi
elif [ "$1" == "start" ]; then
    echo "Starting Stable Diffusion WebUI..."
    bash main.sh
elif [ "$1" == "stop" ]; then
    if [ -e "$file" ]; then
        echo "Stopping Stable Diffusion WebUI"
        pid=$(cat $file)
        kill -TERM $pid
    fi
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi