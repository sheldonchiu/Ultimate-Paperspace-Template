import os

username = os.environ.get('COMMAND_USERNAME')
password = os.environ.get('COMMAND_PASSWORD')

base_url = os.environ.get('COMMAND_BASE_URL', "http://localhost")

fooocus_port = os.environ.get('SD_FOOOCUS_PORT', '7015')
fooocus_subfoler = os.environ.get('SD_FOOOCUS_SUBFOLDER', '/')
