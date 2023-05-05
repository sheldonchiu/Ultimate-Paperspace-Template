from jinja2 import Template

# Define the variables to be used in the template
title = "Command Server"
name = "command"
use_python = True

prepare_repo = ""
prepare_env = "pip install fastapi uvicorn[standard]"

download_model = ""

action_before_start = ""

start = "nohup uvicorn main:app --host 0.0.0.0 --port $COMMAND_PORT > /tmp/command.log 2>&1 &"

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
custom_reload = ""
custom_stop = ""

# Render the template with the variables
result = template.render(
    title=title,
    name=name,
    custom_start=custom_start,
    custom_reload=custom_reload,
    custom_stop=custom_stop,
)

with open('control.sh', 'w') as f:
    f.write(result)