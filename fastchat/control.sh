#!/bin/bash
set -e

# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")

cd $DIR
source .env

if [ "$1" == "reload" ]; then
    if [ -n "$2" ]; then
        case $2 in
            "controller")
                echo "Reloading Fastchat controller..."
                pid=$(cat /tmp/fastchat_controller.pid)
                kill -TERM $pid
                ;;
            "worker")
                echo "Reloading Fastchat worker..."
                pid=$(cat /tmp/fastchat_worker.pid)
                kill -TERM $pid
                ;;
            "server")
                echo "Reloading Fastchat server..."
                pid=$(cat /tmp/fastchat_server.pid)
                kill -TERM $pid
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                exit 1
                ;;
        esac
        bash main.sh $2
    else
        echo "Reloading Fastchat..."
        pid=$(cat /tmp/fastchat_controller.pid)
        kill -TERM $pid
        pid=$(cat /tmp/fastchat_worker.pid)
        kill -TERM $pid
        pid=$(cat /tmp/fastchat_server.pid)
        kill -TERM $pid
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