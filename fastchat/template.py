from jinja2 import Template

# Define the variables to be used in the template
title = "FastChat"
name = "fastchat"
use_python = True

prepare_repo = ""

prepare_env = '''
    pip3 install fschat bitsandbytes
    pip3 install git+https://github.com/huggingface/transformers
'''.strip()

download_model = '''
model_paths=""
model_args = ()
IFS=',' read -ra models <<< "$FASTCHAT_MODEL"
for model in "${models[@]}"
do
if [[ $model == "vicuna-7b" ]]; then
    if [[ ! -d "/tmp/vicuna-7b-1.1" ]]; then
        git clone https://huggingface.co/eachadea/vicuna-7b-1.1 /tmp/vicuna-7b-1.1
    fi
    model_paths="$model_paths,/tmp/vicuna-7b-1.1"
    model_args += ("--load-8bit")
elif [[ $model == "vicuna-13b" ]]; then
    if [[ ! -d "/tmp/vicuna-13b-1.1" ]]; then
        git clone https://huggingface.co/eachadea/vicuna-13b-1.1 /tmp/vicuna-13b-1.1
    fi
    model_paths="$model_paths,/tmp/vicuna-13b-1.1"
    model_args += ("--load-8bit")
elif [[ $model == "chatglm-6b" ]]; then
    if [[ ! -d "/tmp/chatglm-6b" ]]; then
        git clone https://huggingface.co/THUDM/chatglm-6b /tmp/chatglm-6b
    fi
    model_paths="$model_paths,/tmp/chatglm-6b"
    model_args += ("")
else
    echo "Invalid model name. Please set FASTCHAT_MODEL to vicuna-7b, vicuna-13b or chatglm-6b"
    exit 1
fi
done
'''.strip()
action_before_start = ""

worker_loop = f'''
    port=21001
    model_args_id=0
    IFS=',' read -ra models <<< "$model_paths"
    for model in "${{models[@]}}"
    do
    if [ -n "$model" ]; then
        (( port++ ))
        nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --port $port --model-path $model --load-8bit ${{model_args[$model_args_id]}} > /tmp/{name}_worker_$port.log 2>&1 &
        echo $! > /tmp/{name}_worker_$port.pid
        (( model_args_id++ ))
    fi
    done
'''.strip()

start = f'''
if [[ -n $1 ]]; then
    case $1 in
        "controller")
            nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/{name}_controller.log 2>&1 &
            echo $! > /tmp/{name}_controller.pid
            ;;
        "worker")
            {worker_loop}
            ;;
        "server")
            nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode once --port $FASTCHAT_PORT > /tmp/{name}_server.log 2>&1 &
            echo $! > /tmp/{name}_server.pid
            ;;
        *)
            echo "Invalid argument. Usage: bash main.sh [controller|worker|server]"
            ;;
    esac
else
    nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/{name}_controller.log 2>&1 &
    echo $! > /tmp/{name}_controller.pid
    
    {worker_loop}
    
    while true; do
        sleep 5
        response=$(curl -X POST http://localhost:21002/worker_get_status || true )
        if [[ $? -eq 0 ]] && [[ "$(echo "$response" | jq -r '.model_names')" != "" ]]; then
            break
        fi
    done

    nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode once --port $FASTCHAT_PORT > /tmp/{name}_server.log 2>&1 &
    echo $! > /tmp/{name}_server.pid
    
fi
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
    
custom_reload = f'''
    if [[ -n $2 ]]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller"
                kill_pid "/tmp/{name}_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker"
                kill_pid "/tmp/{name}_worker.pid"
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
        kill_pid "/tmp/{name}_worker.pid"
        kill_pid "/tmp/{name}_controller.pid"
        bash main.sh
    fi
'''.strip()
custom_stop = f'''
    if [[ -n $2 ]]; then
        case $2 in
            "controller")
                echo "Stopping Fastchat controller"
                kill_pid "/tmp/{name}_controller.pid"
                ;;
            "worker")
                echo "Stopping Fastchat worker"
                kill_pid "/tmp/{name}_worker.pid"
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
        kill_pid "/tmp/{name}_worker.pid"
        kill_pid "/tmp/{name}_controller.pid"
    fi  
'''.strip()

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
    
##############################################

with open('../template/env.j2') as f:
    template = Template(f.read())
    
export_required_env = '''
'''.strip()
other_commands = '''
export FASTCHAT_MODEL=${FASTCHAT_MODEL:-"vicuna-7b"}
export FASTCHAT_PORT=${FASTCHAT_PORT:-7861}
export EXPOSE_PORTS="$EXPOSE_PORTS:$FASTCHAT_PORT"
export PORT_MAPPING="$PORT_MAPPING:fastchat"
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)