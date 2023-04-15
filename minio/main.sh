#!/bin/bash
set -e

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Setting up Minio Client ###"
if ! [[ -e "/tmp/minio.prepared" ]]; then
  curl https://dl.min.io/client/mc/release/linux-amd64/mc \
    --create-dirs \
    -o /tmp/minio-binaries/mc

  chmod +x /tmp/minio-binaries/mc
  export PATH=$PATH:/tmp/minio-binaries/
  echo "export PATH=\$PATH:/tmp/minio-binaries/" >> /etc/bash.bashrc
  touch /tmp/minio.prepared
fi
echo "Minio Client setup complete."

mc alias set dst $S3_HOST_URL $S3_ACCESS_KEY $S3_SECRET_KEY

if [[ -z $S3_MIRROR_PATH || -z $S3_MIRROR_TO_BUCKET ]]; then
    echo "ENV S3_MIRROR_PATH or S3_MIRROR_TO_BUCKET not provided, skipping minio mirror"
else
    echo "### Starting Minio Mirror ###"
    mkdir -p $S3_MIRROR_PATH
    nohup mc mirror --overwrite --watch --quiet $S3_MIRROR_PATH dst/$S3_MIRROR_TO_BUCKET > /tmp/minio.log 2>&1 &
    echo $! > /tmp/minio.pid
    echo "Minio mirror started"
fi

echo "### Done ###"