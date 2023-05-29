from jinja2 import Template

# Define the variables to be used in the template
title = "Rclone" 
name = "rclone"
use_python = False


prepare_repo = ""
prepare_env = '''
    curl https://rclone.org/install.sh | sudo bash
    mkdir -p /root/.config/rclone
'''.strip()

download_model = ""

action_before_start = ""

start = f'''
rclone serve $RCLONE_SERVE_PROTOCOL --addr :$RCLONE_PORT --copy-links --user $RCLONE_USERNAME --pass $RCLONE_PASSWORD $RCLONE_SERVE_PATH > /tmp/{name}.log 2>&1 &
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

custom_start = ""
custom_stop = ""
custom_reload = ""

# Render the template with the variables
result = template.render(
    title=title,
    name=name,
    custom_start=custom_start,
    custom_stop=custom_stop,
    custom_reload=custom_reload,
)

with open('control.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/env.j2') as f:
    template = Template(f.read())
    
export_required_env = '''
export REQUIRED_ENV="RCLONE_USERNAME,RCLONE_PASSWORD"
'''
other_commands = '''
export RCLONE_SERVE_PROTOCOL=${RCLONE_SERVE_PROTOCOL:-webdav}
export RCLONE_PORT=${RCLONE_PORT:-8080}
export RCLONE_SERVE_PATH=${RCLONE_SERVE_PATH:-/notebooks}

export EXPOSE_PORTS="$EXPOSE_PORTS:$RCLONE_PORT"
export PORT_MAPPING="$PORT_MAPPING:rclone"
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)