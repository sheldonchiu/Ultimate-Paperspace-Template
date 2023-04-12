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

if [ "$1" == "reload" ]; then
    if [ -n "$2" ]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller..."
                kill_pid "/tmp/fastchat_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker..."
                kill_pid "tmp/fastchat_worker.pid"
                ;;
            "server")
                echo "Stopping Fastchat server..."
                kill_pid "/tmp/fastchat_server.pid"
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                exit 1
                ;;
        esac
        bash main.sh $2
    else
        echo "Reloading Fastchat..."
        kill_pid "/tmp/fastchat_server.pid"
        kill_pid "tmp/fastchat_worker.pid"
        kill_pid "/tmp/fastchat_controller.pid"
        bash main.sh
    fi     
elif [ "$1" == "start" ]; then
    echo "Starting Fastchat..."
    bash main.sh
elif [ "$1" == "stop" ]; then
    if [ -n "$2" ]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller..."
                pid=$(cat /tmp/fastchat_controller.pid)
                kill -TERM $pid
                ;;
            "worker")
                echo "Stopping Fastchat worker..."
                pid=$(cat /tmp/fastchat_worker.pid)
                kill -TERM $pid
                ;;
            "server")
                echo "Stopping Fastchat server..."
                pid=$(cat /tmp/fastchat_server.pid)
                kill -TERM $pid
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                ;;
        esac
    else
        echo "Stopping Fastchat..."
        pid=$(cat /tmp/fastchat_controller.pid)
        kill -TERM $pid
        pid=$(cat /tmp/fastchat_worker.pid)
        kill -TERM $pid
        pid=$(cat /tmp/fastchat_server.pid)
        kill -TERM $pid
    fi  
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi