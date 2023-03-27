#!/bin/bash

# Read the RUN_SCRIPT environment variable
run_script="$RUN_SCRIPT"

# Separate the variable by commas
IFS=',' read -ra scripts <<< "$run_script"

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed, installing now..."
    apt-get update -qq
    apt-get install -qq curl -y > /dev/null
else
    echo "curl is already installed"
fi

# Loop through each script and execute the corresponding case
for script in "${scripts[@]}"
do
  case $script in
    "cloudflared")
        if [ -z "${CF_TOKEN}" ]; then
           echo "ENV CF_TOKEN not provided, skipping cloudflared installation"
        else
            bash cloudflared/main.sh
        fi
      ;;
    "minio")
        if [[ -z "${S3_HOST_URL}" || -z "${S3_ACCESS_KEY}" || -z "${S3_SECRET_KEY}" ]]; 
        then
           echo "ENV One of S3_HOST_URL, S3_ACCESS_KEY, or S3_SECRET_KEY not provided, skipping minio installation"
        else
            bash minio/main.sh
        fi
      ;;
    "sd-webui")
      # Execute script3
      ;;
    "sd-volta")
      # Execute script3
      ;;
    "kohya-ss")
        bash kohya-ss/main.sh
      ;;
    *)
      # Unknown script, do nothing
      ;;
  esac
done