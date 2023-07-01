#!/bin/bash

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Define a recursive function to kill all descendant processes
kill_descendants() {
  local parent_pid="$1"
  local child_pids=$(pgrep -P "${parent_pid}")
  for child_pid in ${child_pids}; do
    kill_descendants "${child_pid}"
  done
  echo "Killing descendant processes of PID ${parent_pid}: ${child_pids}"
  if [[ -n "${child_pids}" ]]; then
    kill "${child_pids}" >/dev/null 2>&1
  fi
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
    kill_descendants $pid

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