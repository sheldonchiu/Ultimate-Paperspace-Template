#!/bin/bash

apt-get install -qq aria2 -y > /dev/null

# Install Python 3.10
if ! [ -e "/tmp/sd-webui.prepared" ]; then
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/sd-webui-env
    source /tmp/sd-webui-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    pip install requests gdown bs4
    pip uninstall -y torch torchvision torchaudio protobuf lxml
else
    source /tmp/sd-webui-env/bin/activate
fi

bash prepare_repo.sh
python download_model.py

export PYTHONPATH="$PYTHONPATH:$WEBUI_DIR"
current_dir="$PWD"
# must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
cd $WEBUI_DIR
python $current_dir/preinstall.py
cd $current_dir

if [ -n "${ACTIVATE_XFORMERS}" ]; then
    pip install xformers==0.0.16
fi

touch /tmp/sd-webui.prepared
bash start.sh