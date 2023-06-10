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
        log "Error: PID file $1 not found!"
        return
    fi

    # Check if the process has exited
    if ! kill -0 $pid 2>/dev/null; then
        echo "Error: Process $pid has already exited."
        return
    fi

    # Kill the process
    kill -TERM $pid

    echo "Process $pid has been killed."
}

download_from_hf() {
    model_hub="$1"
    model_name="$2"
    TARGET_REPO_DIR="$MODEL_DIR/$model_name" \
    TARGET_REPO_BRANCH="$3" \
    TARGET_REPO_URL="https://huggingface.co/$model_hub/$model_name" \
    bash $current_dir/../utils/prepare_repo.sh  
}