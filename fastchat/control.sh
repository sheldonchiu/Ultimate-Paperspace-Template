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
file="/tmp/fastchat.pid"

echo "### Command received ###"
if [[ $1 == "reload" ]]; then
    echo "Reloading FastChat"
    
    
    if [[ -n $2 ]]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller"
                kill_pid "/tmp/fastchat_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker"
                kill_pid "tmp/fastchat_worker.pid"
                ;;
            "server")
                echo "Stopping Fastchat server"
                kill_pid "/tmp/fastchat_server.pid"
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                exit 1
                ;;
        esac
        bash main.sh $2
    else
        kill_pid "/tmp/fastchat_server.pid"
        kill_pid "tmp/fastchat_worker.pid"
        kill_pid "/tmp/fastchat_controller.pid"
        bash main.sh

    
elif [[ $1 == "start" ]]; then
    echo "Starting FastChat"
    
    bash main.sh
    
elif [[ $1 == "stop" ]]; then
    echo "Stopping FastChat"
    
    
    if [[ -n $2 ]]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller"
                kill_pid "/tmp/fastchat_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker"
                kill_pid "tmp/fastchat_worker.pid"
                ;;
            "server")
                echo "Stopping Fastchat server"
                kill_pid "/tmp/fastchat_server.pid"
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                ;;
        esac
    else
        kill_pid "/tmp/fastchat_server.pid"
        kill_pid "tmp/fastchat_worker.pid"
        kill_pid "/tmp/fastchat_controller.pid"
    fi  

    

else
  echo "Invalid argument"
fi

echo "### Done ###"