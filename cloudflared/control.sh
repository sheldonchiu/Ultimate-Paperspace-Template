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
file="/tmp/cloudflared.pid"

echo "### Command received ###"
if [[ $1 == "reload" ]]; then
    echo "Reloading Cloudflare Tunnel"
    
    
    for file in /tmp/cloudflared_*.pid; do
        kill_pid $file
    done
    bash main.sh

    
elif [[ $1 == "start" ]]; then
    echo "Starting Cloudflare Tunnel"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    echo "Stopping Cloudflare Tunnel"
    
    
    if [[ -n $2 ]]; then
        echo "Stopping Cloudflare tunnel for $2"
        kill_pid /tmp/cloudflared_{$2}.pid
    else
        for file in /tmp/cloudflared_*.pid; do
            kill_pid $file
        done
    fi

    

else
  echo "Invalid argument"
fi

echo "### Done ###"