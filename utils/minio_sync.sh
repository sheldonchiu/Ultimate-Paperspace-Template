#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
source $current_dir/log.sh


/tmp/minio-binaries/mc mirror --watch --overwrite --quiet $S3_MIRROR_PATH dst/$S3_MIRROR_TO_BUCKET ${EXTRA_MINIO_ARGS} > $LOG_DIR/minio_mirror_root.log 2>&1 &
echo $! > /tmp/minio_root.pid

for item in "$S3_MIRROR_PATH"/*
do
    # Check if the item is a symlink and a directory
    if [[ -L "$item" && -d "$item" ]]
    then
        # Process the symlinked folder
        log "Processing symlinked folder: $item"
        folder_name=$(basename $item)
        /tmp/minio-binaries/mc mirror --watch --overwrite --quiet $item dst/$S3_MIRROR_TO_BUCKET/$folder_name ${EXTRA_MINIO_ARGS} > $LOG_DIR/minio_mirror_$folder_name.log 2>&1 &
        echo $! > /tmp/minio_$folder_name.pid
   fi
done