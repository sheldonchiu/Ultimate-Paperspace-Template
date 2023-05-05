from jinja2 import Template

# Define the variables to be used in the template
title = "FastChat"
name = "fastchat"
use_python = True

prepare_repo = ""

prepare_env = '''
    pip3 install fschat
    pip3 install git+https://github.com/huggingface/transformers
'''

download_model = '''
args=""
if [[ $FASTCHAT_MODEL == "vicuna-7b" ]]; then
    git clone https://huggingface.co/eachadea/vicuna-7b-1.1 /tmp/vicuna-7b-1.1
    model_path=/tmp/vicuna-7b-1.1
elif [[ $FASTCHAT_MODEL == "vicuna-13b" ]]; then
    git clone https://huggingface.co/eachadea/vicuna-13b-1.1 /tmp/vicuna-13b-1.1
    model_path=/tmp/vicuna-13b-1.1
    args="--load-8bit"
elif [[ $FASTCHAT_MODEL == "chatglm-6b" ]]; then
    git clone https://huggingface.co/THUDM/chatglm-6b /tmp/chatglm-6b
    model_path=/tmp/chatglm-6b
else
    echo "Invalid model name. Please set FASTCHAT_MODEL to vicuna-7b, vicuna-13b or chatglm-6b"
    exit 1
fi
'''
action_before_start = ""

start = f'''
if [[ -n $1 ]]; then
    case $1 in
        "controller")
            nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/{name}_controller.log 2>&1 &
            echo $! > /tmp/{name}_controller.pid
            ;;
        "worker")
            nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --model-path $model_path $args > /tmp/{name}_worker.log 2>&1 &
            echo $! > /tmp/{name}_worker.pid
            ;;
        "server")
            nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode reload --port $FASTCHAT_PORT > /tmp/{name}_server.log 2>&1 &
            echo $! > /tmp/{name}_server.pid
            ;;
        *)
            echo "Invalid argument. Usage: bash main.sh [controller|worker|server]"
            ;;
    esac
else
    nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/{name}_controller.log 2>&1 &
    echo $! > /tmp/{name}_controller.pid

    nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --model-path $model_path $args > /tmp/{name}_worker.log 2>&1 &
    echo $! > /tmp/{name}_worker.pid

    nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode reload --port $FASTCHAT_PORT > /tmp/{name}_server.log 2>&1 &
    echo $! > /tmp/{name}_server.pid
    
fi
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
    
custom_reload = f'''
    if [[ -n $2 ]]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller"
                kill_pid "/tmp/{name}_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker"
                kill_pid "tmp/{name}_worker.pid"
                ;;
            "server")
                echo "Stopping Fastchat server"
                kill_pid "/tmp/{name}_server.pid"
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                exit 1
                ;;
        esac
        bash main.sh $2
    else
        kill_pid "/tmp/{name}_server.pid"
        kill_pid "tmp/{name}_worker.pid"
        kill_pid "/tmp/{name}_controller.pid"
        bash main.sh
'''
custom_stop = f'''
    if [[ -n $2 ]]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller"
                kill_pid "/tmp/{name}_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker"
                kill_pid "tmp/{name}_worker.pid"
                ;;
            "server")
                echo "Stopping Fastchat server"
                kill_pid "/tmp/{name}_server.pid"
                ;;
            *)
                echo "Invalid argument. Usage: bash control.sh [reload|start|stop] [controller|worker|server]"
                ;;
        esac
    else
        kill_pid "/tmp/{name}_server.pid"
        kill_pid "tmp/{name}_worker.pid"
        kill_pid "/tmp/{name}_controller.pid"
    fi  
'''

custom_start = ""

# Render the template with the variables
result = template.render(
    title=title,
    name=name,
    custom_reload=custom_reload,
    custom_stop=custom_stop,
    custom_start=custom_start,
)

with open('control.sh', 'w') as f:
    f.write(result)