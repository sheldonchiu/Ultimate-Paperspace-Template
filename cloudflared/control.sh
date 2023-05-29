#!/bin/bash
set -e

cd $(dirname "$(realpath "$0")")
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/cloudflared.pid"
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