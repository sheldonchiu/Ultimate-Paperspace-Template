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
file="/tmp/minio.pid"

echo "### Command received ###"
if [[ $1 == "reload" ]]; then
    echo "Reloading Minio"
    kill_pid $file
    bash main.sh
elif [[ $1 == "start" ]]; then
    echo "Starting Minio"
    bash main.sh
elif [[ $1 == "stop" ]]; then
    echo "Stopping Minio"
    kill_pid $file
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi

echo "### Done ###"