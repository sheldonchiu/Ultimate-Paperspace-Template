#!/bin/bash
set -e

cd $(dirname "$(realpath "$0")")
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
file="/tmp/minio.pid"
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
  echo "Invalid argument"
fi

echo "### Done ###"