  #!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
  
chmod +x $current_dir/hfdownloader

IFS=',' read -ra models <<< "$LLM_MODEL_TO_DOWNLOAD"
for model in "${models[@]}"
do
    $current_dir/hfdownloader -m $model -s $MODEL_DIR 
done