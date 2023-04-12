#!/bin/bash

if ! [[ -e "/tmp/kohya.prepared" ]]; then
    apt-get install -qq pigz -y > /dev/null

    apt-get install -y -qq python3.10 python3.10-venv > /dev/null
    python3.10 -m venv /tmp/kohya-env
    source /tmp/kohya-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools

    git clone https://github.com/sheldonchiu/kohya-trainer-paperspace.git
    
    cd kohya-trainer-paperspace
    pip install -r requirements_train.txt
    pip install lion_pytorch lycoris_lora prettytable

fi

