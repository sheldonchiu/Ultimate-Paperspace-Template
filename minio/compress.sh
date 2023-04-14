#!/bin/bash
set -e

echo "### Compress command received ###"
# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")
cd $DIR

apt-get update -qq
apt-get install -qq zip -y > /dev/null

TARGET_FILE="/tmp/zip_$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8).zip"
echo "### Compressing ###"
echo "Compressing content to $TARGET_FILE"
zip -rq $TARGET_FILE $ZIP_TARGET_PATH
ln -s $TARGET_FILE /notebooks

echo Path to zip file: $(echo $TARGET_FILE | sed 's/tmp/notebooks/g')
echo "### DONE ###"
