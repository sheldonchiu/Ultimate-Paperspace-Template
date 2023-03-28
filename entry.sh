#!/bin/bash

# Read the RUN_SCRIPT environment variable
run_script="$RUN_SCRIPT"

# Separate the variable by commas
IFS=',' read -ra scripts <<< "$run_script"

export SCRIPT_ROOT_DIR="$PWD"


apt-get update -qq
apt-get install -qq curl -y > /dev/null

# Loop through each script and execute the corresponding case
for script in "${scripts[@]}"
do
  cd $SCRIPT_ROOT_DIR
  case $script in
    "cloudflared")
        if [ -z "${CF_TOKEN}" ]; then
           echo "ENV CF_TOKEN not provided, skipping cloudflared installation"
        else
            cd $SCRIPT_ROOT_DIR/cloudflared
            bash main.sh
        fi
      ;;
    "minio")
        if [[ -z "${S3_HOST_URL}" || -z "${S3_ACCESS_KEY}" || -z "${S3_SECRET_KEY}" ]]; 
        then
           echo "ENV One of S3_HOST_URL, S3_ACCESS_KEY, or S3_SECRET_KEY not provided, skipping minio installation"
        else
            cd $SCRIPT_ROOT_DIR/minio
            bash main.sh
        fi
      ;;
    "sd-webui")
      cd $SCRIPT_ROOT_DIR/sd-webui
      bash main.sh
      ;;
    "sd-volta")
      cd $SCRIPT_ROOT_DIR/sd-volta
      bash main.sh
      ;;
    "kohya-ss")
        cd $SCRIPT_ROOT_DIR/kohya-ss
        bash main.sh
      ;;
    *)
      # Unknown script, do nothing
      ;;
  esac
done