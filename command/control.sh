#!/bin/bash
set -e

kill_pid() {
    # Read the pid from a file
    if [ -f $1 ]; then
        pid=$(cat $1)
    else
        echo "Error: PID file $1 not found!"
        return 1
    fi

    # Check if the process has exited
    if ps -p $pid -o pid,comm | grep -q $pid; then
        echo "Error: Process $pid has already exited."
        return 1
    fi

    # Kill the process
    kill -TERM $pid

    echo "Process $pid has been killed."
}

# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")

cd $DIR
source .env
file="/tmp/command.pid"

if [ "$1" == "reload" ]; then
    kill_pid $file
    bash main.sh
elif [ "$1" == "start" ]; then
    echo "Starting Command Server..."
    bash main.sh
elif [ "$1" == "stop" ]; then
    kill_pid $file
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi