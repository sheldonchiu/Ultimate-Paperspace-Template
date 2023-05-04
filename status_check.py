import os

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
table = [['Program', 'Running']]

# Process each pid file
for pid_file in pid_files:
    # Read the PID from the file
    with open(os.path.join('/tmp', pid_file), 'r') as f:
        pid = int(f.read().strip())

    # Check if the process is running
    
    running = is_process_running(pid)

    # Add a row to the table
    table.append([pid_file.replace('.pid', ''), running])

# Determine the maximum width of each column
max_widths = [max(len(str(row[i])) for row in table) for i in range(len(table[0]))]
# Print the table
print('{:>{}}      {}'.format(table[0][0], max_widths[0], table[0][1]))
print('-' * (max_widths[0] + max_widths[1] + 8))
for row in table[1:]:
    print('{:>{}}      {}'.format(row[0], max_widths[0], 'Yes' if row[1] else 'No'))