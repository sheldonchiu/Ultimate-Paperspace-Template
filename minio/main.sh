#!/bin/bash

curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o /tmp/minio-binaries/mc

chmod +x /tmp/minio-binaries/mc
export PATH=$PATH:/tmp/minio-binaries/
echo "export PATH=\$PATH:/tmp/minio-binaries/" >> /etc/bash.bashrc

mc alias set dst $S3_HOST_URL $S3_ACCESS_KEY $S3_SECRET_KEY

if [[ -z "${S3_MIRROR_PATH}" || -z "${S3_MIRROR_TO_BUCKET}" ]]; then
    echo "ENV S3_MIRROR_PATH or S3_MIRROR_TO_BUCKET not provided, skipping minio mirror"
else
    mkdir -p $S3_MIRROR_PATH
    nohup mc mirror --overwrite --watch --quiet $S3_MIRROR_PATH dst/$S3_MIRROR_TO_BUCKET/ > /tmp/minio_mirror.log 2>&1 &
    echo $! > /tmp/minio_mirror.pid
fi