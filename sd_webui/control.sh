#!/bin/bash
set -e

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

kill_pid() {
    # Read the pid from a file
    if [[ -f $1 ]]; then
        pid=$(cat $1)
    else
        echo "Error: PID file $1 not found!"
        return
    fi

    # Check if the process has exited
    if ! kill -0 $pid; then
        echo "Error: Process $pid has already exited."
        return
    fi

    # Kill the process
    kill -TERM $pid

    echo "Process $pid has been killed."
}

# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")

cd $DIR
source .env
file="/tmp/sd_webui.pid"

echo "### Command received ###"
if [[ $1 == "reload" ]]; then
    kill_pid $file
    bash main.sh
elif [[ $1 == "reload_all" ]]; then
    echo "Reinstalling Stable Diffusion WebUI"
    kill_pid $file
    rm /tmp/sd_webui.prepared
    bash main.sh
elif [[ $1 == "start" ]]; then
    bash main.sh
elif [[ $1 == "stop" ]]; then
    kill_pid $file
elif [[ $1 == "download_model" ]]; then
    echo "### Downloading Models ###"
    bash $current_dir/../utils/model_download/main.sh
    python $current_dir/../utils/model_download/link_model.py
    echo "Finished Downloading Models for Stable Diffusion WebUI"
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi

echo "### Done ###"