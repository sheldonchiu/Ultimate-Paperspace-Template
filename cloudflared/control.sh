#!/bin/bash
set -e

# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")

cd $DIR
# if [ "$1" == "reload" ]; then
#     if [ -n "$2" ]; then
#         echo "Reloading Cloudflare tunnel with port $2..."
#         # Get the PID of the cloudflared process
#         pid=$(cat /tmp/cloudflared_{$2}.pid)
#         # Read the environment variables of the cloudflared process
#         ENVIRON=$(tr '\0' '\n' < /proc/$pid/environ)
#         # Kill the cloudflared process
#         kill -TERM $pid
#         # Load the environment variables
#         export $ENVIRON
#         # Start the cloudflared process
#         bash main.sh
#     else
#         for file in /tmp/cloudflared_*.pid; do
#             echo "Reloading $file"
#             pid=$(cat $file)
#             ENVIRON=$(tr '\0' '\n' < /proc/$pid/environ)
#             kill -TERM $pid
#             export $ENVIRON
#             bash main.sh
#         done
#     fi 
elif [ "$1" == "reload" ]; then
    if [ -n "$2" ]; then
        echo "Reloading Cloudflare tunnel with port $2..."
        pid=$(cat /tmp/cloudflared_{$2}.pid)
        kill -TERM $pid
        bash main.sh
    else
        for file in /tmp/cloudflared_*.pid; do
            echo "Reloading $file"
            pid=$(cat $file)
            kill -TERM $pid
            bash main.sh
        done
    fi     
elif [ "$1" == "start" ]; then
    echo "Starting Cloudflare Tunnel..."
    source .env
    bash main.sh
elif [ "$1" == "stop" ]; then
    if [ -n "$2" ]; then
        echo "Stopping Cloudflare tunnel with port $2..."
        pid=$(cat /tmp/cloudflared_{$2}.pid)
        kill -TERM $pid
    else
        for file in /tmp/cloudflared_*.pid; do
            echo "Stopping $file"
            pid=$(cat $file)
            kill -TERM $pid
        done
    fi
else
  echo "Invalid argument. Usage: bash test.sh [reload|start|stop]"
fi