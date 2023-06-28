#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
source $current_dir/log.sh

if [[ $# -gt 0 ]]; then
    for symlink in "$@"; do
        src="${symlink%%:*}"
        dests="${symlink#*:}"

        IFS=',' read -ra dest_array <<< "$dests"

        mkdir -p $src
        for dest in "${dest_array[@]}"; do
            rm -rf $dest
            ln -s $src $dest
            log "$(realpath $dest) -> $dest"
        done
    done
fi