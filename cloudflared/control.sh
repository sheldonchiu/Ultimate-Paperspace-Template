#!/bin/bash
set -e

kill_pid() {
    # Read the pid from a file
    if [[ -f $1 ]]; then
        pid=$(cat $1)
    else
        echo "Error: PID file $1 not found!"
        return
    fi

    # Check if the process has exited
    if ps -p $pid -o pid,comm | grep -q $pid; then
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

if [[ $1 == "reload" ]]; then
    echo "Reloading Cloudflare tunnels..."
    for file in /tmp/cloudflared_*.pid; do
        kill_pid $file
    done
    bash main.sh
elif [[ $1 == "start" ]]; then
    echo "Starting Cloudflare tunnels..."
    bash main.sh
elif [[ $1 == "stop" ]]; then
    echo "Stopping Cloudflare tunnels..."
    if [[ -n $2 ]]; then
        echo "Stopping Cloudflare tunnel for $2..."
        kill_pid /tmp/cloudflared_{$2}.pid
    else
        for file in /tmp/cloudflared_*.pid; do
            kill_pid $file
        done
    fi
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi