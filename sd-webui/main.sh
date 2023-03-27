#!/bin/bash

apt-get install -qq aria2 -y > /dev/null
pip install requests gdown bs4

python download_model.py