#!/bin/bash
set -e

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

echo "### Command received ###"
# Get the directory path of the current file
DIR=$(dirname "$(realpath "$0")")
cd $DIR

TARGET_FILE="/tmp/zip_$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8).zip"
echo "### Compressing ###"
echo "Compressing content to $TARGET_FILE"
zip -rq $TARGET_FILE $ZIP_TARGET_PATH
ln -s $TARGET_FILE /notebooks

echo Path to zip file: $(echo $TARGET_FILE | sed 's/tmp/notebooks/g')
echo "### Done ###"
