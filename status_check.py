import os
import subprocess

try:
    from prettytable import PrettyTable
except ImportError:
    # Use subprocess to run the pip command
    subprocess.check_call(['pip', 'install', 'prettytable'])
    from prettytable import PrettyTable


# Function to check if a process is running
def is_process_running(pid):
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False

# Find files matching the pattern *.pid in /tmp
pid_files = [f for f in os.listdir('/tmp') if f.endswith('.pid')]

# Initialize the table
table = PrettyTable()
table.field_names = ['Program', 'Running', "URL"]

# Process each pid file
for pid_file in pid_files:
    # Read the PID from the file
    with open(os.path.join('/tmp', pid_file), 'r') as f:
        pid = int(f.read().strip())

    # Check if the process is running
    
    running = is_process_running(pid)
    
    host_file = os.path.join('/tmp', pid_file.replace('.pid', '.host'))
    if os.path.isfile(host_file):
        with open(host_file, 'r') as f:
            host = f"https://{f.read().strip()}"
    else:
        host = ""

    # Add a row to the table
    table.add_row([pid_file.replace('.pid', ''), running, host])

print(table)