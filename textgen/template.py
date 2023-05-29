from jinja2 import Template

# Define the variables to be used in the template
title = "Text generation Webui"
name = "textgen"
use_python = True

prepare_repo = '''
TARGET_REPO_DIR=$REPO_DIR \\
TARGET_REPO_BRANCH="main" \\
TARGET_REPO_URL="https://github.com/oobabooga/text-generation-webui" \\
UPDATE_REPO=$TEXTGEN_UPDATE_REPO \\
UPDATE_REPO_COMMIT=$TEXTGEN_UPDATE_REPO_COMMIT \\
bash $current_dir/../utils/prepare_repo.sh
'''.strip()

prepare_env = '''
    cd $REPO_DIR
    pip install torch torchvision torchaudio
    pip install -r requirements.txt

    mkdir -p repositories
    cd repositories
    TARGET_REPO_DIR=$REPO_DIR/repositories/GPTQ-for-LLaMa \\
    TARGET_REPO_BRANCH="cuda" \\
    TARGET_REPO_URL="https://github.com/qwopqwop200/GPTQ-for-LLaMa.git" \\
    bash $current_dir/../utils/prepare_repo.sh
    
    cd GPTQ-for-LLaMa
    python setup_cuda.py install

    pip install deepspeed
    
    # Temp fix for graio 3.25.0 cannot restart on GUI
    pip install gradio>=3.28.0
'''.strip()

download_model = '''
function download_from_hf() {
    model_hub="$1"
    model_name="$2"
    TARGET_REPO_DIR="$model_dir/$model_name" \\
    TARGET_REPO_BRANCH="$3" \\
    TARGET_REPO_URL="https://huggingface.co/$model_hub/$model_name" \\
    bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}" 
}
# Prepare model dir and link it under the models folder inside the repo
model_dir="/tmp/llm-models"
mkdir -p $model_dir
rm -rf $REPO_DIR/models
ln -s $model_dir $REPO_DIR/models
if [[ ! -f $model_dir/config.yaml ]]; then  
    wget -q https://raw.githubusercontent.com/oobabooga/text-generation-webui/main/models/config.yaml -P $model_dir
fi

args=""
IFS=',' read -ra models <<< "$TEXTGEN_MODEL"
for model in "${models[@]}"
do
    cd /tmp
    if [[ "$model" == "vicuna-13B-1.1" ]]; then
        model_name="vicuna-13B-1.1-GPTQ-4bit-128g"
        download_from_hf  "TheBloke" "$model_name" "main"
        args="--wbits 4 --groupsize 128 --model_type Llama"
    elif [[ "$model" == "stable-vicuna-13B" ]]; then
        model_name="stable-vicuna-13B-GPTQ"
        download_from_hf  "TheBloke" "$model_name" "latest"
        args="--wbits 4 --groupsize 128 --model_type Llama"
    fi
done
'''.strip()

action_before_start = ""

start = f'''
cd $REPO_DIR
nohup python server.py  --listen-port $TEXTGEN_PORT --model $model_name $args --xformers > /tmp/{name}.log 2>&1 &
echo $! > /tmp/{name}.pid
'''.strip()

# Load the template from a file
with open('../template/main.j2') as f:
    template = Template(f.read())

# Render the template with the variables
result = template.render(
    title=title,
    name=name, 
    use_python=use_python,
    prepare_repo=prepare_repo,
    prepare_env=prepare_env,
    download_model=download_model,
    action_before_start=action_before_start,
    start=start,
)

with open('main.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/control.j2') as f:
    template = Template(f.read())

# Render the template with the variables
result = template.render(
    title=title,
    name=name,
)

with open('control.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/env.j2') as f:
    template = Template(f.read())
    
export_required_env = ""
other_commands = '''
export MODEL_DIR=${TEXTGEN_MODEL_DIR:-"/tmp/textgen-model"}
export REPO_DIR=${TEXTGEN_REPO_DIR:-"/storage/text-generation-webui"}

export TEXTGEN_PORT=${TEXTGEN_PORT:-7862}
export EXPOSE_PORTS="$EXPOSE_PORTS:$TEXTGEN_PORT"
export PORT_MAPPING="$PORT_MAPPING:textgen"
export HUGGINGFACE_TOKEN=$HF_TOKEN

export LINK_MODEL_TO=${TEXTGEN_LINK_MODEL_TO:-"${REPO_DIR}/models/"}
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)