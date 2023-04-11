#!/bin/bash

current_dir=$(dirname "$(realpath "$0")")

# Install Python 3.10
if ! [ -e "/tmp/textgen.prepared" ]; then
    apt-get install -y python3.10 python3.10-dev python3.10-venv
    python3.10 -m venv /tmp/textgen-env
    source /tmp/textgen-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools

    pip3 install torch torchvision torchaudio
    
    cd /tmp
    git clone https://github.com/oobabooga/text-generation-webui
    cd text-generation-webui
    pip install -r requirements.txt

    mkdir repositories
    cd repositories
    git clone https://github.com/oobabooga/GPTQ-for-LLaMa.git -b cuda
    cd GPTQ-for-LLaMa
    python setup_cuda.py install

    touch /tmp/textgen.prepared

else:
    source /tmp/textgen-env/bin/activate
fi

cd /tmp/text-generation-webui
python server.py --model
  
# bash $current_dir/../utils/model_download/main.sh
# python $current_dir/../utils/model_download/link_model.py


# cd "$REPO_DIR"
# nohup python main.py > /tmp/sd-volta.log 2>&1 &
# echo $! > /tmp/sd-volta.pid