#!/bin/bash

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

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