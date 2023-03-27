#!/bin/bash

apt-get update -qq
apt-get install -qq pigz -y > /dev/null

cd /notebook
git clone https://github.com/sheldonchiu/kohya-trainer-paperspace.git

cd kohya-trainer-paperspace
pip install -r requirements_train.txt
pip install lion_pytorch xformers==0.0.17rc482 triton==2.0.0 lycoris_lora prettytable