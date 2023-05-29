from jinja2 import Template

# Define the variables to be used in the template
title = "Minio" 
name = "minio"
use_python = False

prepare_repo = ""

prepare_env = '''
  curl https://dl.min.io/client/mc/release/linux-amd64/mc \\
    --create-dirs \\
    -o /tmp/minio-binaries/mc

  chmod +x /tmp/minio-binaries/mc
  export PATH=$PATH:/tmp/minio-binaries/
  echo "export PATH=\$PATH:/tmp/minio-binaries/" >> /etc/bash.bashrc
'''.strip()
download_model = ""

action_before_start = '''
/tmp/minio-binaries/mc alias set dst $S3_HOST_URL $S3_ACCESS_KEY $S3_SECRET_KEY
'''.strip()

start = f'''
if [[ -z $S3_MIRROR_PATH || -z $S3_MIRROR_TO_BUCKET ]]; then
    echo "ENV S3_MIRROR_PATH or S3_MIRROR_TO_BUCKET not provided, skipping minio mirror"
else
    mkdir -p $S3_MIRROR_PATH
    nohup /tmp/minio-binaries/mc mirror --overwrite --watch --quiet $S3_MIRROR_PATH dst/$S3_MIRROR_TO_BUCKET > /tmp/{name}.log 2>&1 &
    echo $! > /tmp/{name}.pid
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
export REQUIRED_ENV="S3_HOST_URL,S3_ACCESS_KEY,S3_SECRET_KEY"
'''.strip()
other_commands = ""
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)