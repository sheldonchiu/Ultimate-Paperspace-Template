#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
source $current_dir/log.sh
source $current_dir/helper.sh

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR
  
chmod +x $current_dir/hfdownloader

if ! [ -v "MODEL_DIR" ]; then
    source $current_dir/../.env
    export MODEL_DIR="$DATA_DIR/llm-models"
fi

echo "### Downloading Models ###"
IFS=',' read -ra models <<< "$LLM_MODEL_TO_DOWNLOAD"
for model in "${models[@]}"
do
    $current_dir/hfdownloader -m $model -s $MODEL_DIR 2>&1 > /dev/null
done

echo "### Finished Model Download ###"