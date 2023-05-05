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
'''

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
'''

download_model = '''
args=""
mkdir -p $REPO_DIR/models
IFS=',' read -ra models <<< "$TEXTGEN_MODEL"
for model in "${models[@]}"
do
    cd /tmp
    if [[ "$model" == "vicuna-7B-1.1" ]]; then
        SYMLINKS="/tmp/vicuna-7B-1.1:$REPO_DIR/models/vicuna-7B-1.1" \\
        TARGET_REPO_DIR="/tmp/vicuna-7B-1.1" \\
        TARGET_REPO_BRANCH="main" \\
        TARGET_REPO_URL="https://huggingface.co/eachadea/vicuna-7b-1.1" \\
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-7B-1.1"
    elif [[ "$model" == "vicuna-13B-1.1" ]]; then
        SYMLINKS="/tmp/vicuna-13B-1.1:$REPO_DIR/models/vicuna-13B-1.1" \\
        TARGET_REPO_DIR="/tmp/vicuna-13B-1.1" \\
        TARGET_REPO_BRANCH="main" \\
        TARGET_REPO_URL="https://huggingface.co/eachadea/vicuna-13b-1.1" \\
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-13B-1.1"
        args="--load-in-8bit"
    elif [[ "$model" == "vicuna-13B-1.1-GPTQ-4bit-128g" ]]; then
        SYMLINKS="/tmp/vicuna-13B-1.1-GPTQ-4bit-128g:$REPO_DIR/models/vicuna-13B-1.1-GPTQ-4bit-128g" \\
        TARGET_REPO_DIR="/tmp/vicuna-13B-1.1-GPTQ-4bit-128g" \\
        TARGET_REPO_BRANCH="main" \\
        TARGET_REPO_URL="https://huggingface.co/TheBloke/vicuna-13B-1.1-GPTQ-4bit-128g" \\
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-13B-1.1-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    elif [[ "$model" == "vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" ]]; then
        SYMLINKS="/tmp/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g:$REPO_DIR/models/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" \\
        TARGET_REPO_DIR="/tmp/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" \\
        TARGET_REPO_BRANCH="main" \\
        TARGET_REPO_URL="https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/" \\
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    fi
done
'''

action_before_start = ""

start = f'''
nohup python server.py  --listen-port $TEXTGEN_PORT --model $model_name $args > /tmp/{name}.log 2>&1 &
echo $! > /tmp/{name}.pid
'''

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