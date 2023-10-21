  #!/bin/bash

export current_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cd $current_dir
source .env

source $VENV_DIR/textgen-env/bin/activate

cd $REPO_DIR
share_args="--chat --listen-port $TEXTGEN_PORT --xformers"
if [ -v TEXTGEN_ENABLE_OPENAI_API ] && [ ! -z "TEXTGEN_ENABLE_OPENAI_API" ];then
loader_arg=""
if echo "TEXTGEN_OPENAI_MODEL" | grep -q "GPTQ"; then
    loader_arg="--loader exllama"
fi
if echo "TEXTGEN_OPENAI_MODEL" | grep -q "LongChat"; then
    loader_arg+=" --max_seq_len 8192 --compress_pos_emb 4"
fi
PYTHONUNBUFFERED=1 OPENEDAI_PORT=7013 python server.py --model TEXTGEN_OPENAI_MODEL $loader_arg --extensions openai $share_args
else
PYTHONUNBUFFERED=1 python server.py  $share_args
fi
