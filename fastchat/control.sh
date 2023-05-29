#!/bin/bash
set -e

cd $(dirname "$(realpath "$0")")
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/fastchat.pid"
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
                kill_pid "/tmp/fastchat_worker.pid"
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
        kill_pid "/tmp/fastchat_worker.pid"
        kill_pid "/tmp/fastchat_controller.pid"
        bash main.sh
    fi
    
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
                kill_pid "/tmp/fastchat_worker.pid"
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
        kill_pid "/tmp/fastchat_worker.pid"
        kill_pid "/tmp/fastchat_controller.pid"
    fi
    

else
  echo "Invalid argument"
fi

echo "### Done ###"