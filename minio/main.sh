#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Minio ###"
log "Setting up Minio"

if ! [[ -e "/tmp/minio.prepared" ]]; then
    
    curl https://dl.min.io/client/mc/release/linux-amd64/mc \
      --create-dirs \
      -o /tmp/minio-binaries/mc

    chmod +x /tmp/minio-binaries/mc
    export PATH=$PATH:/tmp/minio-binaries/
    echo "export PATH=\$PATH:/tmp/minio-binaries/" >> /etc/bash.bashrc
    
    touch /tmp/minio.prepared
else
    
    log "Environment already prepared"
    
fi
log "Finished Preparing Environment for Minio"



/tmp/minio-binaries/mc alias set dst $S3_HOST_URL $S3_ACCESS_KEY $S3_SECRET_KEY

echo "### Starting Minio ###"
log "Starting Minio"
if [[ -z $S3_MIRROR_PATH || -z $S3_MIRROR_TO_BUCKET ]]; then
    log "ENV S3_MIRROR_PATH or S3_MIRROR_TO_BUCKET not provided, skipping minio mirror"
else
    mkdir -p $S3_MIRROR_PATH
    nohup /tmp/minio-binaries/mc mirror --overwrite --watch --quiet $S3_MIRROR_PATH dst/$S3_MIRROR_TO_BUCKET ${EXTRA_MINIO_ARGS} > $LOG_DIR/minio_mirror.log 2>&1 &
    echo $! > /tmp/minio.pid
fi

send_to_discord "Minio Started"

bash $current_dir/../cloudflare_reload.sh

echo "### Done ###"